# tool-belt

A personal developer toolkit — shell commands, Claude AI standards, and utility scripts.

---

## Installation

Everything runs through oh-my-zsh custom files. Install once and all commands are available in every terminal session.

**Requirements:** [oh-my-zsh](https://ohmyz.sh)

```bash
cp ~/Development/git-hub/tool-belt/oh-my-zsh/custom/*.zsh ~/.oh-my-zsh/custom/
source ~/.zshrc
```

That's it. Run `ch` to see all available commands.

---

## Commands

| Command | Description |
|---------|-------------|
| `cc` | Launch Claude |
| `cx` | Launch Claude, skip all permission prompts |
| `cv` | Launch Claude in voice-optimised mode |
| `cdi` | Launch Claude with local diagram context |
| `css` | Sync global Claude standards into the current project |
| `ch` | Show this command list |
| `dtree` | Print an ASCII directory tree of any path |

---

## Setting Up Claude Standards in a New Project

Run `css` from the project root:

```bash
cd ~/your-project
css
```

Then add the following to your project's `CLAUDE.md` (create it if it doesn't exist):

```markdown
## Global Standards
@.claude/standards/_INDEX.md
```

Claude will now read the global standards automatically. The `css` command is safe to re-run — it will pull in any updates from tool-belt without touching your `CLAUDE.md`.

---

## What's in the repo

```
oh-my-zsh/custom/   # Shell customisations — copy these to ~/.oh-my-zsh/custom/
claude/standards/   # Global Claude coding standards (source of truth)
scripts/            # Utility scripts (Python + shell)
```
