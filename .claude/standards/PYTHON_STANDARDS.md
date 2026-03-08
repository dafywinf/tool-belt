# Python Development Standards

## Style & Formatting

- Formatter/Linter: Ruff (88 chars).
- Naming: Snake_case for functions, PascalCase for classes.
- Documentation: Google-style docstrings.

## Type Hinting (Mandatory)

- No `Any`. Use explicit types for all parameters and return values.
- Use Pydantic v2 for all data validation and configuration.

## Testing (Pytest + Allure)

- All tests must be decorated with `@allure.feature` and `@allure.story`.
- Use `allure.step` for complex test steps.
- Run command: `pytest --alluredir=allure-results`.
- Coverage: Use `pytest-cov`, minimum 80% coverage required for new features.

## Tooling

- Dependency management: `uv` (preferred) or `Poetry`.
- Static Analysis: Run `mypy --strict` before finalizing any PR.
