# Python Backend Devcontainer Template

A fully self-contained devcontainer for Python backend projects with Claude Code running in
permissive mode (`--dangerously-skip-permissions`). No host-path dependencies — copy `.devcontainer/`
into any project and it works on any machine.

---

## What's included

| Component | Detail |
|-----------|--------|
| Base image | `node:20` (Debian Bookworm) |
| Python | 3.12.10 via **pyenv** |
| Package manager | Poetry 2.3.2 (in-project `.venv`) |
| Task runner | `just` (latest at build time — floating install) |
| Test reporting | `allure` CLI 2.38+ (requires JRE — bundled via `default-jre-headless`) |
| Claude Code | Latest — `cx` alias for permissive mode |
| Shell | Zsh + Oh-my-zsh, aliases baked into image |
| Firewall | Outbound restricted to Anthropic, GitHub, PyPI, npm, VS Code marketplace |

### Aliases (`ch` to display inside the container)

| Alias | Command |
|-------|---------|
| `cc` | `claude` (standard, with permission prompts) |
| `cx` | `claude --dangerously-skip-permissions` (permissive mode) |
| `cv` | Permissive mode + voice-optimised system prompt |
| `h` | `claude --model haiku` (fast, cheap) |
| `ct` | `claude --teleport` |
| `cdi` | Claude with local `ai/diagrams/**/*.md` context injected |

---

## Host Shell Prerequisite

This template assumes your host shell has already been configured with tool-belt's
Oh My Zsh helpers elsewhere in the repo setup. In particular, the workflow below expects
`~/.oh-my-zsh/custom/claude.zsh` to already provide:

- `dc_sync_python`

This README does not define how those host shell scripts are installed or maintained.
It only depends on them being present.

For the canonical host setup instructions, see the repo-level
[`README.md`](../../README.md).

If they are not installed on your machine, use the manual `cp` or `rsync` commands shown below
instead of `dc_sync_python`.

---

## Using the template in a new project

### First time — copy into a project

