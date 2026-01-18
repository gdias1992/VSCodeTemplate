---
applyTo: '**/*.py'
---
# 🐍 Python & FastAPI Coding Standards

## 🏗️ Architectural Principles
- **Modular Design**: Follow the structure: `api` (routes), `core` (config), `db` (connection), `models` (ORM), `schemas` (Pydantic), and `services` (business logic).
- **Service Layer Pattern**: Keep route handlers thin. All complex logic, database queries, and data processing must reside in the `services/` directory.
- **Dependency Injection**: Utilize FastAPI's `Depends` for managing database sessions and shared services.

## 🛠️ Coding Standards
- **Type Hinting**: Use exhaustive type hints for all function signatures and variable declarations.
- **Asynchronous Programming**: Prefer `async def` for route handlers and service methods that perform I/O operations.
- **Validation**: Use Pydantic models (schemas) for all request bodies and response types. Never return ORM models directly; always use `response_model` with a schema.
- **Error Handling**: Raise `HTTPException` from within the service layer to ensure consistent API error responses.

## 🌐 API & HTTP Standards
- **Status Codes**: Follow standard RESTful HTTP status codes categorized by scenario:

  ### ✅ Success (2xx)
  - `200 OK`: Standard successful response for GET, PUT, or PATCH.
  - `201 Created`: Successful creation (e.g., adding to a personal collection or uploading a custom patch).
  - `202 Accepted`: Request received but processing is long-running (e.g., bulk indexing or archive extraction).
  - `204 No Content`: Successful request where no response body is returned (e.g., DELETE).

  ### 🗄️ Caching (3xx)
  - `304 Not Modified`: Used for static assets (screenshots, patches) when browser cache is still valid.

  ### ❌ Client Errors - Input & Validation (4xx)
  - `400 Bad Request`: Generic client-side error (malformed syntax).
  - `404 Not Found`: The requested ROM, hack, or asset does not exist.
  - `409 Conflict`: Resource already exists or state conflict (e.g., duplicate entry).
  - `413 Payload Too Large`: Uploaded file (patch/image) exceeds server limits.
  - `415 Unsupported Media Type`: Incorrect file format for an upload.
  - `422 Unprocessable Entity`: Semantic/Validation errors (Pydantic/FastAPI default).

  ### 🔐 Client Errors - Auth & Permissions (4xx)
  - `401 Unauthorized`: Authentication required (token missing or invalid).
  - `403 Forbidden`: Authenticated user lacks permission for the specific action.

  ### 💥 Server Errors (5xx)
  - `500 Internal Server Error`: For unhandled exceptions, database crashes, or server logic failures.
  - `503 Service Unavailable`: Server is overloaded or the database is temporarily locked/unavailable.

- **Error Response Structure**: 
  - All error responses must include a `detail` field.
  - Validation errors (422) should follow the FastAPI schema, providing a list of specific field errors.
  - Business logic errors should return a string or object in `detail` that clearly explains why the action failed.
- **Validation**: Use Pydantic's built-in validation. For custom business-level validation (e.g., checking if a file exists in the archive), handle it in the `service` layer and raise appropriate `HTTPException`.

## 📝 Documentation & Style
- **Naming Conventions**: `snake_case` for functions, variables, and file names. `PascalCase` for classes (Models, Schemas).
- **Docstrings**: Use Google-style docstrings for complex logic.
- **Clean Code**: Follow PEP 8 guidelines. Keep functions small and focused on a single responsibility.