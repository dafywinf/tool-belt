# Claude Global Standards Sync

A lightweight system that automatically distributes global coding standards from `tool-belt` into any project's `.claude/standards/` directory before Claude runs any tool.

## How It Works

```
PreToolUse hook
    → runs sync.sh
        → copies claude/standards/ → .claude/standards/
            → project CLAUDE.md imports @.claude/standards/_INDEX.md
                → Claude reads all GLOBAL_*.md files
```

`sync.sh` is **safe and non-destructive** — it only ever writes to `.claude/standards/`. It never touches the project's root `CLAUDE.md` or any other project file.

---

## One-Time Machine Setup

### Step 1: Symlink the toolkit

```bash
ln -sf ~/Development/git-hub/tool-belt/claude ~/.claude/toolkit
```

### Step 2: Configure the PreToolUse hook

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": "bash ~/.claude/toolkit/sync.sh"
  }
}
```

This runs `sync.sh` automatically before every tool call Claude makes.

### Step 3: Add `.claude/standards/` to your global gitignore

```bash
echo ".claude/standards/" >> ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
```

This keeps synced standards out of project git history — they are always sourced from `tool-belt`.

---

## Per-Project Setup (one time per project)

Create a `CLAUDE.md` in the project root:

```markdown
# Project: Your Project Name
@.claude/standards/_INDEX.md

## Project Overrides
- Any project-specific rules go here.
```

This file is **never modified by `sync.sh`** — it is yours to maintain.

---

## Updating Standards

Edit any file in `tool-belt/claude/standards/` (e.g., `GLOBAL_PYTHON.md`). The next time Claude runs in any project using this system, `sync.sh` will propagate the change automatically.

---

## Standards Files

| File | Description |
|------|-------------|
| `_INDEX.md` | Master list — imported by project `CLAUDE.md` |
| `GLOBAL_GIT.md` | Git workflow, branching, and commit conventions |
| `GLOBAL_PYTHON.md` | Python style, typing, testing, and tooling standards |
| `GLOBAL_JAVA.md` | Java style, type safety, testing, and build standards |
