#!/bin/bash
set -euo pipefail

# Repeatable end-to-end validation fixture for the python-backend devcontainer.
# Uses the Dev Container CLI so the runtime path is close to what VS Code does.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="$ROOT_DIR/validation-app"
CONFIG_PATH="$ROOT_DIR/.devcontainer/devcontainer.json"
WORKSPACE="$APP_DIR"
CURRENT_STAGE="initializing"

log() {
  printf '\n[%s] %s\n' "devcontainer-fixture" "$1"
}

fail() {
  local exit_code="${1:-1}"
  log "FAILED during stage: $CURRENT_STAGE"
  exit "$exit_code"
}

run_stage() {
  local name="$1"
  shift
  CURRENT_STAGE="$name"
  log "START: $name"
  "$@"
  log "PASS: $name"
}

run_in_container() {
  local name="$1"
  local command="$2"
  run_stage "$name" \
    devcontainer exec \
      --workspace-folder "$WORKSPACE" \
      --config "$CONFIG_PATH" \
      zsh -ic "$command"
}

cleanup() {
  # Always tear down temporary validation resources so reruns start cleanly.
  log "Cleanup: stopping validation compose services and removing devcontainer"
  docker compose -f "$APP_DIR/docker-compose.yml" down >/dev/null 2>&1 || true
  local container_id
  container_id="$(docker ps -q -a \
    --filter "label=devcontainer.local_folder=$WORKSPACE" \
    --filter "label=devcontainer.config_file=$CONFIG_PATH" | head -n 1)"
  if [ -n "$container_id" ]; then
    docker rm -f "$container_id" >/dev/null 2>&1 || true
  fi
}

trap 'fail $?' ERR
trap cleanup EXIT

# Host Postgres and Redis are part of the fixture because the devcontainer firewall
# is expected to allow access back to these services on the host.
run_stage "start host platform services" \
  docker compose -f "$APP_DIR/docker-compose.yml" up -d db redis

# Create the devcontainer through the Dev Container CLI rather than raw docker run.
run_stage "create devcontainer with devcontainer up" \
  devcontainer up \
    --workspace-folder "$WORKSPACE" \
    --config "$CONFIG_PATH" \
    --remove-existing-container \
    --log-level info

# Verify the tools the template promises are actually present inside the live container.
run_in_container "tool versions" \
  'python --version && poetry --version && just --version && allure --version'

# Validate cx the way it is used in VS Code: inside interactive zsh.
run_in_container "claude alias in interactive shell" \
  'alias cx && cx --version'

run_in_container "poetry install" \
  'poetry install'

run_in_container "app test suite" \
  'poetry run pytest -q'

run_in_container "ruff checks" \
  'poetry run ruff check .'

run_in_container "allure result generation" \
  'poetry run pytest --alluredir=allure-results -q'

run_in_container "allure report generation" \
  'allure generate allure-results -o allure-report --clean'

# These tests prove the firewall allows the documented host platform ports.
run_in_container "host platform access tests" \
  'VALIDATE_HOST_PLATFORM=1 poetry run pytest tests/test_host_platform_access.py -q'

log "All validation stages passed"
