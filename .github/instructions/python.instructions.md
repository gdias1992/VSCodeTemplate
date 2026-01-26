---
applyTo: '**/*.py'
---
# 🐍 Clean Python & FastAPI — Best Practices & Standards

> Guidelines for writing clean, maintainable, and production-ready FastAPI applications.

---

## 🎯 Core Principles

| Principle | Description |
| :--- | :--- |
| **Service Layer** | Keep route handlers thin. Business logic lives in `services/`. |
| **Repository Pattern** | All database access goes through `repositories/`. Services never interact with SQLAlchemy directly. |
| **Dependency Injection** | Use FastAPI's `Depends` for services, repositories, and database sessions. |
| **Type Safety** | Use exhaustive type hints on all function signatures and variables. |
| **Pydantic Schemas** | Validate all input/output using Pydantic models. Never return ORM models directly. |
| **Async First** | Prefer `async def` for all I/O-bound operations. |
| **KISS** | Keep It Simple, Stupid. Favor simplicity over cleverness. |
| **DRY** | Don't Repeat Yourself. Extract reusable logic. |
| **SRP** | Single Responsibility. One component, one job. |
| **Explicit > Implicit** | Code should be obvious, not clever. |

---

## 🏷️ Naming Conventions

| Type | Convention | Example |
| :--- | :--- | :--- |
| Modules/Files | snake_case | `user_service.py`, `job_repository.py` |
| Classes | PascalCase | `UserService`, `JobRepository` |
| Functions/Methods | snake_case | `get_user_by_id`, `create_access_token` |
| Variables | snake_case | `current_user`, `job_listing` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_PAGE_SIZE`, `DEFAULT_TIMEOUT` |
| Schemas (Request) | PascalCase + Create/Update | `UserCreate`, `JobUpdate` |
| Schemas (Response) | PascalCase + Response/Out | `UserResponse`, `JobOut` |
| Routes | kebab-case | `/api/v1/user-profile` |

---

## 🏗️ Route Handler Patterns

### Keep Handlers Thin

```python
# ❌ Too much logic in route handler
@router.post("/users", status_code=201)
async def create_user(user_data: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == user_data.email).first()
    if existing:
        raise HTTPException(status_code=409, detail="Email already registered")
    
    hashed = bcrypt.hash(user_data.password)
    user = User(email=user_data.email, password=hashed)
    db.add(user)
    db.commit()
    db.refresh(user)
    
    send_welcome_email(user.email)
    
    return user


# ✅ Delegate to service layer
@router.post("/users", response_model=UserResponse, status_code=201)
async def create_user(
    user_data: UserCreate,
    user_service: UserService = Depends(get_user_service),
) -> UserResponse:
    user = await user_service.create(user_data)
    return UserResponse.model_validate(user)
```

### Use Dependency Injection

```python
# ✅ Constructor-style injection via Depends
class UserService:
    def __init__(
        self,
        user_repository: UserRepository,
        email_service: EmailService,
    ) -> None:
        self._user_repository = user_repository
        self._email_service = email_service


def get_user_service(
    user_repository: UserRepository = Depends(get_user_repository),
    email_service: EmailService = Depends(get_email_service),
) -> UserService:
    return UserService(user_repository, email_service)


# ✅ Usage in route handler
@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    user_service: UserService = Depends(get_user_service),
) -> UserResponse:
    user = await user_service.get_by_id(user_id)
    return UserResponse.model_validate(user)
```

---

## 📦 Repository Pattern

### Repository Interface & Implementation

```python
# ✅ Define repository protocol (interface)
from typing import Protocol


class UserRepositoryProtocol(Protocol):
    async def find_by_id(self, user_id: int) -> User | None: ...
    async def find_by_email(self, email: str) -> User | None: ...
    async def create(self, data: dict) -> User: ...
    async def update(self, user: User, data: dict) -> User: ...
    async def delete(self, user: User) -> bool: ...
    async def paginate(self, skip: int, limit: int) -> list[User]: ...


