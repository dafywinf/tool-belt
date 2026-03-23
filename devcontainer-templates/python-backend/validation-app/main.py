from fastapi import FastAPI

app = FastAPI(title="Validation App", version="0.1.0")


@app.get("/health")
def health_check() -> dict[str, str]:
    """Return service liveness status and API version."""
    return {"status": "ok", "version": app.version}
