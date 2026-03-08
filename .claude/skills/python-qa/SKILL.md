---
name: python-qa
description: Advanced Python developer specializing in Pytest, Allure reporting, and code validation. Use this when creating new features or fixing bugs.
---

# Python QA & Development Skill

## Workflow

1. **Implementation:** Write the Python code following the standards in `CLAUDE.md`.
2. **Test Generation:** Create a matching test file in `tests/`.
3. **Allure Integration:** - Add `@allure.title` and `@allure.description` to every test function.
   - Organize by `@allure.feature` based on the module name.
4. **Validation:** - Run `pytest --alluredir=allure-results`.
   - If tests fail, fix the code immediately.
   - Run `allure serve allure-results` (if requested) to verify the report.

## Mandatory Checks

- Use `mypy` to check for valid type hints.
- Ensure no bare `except:` blocks are used.