# ✅ Implement repository
class UserRepository:
    def __init__(self, db: AsyncSession) -> None:
        self._db = db

    async def find_by_id(self, user_id: int) -> User | None:
        result = await self._db.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()

    async def find_by_email(self, email: str) -> User | None:
        result = await self._db.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()

    async def create(self, data: dict) -> User:
        user = User(**data)
        self._db.add(user)
        await self._db.commit()
        await self._db.refresh(user)
        return user

    async def update(self, user: User, data: dict) -> User:
        for key, value in data.items():
            setattr(user, key, value)
        await self._db.commit()
        await self._db.refresh(user)
        return user

    async def delete(self, user: User) -> bool:
        await self._db.delete(user)
        await self._db.commit()
        return True

    async def paginate(self, skip: int = 0, limit: int = 20) -> list[User]:
        result = await self._db.execute(
            select(User).offset(skip).limit(limit)
        )
        return list(result.scalars().all())
```

### Services Use Repositories

```python
# ❌ Service accessing SQLAlchemy directly
class UserService:
    def __init__(self, db: AsyncSession) -> None:
        self._db = db

    async def create(self, data: UserCreate) -> User:
        user = User(**data.model_dump())  # Direct ORM access
        self._db.add(user)
        await self._db.commit()
        return user


# ✅ Service delegates to repository
class UserService:
    def __init__(self, user_repository: UserRepository) -> None:
        self._user_repository = user_repository

    async def create(self, data: UserCreate) -> User:
        existing = await self._user_repository.find_by_email(data.email)
        if existing:
            raise DuplicateEmailError(data.email)

        return await self._user_repository.create({
            "email": data.email,
            "password": hash_password(data.password),
            "full_name": data.full_name,
        })

    async def get_by_id(self, user_id: int) -> User:
        user = await self._user_repository.find_by_id(user_id)
        if not user:
            raise UserNotFoundError(user_id)
        return user
```

### Dependency Provider Pattern

```python
# ✅ Repository dependency provider
async def get_user_repository(
    db: AsyncSession = Depends(get_async_session),
) -> UserRepository:
    return UserRepository(db)


async def get_job_repository(
    db: AsyncSession = Depends(get_async_session),
) -> JobRepository:
    return JobRepository(db)
```

---

## 📋 Pydantic Schema Validation

### Request & Response Schemas

```python
from pydantic import BaseModel, EmailStr, Field, ConfigDict


# ✅ Request schemas (input validation)
class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)
    full_name: str | None = Field(None, max_length=255)


class UserUpdate(BaseModel):
    email: EmailStr | None = None
    full_name: str | None = Field(None, max_length=255)


# ✅ Response schemas (output transformation)
class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: str
    full_name: str | None
    created_at: datetime
    
    # Nested relationships
    profile: "ProfileResponse | None" = None


class UserListResponse(BaseModel):
    data: list[UserResponse]
    total: int
    page: int
    per_page: int
    total_pages: int
```

### Custom Validators

```python
from pydantic import field_validator, model_validator


class JobCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=255)
    salary_min: int | None = Field(None, ge=0)
    salary_max: int | None = Field(None, ge=0)

    @field_validator("title")
    @classmethod
    def title_must_not_be_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Title cannot be empty or whitespace")
        return v.strip()

    @model_validator(mode="after")
    def validate_salary_range(self) -> "JobCreate":
        if self.salary_min and self.salary_max:
            if self.salary_min > self.salary_max:
                raise ValueError("salary_min cannot exceed salary_max")
        return self
```

---

## 🌐 Global API Standards

### URL Structure

| Pattern | Description | Example |
| :--- | :--- | :--- |
| `/api/v1/{resource}` | Resource collection | `/api/v1/users` |
| `/api/v1/{resource}/{id}` | Single resource | `/api/v1/users/123` |
| `/api/v1/{resource}/{id}/{sub}` | Nested resource | `/api/v1/users/123/applications` |
| `/api/v1/{resource}/{id}/actions/{action}` | Custom actions | `/api/v1/jobs/123/actions/apply` |

### Router Organization

```python
# app/api/v1/router.py
from fastapi import APIRouter

