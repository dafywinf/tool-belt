# ADR-001: Claude Code Permissive Mode via Firewalled Devcontainer

**Date:** 2026-03-23
**Status:** Accepted
**Deciders:** @dafywinf

---

## Context

Claude Code normally prompts for approval before every tool use (file writes,
shell commands, git operations). For autonomous development workflows this
creates constant interruption — defeating the purpose of an AI assistant.

`--dangerously-skip-permissions` removes all prompts, but running it on a
developer's host machine means Claude can reach any network destination,
modify any file, and exfiltrate data silently.

We need a way to use permissive mode safely and reproducibly.

---

## Decision

Run Claude Code inside a devcontainer with a restrictive outbound firewall
baked in. The firewall — not runtime permission prompts — becomes the safety
control.

**The `cx` alias** (`claude --dangerously-skip-permissions`) is baked into
the container image via `claude.zsh` COPY'd in the Dockerfile. It is
available on any machine that builds the image, with no host-path dependency.

---

## Architecture

```
┌─────────────────── Host Machine ──────────────────────────────┐
│                                                                │
│  $ just platform-up                                           │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  docker-compose                                         │  │
│  │  ┌──────────┐  ┌───────┐  ┌───────────────────────┐   │  │
│  │  │ postgres │  │ redis │  │ prometheus/loki/grafana│   │  │
│  │  └──────────┘  └───────┘  └───────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────┘  │
│  ┌─────────┴──────── Devcontainer ───────────────────────┐    │
│  │                                                        │    │
│  │  ┌──────────────────────────────────────────────────┐ │    │
│  │  │  iptables (init-firewall.sh)                     │ │    │
│  │  │  ALLOW: Anthropic, GitHub, PyPI, npm, VSCode     │ │    │
│  │  │  DENY:  everything else                          │ │    │
│  │  └──────────────────────────────────────────────────┘ │    │
│  │                                                        │    │
│  │  cx (claude --dangerously-skip-permissions)            │    │
│  │    ├── reads/writes /workspace (bind mount)            │    │
│  │    ├── runs just, pytest, ruff, poetry                 │    │
│  │    ├── pushes to GitHub (SSH/HTTPS — allowed)          │    │
│  │    └── cannot reach arbitrary internet hosts           │    │
│  │                                                        │    │
│  │  /workspace  ←→  host project directory (bind mount)  │    │
│  │  ~/.claude   ←→  host auth tokens (bind mount)        │    │
│  └────────────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────┘
```

---

## Two-actor model

| Actor | Where | Responsibility |
|-------|-------|----------------|
| Developer | Host | `just platform-up`, VS Code, image rebuild |
| Claude (`cx`) | Container | Code, tests, git, CI gate — no prompts |

Platform services may run on the **host** via `docker-compose`. The firewall includes
an explicit host-gateway allowlist for the platform ports this template expects
(`5432`, `6379`, `9090`, `3100`, and `3000`), so the container can reach those
services without mounting the Docker socket. These are intentionally narrow, development-specific
exceptions for host Postgres, Redis, Prometheus, Loki, and Grafana rather than a general host
network allowlist.

---

## Why not Docker-in-Docker?

Mounting `/var/run/docker.sock` into the container gives Claude root-equivalent
access to the host Docker daemon, bypassing the iptables firewall entirely
(Docker pulls route through the host network stack, not the container's).

For `testcontainers` (integration tests that spin up real postgres), the socket
mount is required — but it is an explicit opt-in documented in the README, not
the default. The tradeoff is accepted for local development; it should not be
used in CI.

---

## Why firewall-as-safety-net, not prompt-based control?

| Approach | Problem |
|----------|---------|
| Default prompt mode | Blocks autonomous operation; defeats the purpose |
| Skip permissions, no firewall | Claude can exfiltrate data, call arbitrary APIs, post to Slack, etc. |
| Skip permissions + firewall | Claude can auto-approve all tool calls; network reach is bounded |

The firewall is IP-set based (not DNS-based), applied at container start,
with default-deny outbound. It survives DNS spoofing and cannot be modified
by the `node` user (sudoers scoped to one script).

---

## Consequences

**Good:**
- Zero interruption autonomous Claude sessions
- Reproducible on any machine — no host-path dependencies
- Firewall survives container restarts

**Accepted trade-offs:**
- `~/.claude` (auth tokens + conversation history) is readable inside the container
- Docker socket opt-in bypasses the firewall
- Only the explicitly allowlisted host platform ports are reachable through the firewall
- `cx` is only safe in this container — never alias it on the host

**Out of scope:**
- Multi-user or shared infrastructure — not designed for this
- CI runners — use standard permission mode with explicit tool allowlists
