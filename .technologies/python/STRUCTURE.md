# 🏗️ Backend Project Structure

> **Directory-focused guide** for the FastAPI backend (Python 3.14), emphasizing modularity, scalability, and maintainability.

---

## 🎯 Design Principles

| Principle | Description |
| :--- | :--- |
| **Service Layer** | Keep route handlers thin; business logic in services. |
| **Repository Pattern** | All database access through repositories. |
| **Dependency Injection** | Use FastAPI's `Depends` for passing services and repositories. |
| **Type Safety** | Exhaustive type hints and Pydantic validation everywhere. |

---

## 🗺️ Directory Structure

```text
├── app/
│   ├── api/                   # API routing layer
│   │   ├── dependencies/      # Reusable FastAPI dependencies
│   │   └── v1/                # Version 1 route handlers
│   │       ├── endpoints/     # Feature-specific routers
│   │       └── router.py      # Central APIRouter for v1 endpoints
│   ├── core/                  # Core application components
│   │   ├── config.py          # Pydantic BaseSettings configurations
│   │   ├── exceptions.py      # Global custom exceptions
│   │   ├── logging.py         # Centralized logging configuration
│   │   └── security.py        # Authentication and hashing utilities
│   ├── db/                    # Database and ORM configuration
│   │   ├── migrations/        # Alembic migration scripts
│   │   ├── models/            # SQLAlchemy ORM models
│   │   └── session.py         # Async database engine and session
│   ├── repositories/          # Data access layer (CRUD operations)
│   ├── schemas/               # Pydantic models (requests, responses)
│   ├── services/              # Business logic layer
│   └── main.py                # FastAPI application instance and entry point
├── logs/                      # Log files (git-ignored, per LOGGING.md)
│   └── app.log                # Primary application log file
├── tests/                     # Test suite
│   ├── conftest.py            # Pytest fixtures
│   ├── api/                   # API endpoint tests
│   ├── repositories/          # Repository layer tests
│   └── services/              # Service layer tests
├── pyproject.toml             # Project dependencies and configs
├── alembic.ini                # Alembic configuration file
└── .env                       # Environment variables (git-ignored)
```

---

## 📁 Directory Reference

| Directory | Purpose |
| :--- | :--- |
| `app/` | Core application code. |
| `app/api/` | Route handlers, grouped by API version and domain. |
| `app/api/dependencies/` | Reusable dependencies injected via `Depends` (e.g., current user, db session). |
| `app/core/` | Application-wide settings, security logic, logging config, and exception handling. |
| `app/db/` | Database setup, SQLAlchemy models, and Alembic migrations. |
| `app/repositories/` | Data access layer isolating SQLAlchemy logic from services. |
| `app/schemas/` | Pydantic models for incoming requests and outgoing responses. |
| `app/services/` | Core business logic that integrates repositories and APIs. |
| `logs/` | Storage for application and access logs (git-ignored). |
| `tests/` | Pytest-based automated tests covering various layers. |

---

## ✅ Summary

### Backend Layers

| Layer | Directories | Scope |
| :--- | :--- | :--- |
| **Routing** | `api/v1/endpoints/` | Route definitions, path parameters, request/response mapping |
| **HTTP/Auth**| `api/dependencies/`, `core/security.py` | API dependencies, JWT, password hashing |
| **Validation** | `schemas/` | Validating input payloads and shaping outputs with Pydantic |
| **Domain** | `services/`, `core/exceptions.py` | Business logic, permissions, domain-specific errors |
| **Data** | `repositories/` | Execution of database queries bridging services and models |
| **Database** | `db/models/`, `db/migrations/` | SQLAlchemy models mapping tables, Alembic schemas |
| **Entry Point**| `main.py`, `core/config.py` | FastAPI app creation, middleware setup, config loading |