from app.api.v1.endpoints import auth, health, jobs, users

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(health.router, tags=["Health"])
api_router.include_router(auth.router, prefix="/auth", tags=["Auth"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(jobs.router, prefix="/jobs", tags=["Jobs"])
```

### HTTP Methods

| Method | Action | Response |
| :--- | :--- | :--- |
| `GET` | Read resource(s) | 200 with data |
| `POST` | Create resource | 201 with created resource |
| `PUT` | Full update | 200 with updated resource |
| `PATCH` | Partial update | 200 with updated resource |
| `DELETE` | Remove resource | 204 No Content |

### Pagination Pattern

```python
# ✅ Pagination schema
class PaginationParams(BaseModel):
    page: int = Field(1, ge=1)
    per_page: int = Field(20, ge=1, le=100)

    @property
    def skip(self) -> int:
        return (self.page - 1) * self.per_page


# ✅ Paginated response
class PaginatedResponse(BaseModel, Generic[T]):
    data: list[T]
    total: int
    page: int
    per_page: int
    total_pages: int


# ✅ Repository pagination
class JobRepository:
    async def get_paginated(
        self,
        filters: JobFilters,
        pagination: PaginationParams,
    ) -> tuple[list[Job], int]:
        query = select(Job)

        if filters.status:
            query = query.where(Job.status == filters.status)
        if filters.search:
            query = query.where(Job.title.ilike(f"%{filters.search}%"))

        # Get total count
        count_result = await self._db.execute(
            select(func.count()).select_from(query.subquery())
        )
        total = count_result.scalar() or 0

        # Apply sorting and pagination
        query = query.order_by(
            getattr(Job, filters.sort_by).desc()
            if filters.sort_order == "desc"
            else getattr(Job, filters.sort_by).asc()
        )
        query = query.offset(pagination.skip).limit(pagination.per_page)

        result = await self._db.execute(query)
        return list(result.scalars().all()), total


# ✅ Service builds paginated response
class JobService:
    async def get_paginated(
        self,
        filters: JobFilters,
        pagination: PaginationParams,
    ) -> PaginatedResponse[JobResponse]:
        jobs, total = await self._job_repository.get_paginated(filters, pagination)
        total_pages = (total + pagination.per_page - 1) // pagination.per_page

        return PaginatedResponse(
            data=[JobResponse.model_validate(job) for job in jobs],
            total=total,
            page=pagination.page,
            per_page=pagination.per_page,
            total_pages=total_pages,
        )
```

### Filtering & Sorting

```python
# ✅ Filter schema with defaults
class JobFilters(BaseModel):
    status: Literal["draft", "active", "closed"] | None = None
    search: str | None = Field(None, min_length=2, max_length=100)
    sort_by: Literal["created_at", "title", "salary"] = "created_at"
    sort_order: Literal["asc", "desc"] = "desc"


# ✅ Route with query params
@router.get("/", response_model=PaginatedResponse[JobResponse])
async def list_jobs(
    filters: Annotated[JobFilters, Query()],
    pagination: Annotated[PaginationParams, Query()],
    job_service: JobService = Depends(get_job_service),
) -> PaginatedResponse[JobResponse]:
    return await job_service.get_paginated(filters, pagination)
```

---

## 📊 HTTP Status Codes

### ✅ Success (2xx)

| Code | When to Use |
| :--- | :--- |
| `200 OK` | Successful GET, PUT, PATCH |
| `201 Created` | Successful POST creating a resource |
| `202 Accepted` | Request accepted for async processing |
| `204 No Content` | Successful DELETE |

### 🗄️ Caching (3xx)

| Code | When to Use |
| :--- | :--- |
| `304 Not Modified` | Static assets with valid cache |

### ⚠️ Client Errors (4xx)

| Code | When to Use |
| :--- | :--- |
| `400 Bad Request` | Malformed request syntax |
| `401 Unauthorized` | Missing or invalid authentication |
| `403 Forbidden` | Authenticated but not authorized |
| `404 Not Found` | Resource does not exist |
| `409 Conflict` | Duplicate or state conflict |
| `413 Payload Too Large` | Upload exceeds limits |
| `415 Unsupported Media Type` | Invalid file format |
| `422 Unprocessable Entity` | Validation errors (FastAPI default) |

### 💥 Server Errors (5xx)

| Code | When to Use |
| :--- | :--- |
| `500 Internal Server Error` | Unhandled exceptions |
| `503 Service Unavailable` | Database or service down |

---

## 🚨 Error Handling

### Custom Exception Classes

```python
# ✅ Base application exception
class AppException(Exception):
    def __init__(
        self,
        message: str,
        code: str,
        status_code: int = 400,
        details: dict | None = None,
    ) -> None:
        self.message = message
        self.code = code
        self.status_code = status_code
        self.details = details or {}
        super().__init__(message)


# ✅ Domain-specific exceptions
class UserNotFoundError(AppException):
    def __init__(self, user_id: int) -> None:
        super().__init__(
            message=f"User with id {user_id} not found",
            code="USER_NOT_FOUND",
            status_code=404,
        )


class DuplicateEmailError(AppException):
    def __init__(self, email: str) -> None:
        super().__init__(
            message="Email already registered",
            code="DUPLICATE_EMAIL",
            status_code=409,
            details={"email": email},
        )


class InsufficientPermissionsError(AppException):
    def __init__(self, action: str) -> None:
        super().__init__(
            message=f"Not authorized to {action}",
            code="FORBIDDEN",
            status_code=403,
        )
```

### Global Exception Handler

```python
# ✅ Register in main.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse


def create_app() -> FastAPI:
    app = FastAPI()

    @app.exception_handler(AppException)
    async def app_exception_handler(
        request: Request,
        exc: AppException,
    ) -> JSONResponse:
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "detail": exc.message,
                "code": exc.code,
                **exc.details,
            },
        )

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(
        request: Request,
        exc: Exception,
    ) -> JSONResponse:
        # Log the error
        logger.exception("Unhandled exception")
        return JSONResponse(
            status_code=500,
            content={
                "detail": "Internal server error",
                "code": "INTERNAL_ERROR",
            },
        )

    return app
