"""Validation tests for host platform services exposed through the Docker host gateway."""

from __future__ import annotations

import os
import socket
import subprocess

import httpx
import pytest


def _docker_host() -> str:
    env_host = os.getenv("PLATFORM_HOST")
    if env_host:
        return env_host

    try:
        socket.gethostbyname("host.docker.internal")
        return "host.docker.internal"
    except OSError:
        pass

    gateway = subprocess.check_output(
        ["sh", "-c", "ip route | awk '/default/ {print $3; exit}'"],
        text=True,
    ).strip()
    if not gateway:
        raise RuntimeError("Could not determine Docker host gateway")
    return gateway


def _require_host_platform() -> str:
    if os.getenv("VALIDATE_HOST_PLATFORM") != "1":
        pytest.skip("Set VALIDATE_HOST_PLATFORM=1 and start the host docker compose stack")
    return _docker_host()


@pytest.mark.host_platform
@pytest.mark.parametrize("port", [5432, 6379, 9090, 3100, 3000])
def test_host_platform_tcp_ports_are_reachable(port: int) -> None:
    host = _require_host_platform()
    with socket.create_connection((host, port), timeout=3):
        pass


@pytest.mark.host_platform
@pytest.mark.parametrize(
    ("path", "expected_status"),
    [
        ("/-/ready", 200),      # Prometheus
        ("/ready", 200),        # Loki
        ("/api/health", 200),   # Grafana
    ],
)
def test_host_platform_http_health_endpoints(path: str, expected_status: int) -> None:
    host = _require_host_platform()
    port = {"/-/ready": 9090, "/ready": 3100, "/api/health": 3000}[path]
    response = httpx.get(f"http://{host}:{port}{path}", timeout=3.0)
    assert response.status_code == expected_status
