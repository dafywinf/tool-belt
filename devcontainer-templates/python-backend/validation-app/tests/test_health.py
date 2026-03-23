"""Tests for the /health endpoint."""

from collections.abc import Generator

import allure
import pytest
from fastapi.testclient import TestClient

from main import app


@pytest.fixture
def client() -> Generator[TestClient, None, None]:
    with TestClient(app) as c:
        yield c


@allure.epic("Validation App")  # pyright: ignore[reportUnknownMemberType]
@allure.feature("Health")  # pyright: ignore[reportUnknownMemberType]
@allure.story("Service liveness")  # pyright: ignore[reportUnknownMemberType]
def test_health_returns_ok(client: TestClient) -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


@allure.epic("Validation App")  # pyright: ignore[reportUnknownMemberType]
@allure.feature("Health")  # pyright: ignore[reportUnknownMemberType]
@allure.story("Service liveness")  # pyright: ignore[reportUnknownMemberType]
def test_health_includes_version(client: TestClient) -> None:
    """Health response must include a non-empty version string."""
    response = client.get("/health")

    assert response.status_code == 200
    body = response.json()
    assert "version" in body
    assert isinstance(body["version"], str)
    assert len(body["version"]) > 0
