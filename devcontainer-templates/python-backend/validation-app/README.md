# Validation App

This directory contains the minimal FastAPI app used to validate the
`python-backend` devcontainer template.

It is not the template itself. The reusable template lives in
[`../.devcontainer/`](../.devcontainer/).

## What This Validates

After building the devcontainer image, this app is used to verify:

- `poetry install`
- `pytest`
- `ruff`
- Allure result generation
- Allure static report generation
- interactive Claude startup via `cx`

## Validation Commands

The preferred validation path is the Dev Container CLI fixture:

```bash
bash scripts/run_devcontainer_cli_validation.sh
```

See [`DEVCONTAINER_VALIDATION_FIXTURE.md`](DEVCONTAINER_VALIDATION_FIXTURE.md) for the exact
workflow and scope.

If you need lower-level checks, the raw Docker commands below are still useful:

Build the image from the template root:

```bash
cd ../.devcontainer
docker build -t devcontainer-python-backend .
```

Run the validation app inside that image:

```bash
docker run --rm \
  -v "$(pwd):/workspace" \
  -v "$HOME/.claude:/home/node/.claude" \
  --user node \
  devcontainer-python-backend \
  /bin/zsh -c "
    source ~/.zshrc
    cd /workspace
    poetry install --no-root
    poetry run pytest -q
    poetry run ruff check .
    poetry run pytest --alluredir=allure-results -q
    allure generate allure-results -o allure-report --clean
  "
```

Start the host platform services from this directory before running the host-platform tests:

```bash
docker compose up -d db redis
docker compose --profile monitoring up -d prometheus loki grafana
```

To validate Claude itself, use an interactive shell:

```bash
docker run --rm -it \
  -v "$HOME/.claude:/home/node/.claude" \
  --user node \
  devcontainer-python-backend \
  /bin/zsh -ic 'alias cx && cx --version'
```

## Host Platform Validation

These opt-in tests verify that the devcontainer firewall allows access back to the host platform
services exposed by `docker-compose.yml`:

```bash
VALIDATE_HOST_PLATFORM=1 poetry run pytest tests/test_host_platform_access.py -q
```

To run the same check under an isolated iptables policy from a root container, use:

```bash
docker run --rm \
  --add-host=host.docker.internal:host-gateway \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  --user root \
  -v "$(pwd):/workspace" \
  -v "$HOME/.claude:/home/node/.claude" \
  devcontainer-python-backend \
  bash /workspace/scripts/run_host_platform_validation.sh
```

They check:

- TCP connectivity to host ports `5432`, `6379`, `9090`, `3100`, and `3000`
- HTTP health endpoints for Prometheus, Loki, and Grafana

These ports are allowed because they map to the default host platform services used during
local backend development:

- `5432` PostgreSQL
- `6379` Redis
- `9090` Prometheus
- `3100` Loki
- `3000` Grafana

To allow additional host ports, update [`../.devcontainer/init-firewall.sh`](../.devcontainer/init-firewall.sh)
and add matching assertions in [`tests/test_host_platform_access.py`](tests/test_host_platform_access.py).

## Consumer Notes

The main template is intentionally broader than FastAPI, but this validation app is
FastAPI-based because it gives a small, realistic Python backend workload.

The default firewall now allows host-gateway access for the ports exposed by
`docker-compose.yml`, so a consuming project can use host-run platform services without
mounting the Docker socket into the devcontainer.
