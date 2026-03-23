# Devcontainer Validation Fixture

This is the repeatable validation fixture for the `python-backend` devcontainer.

Use this when changing:

- `.devcontainer/devcontainer.json`
- `.devcontainer/Dockerfile`
- `.devcontainer/init-firewall.sh`
- `.devcontainer/claude.zsh`
- `validation-app/docker-compose.yml`
- host-platform access tests

## Preferred Validation Path

Use the Dev Container CLI, not plain `docker build` / `docker run`, because it is closer to
the VS Code Dev Containers workflow.

The fixture validates:

- devcontainer creation through `devcontainer up`
- `postStartCommand` firewall application
- Python, Poetry, `just`, Allure, and Claude availability
- interactive `cx` alias behavior
- app tests and Ruff
- Allure result and report generation
- host-platform access to `5432`, `6379`, `9090`, `3100`, and `3000`

## One Command

From `validation-app/`:

```bash
bash scripts/run_devcontainer_cli_validation.sh
```

The script itself is also documented with inline comments describing:

- why the fixture uses the Dev Container CLI
- why host services are started first
- why `cx` is validated in interactive `zsh`
- why cleanup runs on every exit path

## What It Does

1. Starts host Postgres and Redis from `docker-compose.yml`
2. Brings the devcontainer up with `devcontainer up`
3. Runs validation commands inside it with `devcontainer exec`
4. Verifies host-platform access tests from inside the live devcontainer
5. Cleans up the temporary devcontainer and compose services on exit

## Notes

- This fixture assumes the monitoring endpoints on `3000`, `9090`, and `3100` are already
  available on the host, or are otherwise intentionally provided during validation.
- The installed Dev Container CLI version used during creation of this fixture was `0.84.1`.
- `cx` must be validated in interactive `zsh`; alias expansion does not occur in non-interactive shells.
