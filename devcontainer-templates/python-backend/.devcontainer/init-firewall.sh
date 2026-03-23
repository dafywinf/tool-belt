#!/bin/bash
# Restrictive outbound firewall for the Python backend devcontainer.
#
# Allowed outbound:
#   DNS (53), SSH (22), GitHub, Anthropic API (api.anthropic.com, statsig.anthropic.com),
#   PyPI (pypi.org + files.pythonhosted.org), npm registry, VS Code marketplace,
#   and selected host-gateway service ports for platform services run on the host
#
# Inbound: established/related only.
#
# Fail-safe: any error during initialization triggers the ERR trap, which
# sets OUTPUT to DROP so a partial failure produces a locked-down container
# rather than an open one.

set -euo pipefail

log() { echo "[firewall] $*"; }
die() { echo "[firewall] ERROR: $*" >&2; exit 1; }

# Fail-safe: if the script aborts mid-initialization, lock outbound down.
# Without this, the iptables flush on line ~25 would leave the container fully
# open until the DROP rule at the end of the outbound block is applied.
trap 'log "ERR: initialization failed — setting OUTPUT DROP as fail-safe"; iptables -P OUTPUT DROP; iptables -P INPUT DROP' ERR

log "Flushing existing rules..."
iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X
log "Flush complete."
ipset destroy allowed_hosts 2>/dev/null || true

resolve_to_set() {
  local set_name="$1" host="$2"
  local count=0
  while read -r ip; do
    if ipset add "$set_name" "$ip" 2>/dev/null; then
      count=$((count + 1))
    else
      log "WARNING: ipset add failed for $ip ($host)"
    fi
  done < <(dig +short "$host" A | grep -E '^[0-9]+\.')
  if [ "$count" -eq 0 ]; then
    log "WARNING: resolved 0 IPs for $host — outbound to $host will be BLOCKED"
  else
    log "  $host: $count IP(s) added"
  fi
}

ipset create allowed_hosts hash:net

# GitHub — fetch CIDRs from the meta API; validate non-empty before adding
log "Fetching GitHub CIDRs..."
github_meta=$(curl -sf --max-time 10 https://api.github.com/meta) \
  || die "Failed to fetch GitHub CIDRs from api.github.com/meta"
github_cidr_count=$(echo "$github_meta" | jq -r '.web[], .api[], .git[]' | wc -l)
[ "$github_cidr_count" -gt 0 ] || die "GitHub meta response contained zero CIDRs"
echo "$github_meta" | jq -r '.web[], .api[], .git[]' | while read -r cidr; do
  ipset add allowed_hosts "$cidr" 2>/dev/null || log "WARNING: ipset add failed for $cidr (GitHub)"
done
log "  GitHub: $github_cidr_count CIDR(s) added"

# Anthropic
resolve_to_set allowed_hosts api.anthropic.com
resolve_to_set allowed_hosts statsig.anthropic.com

# PyPI
resolve_to_set allowed_hosts pypi.org
resolve_to_set allowed_hosts files.pythonhosted.org

# npm
resolve_to_set allowed_hosts registry.npmjs.org

# VS Code marketplace
resolve_to_set allowed_hosts marketplace.visualstudio.com
resolve_to_set allowed_hosts vscode.blob.core.windows.net

HOST_GW=$(ip route | awk '/default/ {print $3; exit}')
HOST_SERVICE_PORTS=(5432 6379 9090 3100 3000)
DNS_SERVERS=($(awk '/^nameserver / {print $2}' /etc/resolv.conf))
HOST_SERVICE_IPS=()

if [ -n "$HOST_GW" ]; then
  HOST_SERVICE_IPS+=("$HOST_GW")
fi

while read -r ip; do
  HOST_SERVICE_IPS+=("$ip")
done < <(getent ahostsv4 host.docker.internal 2>/dev/null | awk '{print $1}' | sort -u)

# Inbound
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
if [ -n "$HOST_GW" ]; then
  iptables -A INPUT -s "$HOST_GW" -p udp --sport 53 -j ACCEPT
else
  log "WARNING: no default gateway found — host DNS forwarding rule skipped; using 8.8.8.8 only"
fi
iptables -A INPUT -j DROP

# Outbound
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
for dns_ip in "${DNS_SERVERS[@]}"; do
  iptables -A OUTPUT -d "$dns_ip" -p udp --dport 53 -j ACCEPT
done
iptables -A OUTPUT -d 8.8.8.8    -p udp --dport 53 -j ACCEPT
for host_ip in "${HOST_SERVICE_IPS[@]}"; do
  for port in "${HOST_SERVICE_PORTS[@]}"; do
    iptables -A OUTPUT -d "$host_ip" -p tcp --dport "$port" -j ACCEPT
  done
done
iptables -A OUTPUT -p tcp --dport 22  -m set --match-set allowed_hosts dst -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m set --match-set allowed_hosts dst -j ACCEPT
iptables -A OUTPUT -j DROP

log "Verifying firewall..."
curl -sf --max-time 5 https://api.github.com/zen > /dev/null \
  && log "GitHub: OK" || die "GitHub blocked — check firewall rules"
curl -sf --max-time 5 https://pypi.org/pypi/fastapi/json > /dev/null \
  && log "PyPI: OK" || die "PyPI blocked — check firewall rules"
if [ "${#HOST_SERVICE_IPS[@]}" -gt 0 ]; then
  log "Host service allowlist active for IPs: ${HOST_SERVICE_IPS[*]}"
  log "Host service TCP allowlist active for ports: ${HOST_SERVICE_PORTS[*]}"
fi
log "Firewall active."