```

### Service Layer Exception Handling

```python
# ✅ Throw exceptions from services
class UserService:
    def __init__(self, user_repository: UserRepository) -> None:
        self._user_repository = user_repository

    async def get_by_id(self, user_id: int) -> User:
        user = await self._user_repository.find_by_id(user_id)
        if not user:
            raise UserNotFoundError(user_id)
        return user

    async def create(self, data: UserCreate) -> User:
        existing = await self._user_repository.find_by_email(data.email)
        if existing:
            raise DuplicateEmailError(data.email)

        return await self._user_repository.create({
            "email": data.email,
            "password": hash_password(data.password),
            "full_name": data.full_name,
        })

    async def update(self, user_id: int, data: UserUpdate) -> User:
        user = await self.get_by_id(user_id)

        if data.email and data.email != user.email:
            existing = await self._user_repository.find_by_email(data.email)
            if existing:
                raise DuplicateEmailError(data.email)

        return await self._user_repository.update(
            user,
            data.model_dump(exclude_unset=True),
        )
```

---

## 🔒 Security Patterns

### JWT Authentication

```python
# ✅ Auth service
from datetime import datetime, timedelta
from jose import JWTError, jwt


class AuthService:
    def __init__(
        self,
        user_repository: UserRepository,
        settings: Settings,
    ) -> None:
        self._user_repository = user_repository
        self._settings = settings

    async def authenticate(self, email: str, password: str) -> str:
        user = await self._user_repository.find_by_email(email)
        if not user or not verify_password(password, user.password):
            raise InvalidCredentialsError()

        return self._create_access_token(user.id)

    def _create_access_token(self, user_id: int) -> str:
        expires = datetime.utcnow() + timedelta(
            minutes=self._settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
        payload = {
            "sub": str(user_id),
            "exp": expires,
            "iat": datetime.utcnow(),
        }
        return jwt.encode(
            payload,
            self._settings.SECRET_KEY,
            algorithm=self._settings.ALGORITHM,
        )

    def decode_token(self, token: str) -> int:
        try:
            payload = jwt.decode(
                token,
                self._settings.SECRET_KEY,
                algorithms=[self._settings.ALGORITHM],
            )
            user_id = int(payload["sub"])
            return user_id
        except JWTError:
            raise InvalidTokenError()
```

### Current User Dependency

```python
# ✅ Get current authenticated user
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    auth_service: AuthService = Depends(get_auth_service),
    user_service: UserService = Depends(get_user_service),
) -> User:
    user_id = auth_service.decode_token(credentials.credentials)
    return await user_service.get_by_id(user_id)


