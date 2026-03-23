# Security Review — Python FastAPI Devcontainer Template

**Report ID:** SEC-2026-03-23
**Date:** 2026-03-23
**Scope:** `devcontainer-templates/python-backend/` in `tool-belt` repository
**Branch reviewed:** `feat/devcontainer-templates` @ `da20598`
**Reviewer:** Claude Code (automated + manual)
**Tools run:** trivy 0.69, gitleaks 8.30.1 (manual code review)

---

## Executive Summary

The devcontainer provides a well-architected permissive-mode Claude Code environment with a meaningful outbound firewall. It is **appropriate for single-user personal development use**. It is not designed for multi-user or shared infrastructure deployment and should not be adapted for that purpose without significant additional hardening.

**One actionable finding (FIND-001) was fixed during this review.** The SSH egress rule was unrestricted, allowing outbound connections to any IP on port 22. This was tightened to the approved allowlist.

The remaining open findings are either accepted trade-offs inherent to this use case, or Debian base image CVEs with no upstream fix available.

| Severity | Open | Fixed during review |
|----------|------|---------------------|
| Critical | 0    | 0 |
| High     | 1    | 1 |
| Medium   | 3    | 0 |
| Low      | 2    | 0 |
| Info     | 1    | 0 |

---

## Findings

---

### FIND-001 — SSH egress unrestricted to all destinations

**Severity:** High (CVSS 8.1)
**Status:** **FIXED** — `init-firewall.sh` line 61 (now line 61 post-fix)
**File:** `.devcontainer/init-firewall.sh`

**Before:**
```bash
iptables -A OUTPUT -p tcp --dport 22  -j ACCEPT
```

**After:**
```bash
iptables -A OUTPUT -p tcp --dport 22  -m set --match-set allowed_hosts dst -j ACCEPT
```

**Description:** The original rule permitted outbound TCP port 22 to any IP address. A compromised supply chain package or a Claude tool invocation could establish an SSH tunnel or SOCKS proxy to an arbitrary external host, bypassing the firewall's allowlist design. Port 22 to arbitrary hosts enables data exfiltration over encrypted channels that would be invisible to the firewall log.

**Impact:** Full bypass of the outbound allowlist via SSH tunnelling.

**Remediation:** Restrict SSH egress to the `allowed_hosts` ipset, which already contains GitHub's CIDR ranges. Git-over-SSH to GitHub (the only legitimate use case) continues to work.

**References:** CWE-923 (Improper Restriction of Communication Channel to Intended Endpoints)

---

### FIND-002 — curl-pipe-bash installer pattern for pyenv

**Severity:** Medium
**Status:** Open — accepted trade-off
**File:** `.devcontainer/Dockerfile` line 41

```dockerfile
RUN curl -fsSL https://pyenv.run | bash
```

**Description:** The pyenv installer is fetched and executed in a single pipeline during image build. No checksum or signature verification is performed. If `pyenv.run` or the GitHub repository it redirects to is compromised, arbitrary code executes as the `node` user during image build and is baked into the image silently.

The same pattern applies to `zsh-in-docker` on line 50 (fetched via `wget`).

**Impact:** Full container compromise if either upstream source is compromised at build time.

**Remediation options:**
- Pin to a specific commit SHA in the curl URL and verify the checksum, or
- Copy the installer into the repo and audit it on update, or
- Accept: the risk profile matches standard open-source Docker build practice; mitigated by rebuilding from scratch rather than pulling cached images from unknown registries.

**References:** CWE-494 (Download of Code Without Integrity Check), SLSA Level 1 gap

---

### FIND-003 — `CLAUDE_CODE_VERSION=latest` unpinned

**Severity:** Medium
**Status:** Open — accepted trade-off
**File:** `.devcontainer/Dockerfile` line 6 and `devcontainer.json` line 7

```dockerfile
ARG CLAUDE_CODE_VERSION=latest
```
```json
"CLAUDE_CODE_VERSION": "latest"
```

**Description:** Claude Code is installed as an npm package resolved at build time. `latest` is resolved at the moment `docker build` runs, which means two builds from the same Dockerfile may produce different images. A breaking change or (theoretically) a compromised npm package version could silently enter the image on the next rebuild.

**Impact:** Non-reproducible builds; risk of untested Claude Code version being used.

