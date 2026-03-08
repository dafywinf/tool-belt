# Git Workflow & Conventions

## Starting New Work

When asked to start a new feature or work on a task, follow this sequence:

1. `git checkout main`
2. `git pull origin main`
3. `git checkout -b type/short-description`

Never work directly on `main`.

## Branch Naming

- **Convention:** `type/short-description` (e.g., `feat/user-auth`, `fix/login-bug`)
- **Allowed Types:** `feat`, `fix`, `refactor`, `docs`, `chore`

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
- **Before raising a PR, squash commits into a single logical commit.**
  ```bash
  git rebase -i origin/main
  ```
  Mark all commits except the first as `squash` (or `s`), then write a single conventional commit message summarising the change.