Use the `dc_sync_python` shell function (available in tool-belt's `claude.zsh`):

```zsh
cd /your-project
dc_sync_python           # syncs the python-backend template into ./.devcontainer/
```

Or manually:
```bash
cp -r path/to/tool-belt/devcontainer-templates/python-backend/.devcontainer /your-project/
```

### Pulling template updates into an existing project

When the template changes in tool-belt, sync any project that uses it:

```zsh
cd /your-project
dc_sync_python           # rsyncs latest .devcontainer/ from tool-belt
git diff .devcontainer/  # review what changed
git add .devcontainer/ && git commit -m "chore: update devcontainer from tool-belt"
```

Then rebuild the container (see below).

### Opening the container

Open the project in VS Code, then use **`Cmd+Shift+P`** and select
**`Dev Containers: Reopen in Container`**.
VS Code builds the image on first open (~5-8 min — pyenv compiles Python 3.12).

Once inside, run `cx` to launch Claude in permissive mode — no "Allow tool?" prompts.
The firewall is the safety net.

### Rebuilding after changes

When you modify anything in `.devcontainer/`:

- **`Cmd+Shift+P`** → `Dev Containers: Rebuild Container`
- Without cache (e.g. after a base image security update): `Cmd+Shift+P` → `Dev Containers: Rebuild Without Cache and Reopen in Container`

### Adapting for your project

- **Additional outbound hosts** — extend `init-firewall.sh` with extra `resolve_to_set` calls
  (e.g. Sentry, your container registry, Loki):
  ```bash
  resolve_to_set allowed_hosts sentry.io
  ```

- **Personal tool aliases** — add optional host bind mounts in `devcontainer.json` for personal
  zsh scripts (e.g. `java.zsh`, `kubernetes.zsh`). Missing host files fail silently.

- **VS Code extensions** — add to the `extensions` array in `devcontainer.json`, then apply the
  change with **`Cmd+Shift+P`** → `Dev Containers: Rebuild Container`.

- **Python version** — change the `PYTHON_VERSION` build arg in `Dockerfile` and rebuild.

---

## What the image provides

These tools are always available inside any container built from this template,
regardless of which project you use it with:

| Tool | Version | Notes |
|------|---------|-------|
| `just` | latest at build time | Task runner — your project supplies the `justfile` |
| `python` | 3.12.10 | Via pyenv |
| `poetry` | 2.3.2 | In-project `.venv` — run `poetry install` in your project |
| `allure` | 2.38+ | Via npm + JRE — `allure serve -p 4242 <results-dir>` |
| `node` / `npm` | 20 / 10 | Base image |
| `gh` | Bookworm apt default | GitHub CLI |

Per-project tools (`ruff`, `basedpyright`, `pytest`, `uvicorn`, `alembic`, `playwright`) are
installed by your project's `poetry install` — they are not in the image itself.

---

## Ports And Hosts

### Container to host

These host services are intentionally reachable from inside the devcontainer so your app and Claude
can call platform services running on the host machine outside the devcontainer.

| Host | Port | Service | Why it is open |
|------|------|---------|----------------|
| `host.docker.internal` | `5432` | PostgreSQL | Backend apps commonly depend on a local database |
| `host.docker.internal` | `6379` | Redis | Cache / queue / session development |
| `host.docker.internal` | `3000` | Grafana | Local observability dashboards |
| `host.docker.internal` | `9090` | Prometheus | Local metrics scraping and inspection |
| `host.docker.internal` | `3100` | Loki | Local log ingestion and querying |

The firewall also allows:

| Destination | Port / Protocol | Purpose |
|-------------|------------------|---------|
| Docker host gateway | UDP `53` | DNS forwarding |
| `8.8.8.8` | UDP `53` | DNS fallback |
| Allowlisted internet hosts in [`init-firewall.sh`](.devcontainer/init-firewall.sh) | TCP `22`, `443` | GitHub, Anthropic, PyPI, npm, VS Code marketplace |

This is intentionally narrow. The goal is to let the devcontainer reach a small set of host
platform services while still default-denying arbitrary outbound traffic.

To add more host ports:

1. Update `HOST_SERVICE_PORTS` in [`init-firewall.sh`](.devcontainer/init-firewall.sh)
2. Rebuild or reopen the devcontainer so `postStartCommand` reapplies the firewall
3. Add or extend coverage in [`validation-app/tests/test_host_platform_access.py`](validation-app/tests/test_host_platform_access.py)
4. If needed, expose the service in [`validation-app/docker-compose.yml`](validation-app/docker-compose.yml)

Do not open extra host ports casually. Every added port expands what `cx` can reach from inside
the container.

### Host to container

These ports are forwarded from the container back to the host by
[`devcontainer.json`](.devcontainer/devcontainer.json):

| Port | Purpose |
|------|---------|
| `8000` | Backend services |
| `5173` | Frontend dev servers |
| `4242` | Allure reports |

For consumer-specific notes and the validation workflow, see
[`validation-app/README.md`](validation-app/README.md).

---

## Developing the template itself

### Repository layout

```
devcontainer-templates/python-backend/
├── .devcontainer/
│   ├── Dockerfile          # Image definition
│   ├── devcontainer.json   # VS Code container config
│   ├── claude.zsh          # Claude aliases baked into image
│   └── init-firewall.sh    # Outbound firewall (runs at container start)
├── validation-app/         # Minimal FastAPI app used to validate the template
│   ├── README.md           # Validation workflow and consumer-specific notes
│   ├── main.py
│   ├── pyproject.toml
│   ├── poetry.lock
│   └── tests/
│       └── test_health.py
├── docs/                   # Security reports and technical docs
├── CLAUDE.md               # Instructions for Claude working in this directory
└── README.md               # This file
```

### Build the image locally

```bash
cd devcontainer-templates/python-backend/.devcontainer
docker build -t devcontainer-python-backend .
```

First build is slow (~8 min) — pyenv downloads and compiles Python 3.12, JRE is installed.
Subsequent builds use Docker layer cache and are fast unless a `RUN pyenv install` or apt layer
is invalidated.

### Validate all tools after a rebuild

```bash
docker run --rm --user node devcontainer-python-backend \
  /bin/zsh -c "
    source ~/.zshrc
    just --version
    allure --version
    java --version
    python --version
    poetry --version
    node --version
  "
```

### Validated behavior

The current template has been verified with these checks:

- Image build succeeds from `.devcontainer/Dockerfile`
- `poetry --version` reports `2.3.2`
- `poetry install` succeeds in `validation-app` without a lockfile mismatch warning
- `poetry run pytest -q` passes in `validation-app`
- `poetry run ruff check .` passes in `validation-app`
- `pytest --alluredir=allure-results` produces Allure results
- `allure generate allure-results -o allure-report --clean` produces `allure-report/index.html`
- `cx --version` works in an interactive `zsh` session inside the container

### Run a validation shell

```bash
docker run --rm -it \
  -v "$(pwd)/../validation-app:/workspace/validation-app" \
  -v "$HOME/.claude:/home/node/.claude" \
  --user node \
  devcontainer-python-backend \
  /bin/zsh
```

### Validate the full TDD cycle

```bash
docker run --rm \
  -v "$(pwd)/../validation-app:/workspace/validation-app" \
  -v "$HOME/.claude:/home/node/.claude" \
  --user node \
  devcontainer-python-backend \
  /bin/zsh -c "
    source ~/.zshrc
    type cx && python --version && just --version && allure --version
    cd /workspace/validation-app
    poetry config virtualenvs.in-project true
    poetry install --no-root
    poetry run pytest tests/ -v
    poetry run ruff check .
    poetry run pytest --alluredir=allure-results -q
    allure generate allure-results -o allure-report --clean
  "
```

Expected output:
```
cx is an alias for claude --dangerously-skip-permissions
Python 3.12.x
just 1.47.x
2.38.x
...
2 passed
All checks passed!
```

To validate `cx` itself, use an interactive shell because alias expansion does not occur in
non-interactive `zsh -c`:

```bash
docker run --rm -it \
  -v "$HOME/.claude:/home/node/.claude" \
  --user node \
  devcontainer-python-backend \
  /bin/zsh -ic 'alias cx && cx --version'
```

### claude.zsh in the container

`.devcontainer/claude.zsh` is a normal tracked file in this template.
It is intentionally container-specific and does not depend on any host-side sync command.

Keep it aligned with the host `oh-my-zsh/custom/claude.zsh` where that makes sense, but
edit the container copy directly when the container behavior needs to change. In particular,
do not add host-only helpers such as `css()`.

### Known pitfalls

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Current Python version (3.11.2) is not allowed` | `eval "$(pyenv init -)"` not sourced before Poetry | Ensure `.zshrc` sources pyenv init; the Dockerfile bakes this in |
| `No such file or directory: 'python'` | pyenv not on PATH | Source `~/.zshrc` first or check ENV in Dockerfile |
| `externally-managed-environment` pip error | Debian Bookworm blocks system pip | pyenv pip doesn't have this restriction |
| `No file/folder found for package validation-app` | Missing `package-mode = false` | Already fixed in validation app `pyproject.toml` |
| Poetry lock mismatch warning | Lock file generated by different Poetry version | Keep the image Poetry version aligned with `validation-app/poetry.lock`, then rebuild |
| `docker: command not found` | Docker CLI not in image | Add Docker socket mount + docker.io package (see above) |
| testcontainers connection error | No Docker socket | Add Docker socket mount |
| `allure serve` opens random port | No `-p` flag | Use `allure serve -p 4242 allure-results` |

---

## How the firewall works

`init-firewall.sh` runs as root via `sudo` at container start (`postStartCommand`). It:

1. Flushes all iptables rules
2. Resolves allowed hosts to IP sets (GitHub CIDRs from API, DNS lookups for others)
3. Blocks all outbound except DNS (53), SSH (22 to allowed IPs only), and HTTPS to the allowed IP set

This makes `cx` (permissive mode) safe — Claude can auto-approve every tool call because
it cannot reach anything outside the approved set regardless.

**Important:** If you mount the Docker socket, Docker operations bypass this firewall entirely.
They run through the host Docker daemon, which has unrestricted network access. This is an
accepted trade-off when using `platform-up` or `testcontainers`.

The node user can only re-run the firewall script, not modify it (`sudoers.d/node-firewall`).