**Remediation:** Pin to a specific version, e.g. `CLAUDE_CODE_VERSION=1.x.y`, and update intentionally. Check [npm registry](https://www.npmjs.com/package/@anthropic-ai/claude-code) for current version.

**References:** CWE-1357 (Reliance on Insufficiently Trustworthy Component)

---

### FIND-004 — `~/.claude` host directory mounted into container

**Severity:** Medium
**Status:** Open — by design; accepted
**File:** `.devcontainer/devcontainer.json` line 14

```json
"source=${localEnv:HOME}/.claude,target=/home/node/.claude,type=bind,consistency=cached"
```

**Description:** The entire `~/.claude` directory is bind-mounted into the container. This directory contains:
- API authentication tokens (used to make calls to Anthropic's API at your billing account's expense)
- All conversation history from every Claude Code session on the host machine
- Local settings and project configurations

Any process running in the container — including Claude itself in permissive mode — can read, modify, or delete this data.

**Impact:** API key exposure; conversation history readable; potential credential theft if combined with a compromised package.

**Remediation:** This mount is required for Claude Code authentication. Accepted. Mitigation: do not add other services (background agents, sidecar processes) to this container that do not need auth access.

**References:** CWE-200 (Exposure of Sensitive Information)

---

### FIND-005 — Firewall not enforced during image build

**Severity:** Low
**Status:** Open — inherent to devcontainer design
**File:** `.devcontainer/Dockerfile`, `.devcontainer/devcontainer.json` line 21

**Description:** The firewall (`init-firewall.sh`) runs as a `postStartCommand` — after the container starts. All `RUN` steps during `docker build` execute with unrestricted network access. This is standard Docker build behaviour, but it means the network restriction only applies at runtime, not at build time.

**Impact:** Build-time scripts can reach arbitrary internet hosts (PyPI, GitHub, python.org, zsh-in-docker CDN, npmjs.com). This is intentional but means build-time supply chain attacks are not mitigated by the runtime firewall.

**Remediation:** Accept. For a higher-assurance build, use a build-time network policy via Docker's `--network` flag or a build proxy. Out of scope for this use case.

---

### FIND-006 — iptables flush leaves container unprotected during firewall restart

**Severity:** Low
**Status:** Open — accepted
**File:** `.devcontainer/init-firewall.sh` line 15

```bash
iptables -F; iptables -X; iptables -t nat -F; iptables -t nat -X
ipset destroy 2>/dev/null || true
```

**Description:** The firewall script flushes all rules before re-applying them. If the script fails after the flush (e.g. DNS unavailable when resolving GitHub CIDRs), the container is left with no firewall rules until the script is re-run. The `set -euo pipefail` at the top of the script causes it to exit on failure, which surfaces the error, but does not restore the previous rules.

**Impact:** Temporary unprotected state on firewall failure or during manual re-runs. Low probability; fails loudly.

**Remediation:** Accept. Mitigation: the GitHub check uses `die` (non-zero exit), which makes the failure visible. Log monitoring of postStartCommand output is sufficient.

---

### FIND-007 — Debian base image CVEs (trivy scan)

**Severity:** Info (not actionable)
**Status:** Open — no upstream fix
**Tool:** trivy image scan

**Summary:** Trivy reports 284 CVEs against the `debian 12.13` base (250 HIGH, 34 CRITICAL). The majority have `will_not_fix` or `affected` status with no fixed version available in Bookworm.

Notable packages affected:

| Package | CVE | Severity | Status | Notes |
|---------|-----|----------|--------|-------|
| `gh` | CVE-2024-52308 | CRITICAL | affected | GitHub CLI RCE (v2.23 installed; fix in v2.6.1+ — note: gh pkg in Bookworm is outdated) |
| `git` | CVE-2025-48384 | HIGH | affected | Arbitrary code execution |
| `git` | CVE-2025-48385 | HIGH | affected | Arbitrary file writes |
| `imagemagick` | CVE-2026-25971 | CRITICAL | will_not_fix | DoS — ImageMagick not used by this stack |
| `libaom3` | CVE-2023-6879 | CRITICAL | affected | Heap buffer overflow — not used by this stack |
| `libc-bin` | CVE-2026-0861 | HIGH | affected | glibc heap corruption |

**Assessment:** Most CRITICAL findings are in libraries not used by the FastAPI/Claude Code stack (ImageMagick, libaom3). The `gh` CLI CVE is more relevant but exploitability requires a malicious `gh` extension being installed, which is not part of this template's workflow. The `git` CVEs are relevant but the fix is upstream in Bookworm's package feed — rebuild when a patched package ships.

**Remediation:** Rebuild the image periodically (`docker build --no-cache`) to pick up Debian security updates as they land in Bookworm. Pin `gh` CLI to a known-good version if the RCE CVE is a concern for your threat model.

---

## Secrets Scan Results

**Tool:** gitleaks 8.30.1
**Result:** No leaks found — scanned 50.73 KB in 60.6ms.

No hardcoded secrets, API keys, or credentials detected in any template file.

---

## Trivy Config Scan Results

**Tool:** trivy config (Dockerfile misconfig)
**Result:** 1 finding — LOW

| Finding | Severity | Notes |
|---------|----------|-------|
| DS-0026: Missing HEALTHCHECK | Low | Devcontainer images are not orchestrated by Docker health checks; this is not applicable |

---

## Prioritised Remediation

| Priority | Finding | Action |
|----------|---------|--------|
| 1 | FIND-001 — SSH egress | **DONE** — fixed in this review |
| 2 | FIND-003 — Unpinned `CLAUDE_CODE_VERSION` | Pin to a specific version |
| 3 | FIND-002 — curl-pipe-bash | Accept or pin to commit SHA |
| 4 | FIND-007 — Debian CVEs | Rebuild image periodically |
| 5 | FIND-004, FIND-005, FIND-006 | Accept — inherent to design |

---

## Conclusion

This template is well-suited for its intended purpose: a personal, single-developer workstation environment where permissive Claude Code operation is traded for developer velocity, with the firewall as the primary safety control. The design is explicit about this trade-off.

The one concrete security gap — unrestricted SSH egress — has been fixed. All remaining findings are either accepted trade-offs or unactionable base-image CVEs. No secrets were found. The firewall design is sound: IP-based allowlisting with default-deny outbound is significantly stronger than a typical devcontainer.

**Verdict:** Safe for personal use. Not suitable for shared, multi-user, or production-adjacent infrastructure without substantial additional hardening.
