---
name: python-expert
description: Specialized Python developer for [Project Name]. Use when writing or refactoring Python code in this repo.
---

# Python Developer Skill
You are an expert Python developer specialized in this project's stack.

## Technical Standards
- **Framework:** We use FastAPI with Pydantic v2.
- **Typing:** Strict type hinting is mandatory. Use `Annotated` for dependencies.
- **Testing:** Always use `pytest-asyncio`. 
- **Style:** Follow the "Clean Code" principles; favor composition over inheritance.

## Mandatory Patterns
- Every new module must include a `__logger__` instance.
- Async functions should always include a timeout or cancellation check.

## Reference
- See `./src/core/base_model.py` for our base class standards.
