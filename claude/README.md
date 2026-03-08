# Claude Global Standards Sync

A lightweight system that distributes global coding standards from `tool-belt` into any project's `.claude/standards/` directory on demand.

## How It Works

```
css (zsh command)
    → runs scripts/claude-standards-sync.sh
        → copies claude/standards/ → .claude/standards/
            → project CLAUDE.md imports @.claude/standards/_INDEX.md
                → Claude reads all *_STANDARDS.md files
```

`claude-standards-sync.sh` is **safe and non-destructive** — it only ever writes to `.claude/standards/`. It never touches the project's root `CLAUDE.md` or any other project file.

---

## One-Time Machine Setup

### Step 1: Add `.claude/standards/` to your global gitignore

```bash
echo ".claude/standards/" >> ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
```

This keeps synced standards out of project git history — they are always sourced from `tool-belt`.

### Step 2: Add the `oh-my-zsh/custom/` files to your shell

```bash
cp ~/Development/git-hub/tool-belt/oh-my-zsh/custom/*.zsh ~/.oh-my-zsh/custom/
source ~/.zshrc
```

This gives you the `css` command (and others) in any terminal session.

---

## Per-Project Setup (one time per project)

1. Run `css` from the project root to sync the standards files
2. Add the following to your project's `CLAUDE.md`:

```markdown
## Global Standards
@.claude/standards/_INDEX.md
```

This file is **never modified by the sync script** — it is yours to maintain.

---

## Updating Standards

Edit any file in `tool-belt/claude/standards/` (e.g., `PYTHON_STANDARDS.md`). Then re-run `css` in any project to pull in the changes.

---

## Standards Files

| File | Description |
|------|-------------|
| `_INDEX.md` | Master list — imported by project `CLAUDE.md` |
| `GIT_STANDARDS.md` | Git workflow, branching, and commit conventions |
| `PYTHON_STANDARDS.md` | Python style, typing, testing, and tooling standards |
| `JAVA_STANDARDS.md` | Java style, type safety, testing, and build standards |