# ✅ Usage in protected routes
@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
) -> UserResponse:
    return UserResponse.model_validate(current_user)
```

### Role-Based Access Control

```python
# ✅ Role checker dependency
class RoleChecker:
    def __init__(self, allowed_roles: list[str]) -> None:
        self.allowed_roles = allowed_roles

    def __call__(self, user: User = Depends(get_current_user)) -> User:
        if user.role not in self.allowed_roles:
            raise InsufficientPermissionsError("access this resource")
        return user


# ✅ Usage
allow_admin = RoleChecker(["admin"])
allow_moderator = RoleChecker(["admin", "moderator"])


@router.delete("/{user_id}", status_code=204)
async def delete_user(
    user_id: int,
    current_user: User = Depends(allow_admin),
    user_service: UserService = Depends(get_user_service),
) -> None:
    await user_service.delete(user_id)
```

### Resource Ownership Authorization

```python
# ✅ Check resource ownership
async def get_job_with_auth(
    job_id: int,
    current_user: User = Depends(get_current_user),
    job_service: JobService = Depends(get_job_service),
) -> Job:
    job = await job_service.get_by_id(job_id)
    if job.user_id != current_user.id and current_user.role != "admin":
        raise InsufficientPermissionsError("modify this job")
    return job


@router.put("/{job_id}", response_model=JobResponse)
async def update_job(
    job_data: JobUpdate,
    job: Job = Depends(get_job_with_auth),
    job_service: JobService = Depends(get_job_service),
) -> JobResponse:
    updated = await job_service.update(job, job_data)
    return JobResponse.model_validate(updated)
```

---

## 🧪 Testing Patterns

### Test Structure with pytest

```python
# ✅ Arrange-Act-Assert pattern
import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_can_create_user(client: AsyncClient, db_session: AsyncSession) -> None:
    # Arrange
    user_data = {
        "email": "test@example.com",
        "password": "securepass123",
        "full_name": "Test User",
    }

    # Act
    response = await client.post("/api/v1/users", json=user_data)

    # Assert
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert data["full_name"] == "Test User"
    assert "password" not in data
    assert "id" in data


@pytest.mark.asyncio
async def test_cannot_create_user_with_duplicate_email(
    client: AsyncClient,
    user_factory: UserFactory,
) -> None:
    # Arrange
    existing = await user_factory.create(email="existing@example.com")

    # Act
    response = await client.post("/api/v1/users", json={
        "email": "existing@example.com",
        "password": "password123",
    })

    # Assert
    assert response.status_code == 409
    assert response.json()["code"] == "DUPLICATE_EMAIL"
```

### Test Fixtures

```python
# ✅ conftest.py
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine

from app.main import create_app
from app.db.session import get_async_session


@pytest.fixture
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSession(engine) as session:
        yield session


@pytest.fixture
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    app = create_app()

    async def override_get_session() -> AsyncSession:
        return db_session

    app.dependency_overrides[get_async_session] = override_get_session

    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac


@pytest.fixture
def user_factory(db_session: AsyncSession) -> UserFactory:
    return UserFactory(db_session)
```

### Factory Pattern for Tests

```python
# ✅ Test factories
from faker import Faker

fake = Faker()


class UserFactory:
    def __init__(self, db: AsyncSession) -> None:
        self._db = db

    async def create(
        self,
        email: str | None = None,
        password: str = "password123",
        role: str = "user",
        **kwargs,
    ) -> User:
        user = User(
            email=email or fake.email(),
            password=hash_password(password),
            role=role,
            full_name=kwargs.get("full_name", fake.name()),
        )
        self._db.add(user)
        await self._db.commit()
        await self._db.refresh(user)
        return user

    async def create_admin(self, **kwargs) -> User:
        return await self.create(role="admin", **kwargs)
