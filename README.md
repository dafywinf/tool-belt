# tool-belt

A personal developer toolkit — shell commands, Claude AI standards, and utility scripts.

---

## Installation

Requires [oh-my-zsh](https://ohmyz.sh). Copy the custom files and reload your shell:

```bash
cp ~/Development/git-hub/tool-belt/oh-my-zsh/custom/*.zsh ~/.oh-my-zsh/custom/
source ~/.zshrc
```

---

## Shell Commands

### Claude — `claude.zsh` · help: `ch`

| Command | Description |
|---------|-------------|
| `cc` | Launch Claude |
| `cx` | Launch Claude, skip all permission prompts |
| `cv` | Launch Claude in voice-optimised mode |
| `cdi` | Launch Claude with local diagram context |
| `css` | Sync global Claude standards into the current project |
| `ghv` | Open current GitHub repo in browser |
| `ghcp` | Copy current GitHub repo URL to clipboard |
| `mcpi` | Launch MCP Inspector |

---

### Java — `java.zsh` · help: `jh`

| Command | Description |
|---------|-------------|
| `jv` | Show current Java version |
| `jdk8` | Switch active JDK to JDK 8 |

---

### Kubernetes — `kubernetes.zsh` · help: `kh`

| Command | Description |
|---------|-------------|
| `k` | kubectl |
| `kgp` | kubectl get pods |
| `kl` | kubectl logs -f |
| `hm` | helm |
| `argo` | argocd |
| `argol` | argocd login |

---

### Tools — `tools.zsh` · help: `dth`

| Command | Description |
|---------|-------------|
| `dtree` | Print ASCII directory tree of current or given path |

---

### Keybindings — `keybindings.zsh`

| Binding | Action |
|---------|--------|
| `Ctrl+→` | Accept next word of autosuggestion |

---

## Other Useful Tools

### `npx ccstatusline@latest`

Adds a customisable status line to your Claude Code session that displays real-time context — current git branch, working directory, token usage, and other session metadata — directly in the Claude Code interface.

Valuable because it keeps you oriented without breaking flow: you can see at a glance which branch you're on, how much context you've consumed, and where you are in the filesystem, all without switching away from the conversation.

```bash
npx ccstatusline@latest
```

---

## Setting Up Claude Standards in a New Project

Run `css` from the project root, then add this to your `CLAUDE.md`:

```markdown
## Global Standards
@.claude/standards/_INDEX.md
```

See [`claude/README.md`](claude/README.md) for full details.
