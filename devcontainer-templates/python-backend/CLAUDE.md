# Project Instructions

## Tech Stack

- **Framework:** FastAPI (sync — use `def` not `async def`)
- **Python:** 3.12 (managed via pyenv)
- **Dependencies:** Poetry with in-project `.venv`
- **Linter:** Ruff (88 chars)

## Notes

This is the minimal validation app for the python-backend devcontainer
template. Extend when copying into a real project.

## Validation Workflow

- Prefer the Dev Container CLI over raw Docker when validating this template.
- Default fixture: [`validation-app/DEVCONTAINER_VALIDATION_FIXTURE.md`](validation-app/DEVCONTAINER_VALIDATION_FIXTURE.md)
- Default command: `bash validation-app/scripts/run_devcontainer_cli_validation.sh`
- Validate `cx` in interactive `zsh`, not `zsh -lc`, because alias expansion is interactive-only.