```

### Authenticated Test Requests

```python
# ✅ Helper for authenticated requests
@pytest.fixture
async def auth_headers(
    client: AsyncClient,
    user_factory: UserFactory,
) -> dict[str, str]:
    user = await user_factory.create(email="test@example.com", password="password123")
    response = await client.post("/api/v1/auth/login", json={
        "email": "test@example.com",
        "password": "password123",
    })
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.mark.asyncio
async def test_authenticated_user_can_view_profile(
    client: AsyncClient,
    auth_headers: dict[str, str],
) -> None:
    response = await client.get("/api/v1/users/me", headers=auth_headers)
    assert response.status_code == 200
    assert response.json()["email"] == "test@example.com"
```

---

## 🚫 Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad |
| :--- | :--- |
| Business logic in route handlers | Hard to test, violates SRP |
| Services accessing ORM directly | Couples business logic to database, harder to test |
| Returning ORM models from routes | Exposes internal structure, couples API to DB |
| Missing type hints | Reduces IDE support and static analysis effectiveness |
| Sync I/O in async handlers | Blocks the event loop, kills performance |
| Hardcoded configuration | Not portable, breaks across environments |
| Catching bare `Exception` | Hides bugs, makes debugging difficult |
| N+1 queries | Kills performance, use eager loading |
| Mutable default arguments | Leads to unexpected behavior |
| Global state / singletons | Hard to test, creates hidden dependencies |

---

## 📝 Documentation & Style

### Docstrings (Google Style)

```python
async def create_user(self, data: UserCreate) -> User:
    """Create a new user in the database.

    Args:
        data: Validated user creation data containing email and password.

    Returns:
        The newly created User instance.

    Raises:
        DuplicateEmailError: If a user with the given email already exists.
    """
    existing = await self._user_repository.find_by_email(data.email)
    if existing:
        raise DuplicateEmailError(data.email)
    return await self._user_repository.create(data.model_dump())
```

### OpenAPI Documentation

```python
from fastapi import APIRouter, status

router = APIRouter()


@router.post(
    "/",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new user",
    description="Register a new user with email and password.",
    responses={
        201: {"description": "User created successfully"},
        409: {"description": "Email already registered"},
        422: {"description": "Validation error"},
    },
)
async def create_user(
    user_data: UserCreate,
    user_service: UserService = Depends(get_user_service),
) -> UserResponse:
    """Create a new user account.

    - **email**: Valid email address (must be unique)
    - **password**: Minimum 8 characters
    - **full_name**: Optional display name
    """
    user = await user_service.create(user_data)
    return UserResponse.model_validate(user)
```

### Code Formatting & Linting

```toml
# pyproject.toml
[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # pyflakes
    "I",      # isort
    "B",      # flake8-bugbear
    "C4",     # flake8-comprehensions
    "UP",     # pyupgrade
    "ARG",    # flake8-unused-arguments
    "SIM",    # flake8-simplify
]

[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_ignores = true
```

---

## 📂 Folder Structure

See [STRUCTURE_BACKEND.md](../../STRUCTURE_BACKEND.md) for full details.

---

## ✅ Quick Checklist

- [ ] Route handlers delegate to service layer
- [ ] Services delegate database access to repositories
- [ ] Repository dependencies injected via `Depends`
- [ ] All routes have `response_model` with Pydantic schema
- [ ] Pydantic schemas for all input validation
- [ ] Type hints on all function signatures
- [ ] `async def` for all I/O-bound operations
- [ ] Custom exceptions for business logic errors
- [ ] Global exception handler registered
- [ ] Proper HTTP status codes used
- [ ] Error responses include `detail` field
- [ ] JWT authentication with `HTTPBearer`
- [ ] Role-based access control where needed
- [ ] Tests cover happy path and error cases
- [ ] API versioning implemented (`/api/v1/`)
- [ ] Eager loading used to prevent N+1 queries
- [ ] No ORM models returned from routes
- [ ] Code formatted with ruff/black
- [ ] Type-checked with mypy