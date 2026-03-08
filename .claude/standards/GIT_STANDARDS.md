# Git Workflow & Conventions

## Branch Naming

- **Convention:** `type/description-issueID` (e.g., `feat/user-auth-101`)
- **Allowed Types:** `feat`, `fix`, `refactor`, `docs`, `chore`
- **Rule:** Always create a new branch for a new task. Never work directly on `main`.

## Conventional Commits

- **Format:** `type(scope): description`
- **Rule:** Use lowercase for the type and description. No period at the end.
- **Types:**
  - `feat`: A new feature
  - `fix`: A bug fix
  - `docs`: Documentation only changes
  - `refactor`: A code change that neither fixes a bug nor adds a feature
  - `test`: Adding missing tests or correcting existing tests
  - `chore`: Updating build tasks, package manager configs, etc.

## Workflow Rules

- Before committing, always run `pytest` to ensure tests pass.
- Use atomic commits (one logical change per commit).
- Always include an Allure report decorator in test files.
