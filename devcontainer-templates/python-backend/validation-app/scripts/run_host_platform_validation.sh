#!/bin/bash
set -euo pipefail

iptables -F
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

DNS_IP=$(awk '/^nameserver / {print $2; exit}' /etc/resolv.conf)
HOST_IP=$(getent ahostsv4 host.docker.internal | awk '{print $1; exit}')

iptables -A OUTPUT -d "$DNS_IP" -p udp --dport 53 -j ACCEPT
for port in 5432 6379 9090 3100 3000; do
  iptables -A OUTPUT -d "$HOST_IP" -p tcp --dport "$port" -j ACCEPT
done

su node -s /bin/zsh -c '
  source ~/.zshrc
  cd /workspace
  poetry install
  VALIDATE_HOST_PLATFORM=1 poetry run pytest tests/test_host_platform_access.py -q
'
