# 🏗️ Backend Project Structure (C#)

> **Directory-focused guide** for the ASP.NET Core Web API (.NET 8+), emphasizing modularity, scalability, and maintainability.

---

## 🎯 Design Principles

| Principle | Description |
| :--- | :--- |
| **Service Layer** | Keep controllers thin; business logic in services. |
| **Repository Pattern** | All database access through repositories. |
| **Single Responsibility** | Each directory has one clear purpose. |
| **Clear Boundaries** | Separate API, domain, and data layers. |
| **Dependency Injection** | Constructor injection for all dependencies. |
| **Integration Isolation** | External API clients encapsulated per vendor. |

---

## 🗺️ Directory Structure

```text
backend/                                   # ASP.NET Core Web API (.NET 8+)
├── .github/                               # GitHub configuration and workflows
├── docs/                                  # Project documentation
├── src/
│   └── Api/                               # Main API project
│       ├── src/
│       │   ├── Clients/                   # External API clients (HTTP communication)
│       │   │   └── {Vendor}/              # Per-vendor integration (e.g., Unico, Stripe)
│       │   │       ├── Configuration/     # Vendor API settings
│       │   │       ├── I{Vendor}ApiClient.cs
│       │   │       ├── Models/
│       │   │       │   ├── Requests/      # Request models for vendor API
│       │   │       │   └── Responses/     # Response models from vendor API
│       │   │       └── {Vendor}ApiClient.cs
│       │   ├── Configuration/             # Startup configuration classes
│       │   │   ├── BasicAuthConfig.cs
│       │   │   ├── ServicesConfig.cs
│       │   │   └── SwaggerConfig.cs
│       │   ├── Controllers/               # API endpoints (HTTP request handlers)
│       │   │   ├── BaseController.cs
│       │   │   ├── HealthController.cs
│       │   │   └── V1/                    # Versioned API endpoints
│       │   ├── Data/                      # Database access layer
│       │   │   ├── Configurations/        # EF Core entity configurations
│       │   │   ├── Migrations/            # EF Core migrations
│       │   │   ├── AppDbContext.cs        # Database context
│       │   │   └── Repositories/          # Repository implementations
│       │   ├── Enums/                     # Enumeration types
│       │   ├── Extensions/                # Extension methods for existing types
│       │   ├── Filters/                   # Action filters for cross-cutting concerns
│       │   ├── Helpers/                   # Utility classes and constants
│       │   ├── Middleware/                # Custom middleware components
│       │   ├── Models/                    # Data structures and contracts
│       │   │   ├── DTOs/                  # Data Transfer Objects
│       │   │   │   ├── Common/            # Shared/reusable DTOs
│       │   │   │   └── {Feature}/         # Feature-specific DTOs
│       │   │   └── Entities/              # Domain models (database entities)
│       │   └── Services/                  # Business logic layer
│       │       ├── Implementations/       # Service implementations
│       │       └── Interfaces/            # Service contracts
│       ├── appsettings.Development.json
│       ├── appsettings.json               # Base configuration
│       ├── appsettings.Production.json
│       └── Program.cs                     # Application entry point
├── tests/
│   ├── Api.IntegrationTests/              # Integration tests
│   └── Api.UnitTests/                     # Unit tests
├── .editorconfig                          # Code style configuration
├── .gitignore
├── backend.sln                            # Solution file
├── Directory.Build.props                  # Shared MSBuild properties
└── README.md
```

---

## 📁 Directory Reference

| Directory | Purpose |
| :--- | :--- |
| `.github/` | GitHub workflows, issue templates, and CI/CD configuration. |
| `docs/` | Project documentation. |
| `src/` | Source code projects. |
| `tests/` | Test projects (unit and integration). |

### `src/Api/src/Clients/` — External API Clients

| Directory | Purpose |
| :--- | :--- |
| `{Vendor}/` | Per-vendor integration folder (e.g., `Unico/`, `Stripe/`). |
| `{Vendor}/Configuration/` | Vendor-specific settings and options classes. |
| `{Vendor}/Models/Requests/` | Request models for vendor API calls. |
| `{Vendor}/Models/Responses/` | Response models from vendor API. |
| `{Vendor}/I{Vendor}ApiClient.cs` | Interface for vendor API client. |
| `{Vendor}/{Vendor}ApiClient.cs` | Implementation of vendor API client. |

### `src/Api/src/Configuration/` — Startup Configuration

| Purpose |
| :--- |
| Startup configuration classes for auth, services registration, Swagger, etc. |

### `src/Api/src/Controllers/` — API Layer

| Directory | Purpose |
| :--- | :--- |
| `BaseController.cs` | Base controller with shared functionality. |
| `HealthController.cs` | Health check endpoints. |
| `V1/` | Versioned API controllers (thin, delegate to services). |

### `src/Api/src/Data/` — Data Layer

| Directory/File | Purpose |
| :--- | :--- |
| `AppDbContext.cs` | Primary database context. |
| `Configurations/` | EF Core `IEntityTypeConfiguration<T>` classes. |
| `Migrations/` | EF Core database migrations. |
| `Repositories/` | Repository pattern implementations. |

### `src/Api/src/Enums/` — Enumerations

| Purpose |
| :--- |
| Shared enumeration types used across layers. |

### `src/Api/src/Extensions/` — Extension Methods

| Purpose |
| :--- |
| Extension methods for existing types (e.g., `IApplicationBuilder`, enums). |

### `src/Api/src/Filters/` — Filters

| Purpose |
| :--- |
| Action filters, exception filters, and validation filters. |

### `src/Api/src/Helpers/` — Helpers

| Purpose |
| :--- |
| Utility classes, constants, and static helper methods. |

### `src/Api/src/Middleware/` — Middleware

| Purpose |
| :--- |
| Custom middleware (auth, logging, exception handling). |

### `src/Api/src/Models/` — Models

| Directory | Purpose |
| :--- | :--- |
| `DTOs/Common/` | Shared/reusable DTOs (e.g., `ApiResponseDto`, `PagedResultDto`). |
| `DTOs/{Feature}/` | Feature-specific DTOs (e.g., `Greenhouse/CandidateWebhookDto`). |
| `Entities/` | Domain models representing database tables. |

### `src/Api/src/Services/` — Service Layer

| Directory | Purpose |
| :--- | :--- |
| `Implementations/` | Business logic implementations. |
| `Interfaces/` | Service contracts. |

### `tests/` — Test Projects

| Directory | Purpose |
| :--- | :--- |
| `Api.IntegrationTests/` | Integration tests with test database and HTTP client. |
| `Api.UnitTests/` | Unit tests for services, validators, and utilities. |

---

## 📏 Namespace Conventions

ASP.NET Core uses namespace conventions matching folder structure:

```text
Api.Clients.{Vendor}             → src/Api/src/Clients/{Vendor}/
Api.Clients.{Vendor}.Models      → src/Api/src/Clients/{Vendor}/Models/
Api.Configuration                → src/Api/src/Configuration/
Api.Controllers                  → src/Api/src/Controllers/
Api.Controllers.V1               → src/Api/src/Controllers/V1/
Api.Data                         → src/Api/src/Data/
Api.Data.Configurations          → src/Api/src/Data/Configurations/
Api.Data.Repositories            → src/Api/src/Data/Repositories/
Api.Enums                        → src/Api/src/Enums/
Api.Extensions                   → src/Api/src/Extensions/
Api.Filters                      → src/Api/src/Filters/
Api.Helpers                      → src/Api/src/Helpers/
Api.Middleware                   → src/Api/src/Middleware/
Api.Models.DTOs                  → src/Api/src/Models/DTOs/
Api.Models.DTOs.Common           → src/Api/src/Models/DTOs/Common/
Api.Models.Entities              → src/Api/src/Models/Entities/
Api.Services                     → src/Api/src/Services/Implementations/
Api.Services.Interfaces          → src/Api/src/Services/Interfaces/
```

---

## 🔧 Common CLI Commands

| Command | Purpose |
| :--- | :--- |
| `dotnet new webapi -n Api` | Create new Web API project |
| `dotnet build` | Build the solution |
| `dotnet run --project src/Api` | Run the API |
| `dotnet watch --project src/Api` | Run with hot reload |
| `dotnet ef migrations add <Name>` | Add new migration |
| `dotnet ef database update` | Apply migrations |
| `dotnet test` | Run all tests |
| `dotnet format` | Format code according to .editorconfig |

---

## ✅ Summary

### Backend Layers

| Layer | Directories | Scope |
| :--- | :--- | :--- |
| **API** | `Controllers/`, `Filters/`, `Middleware/` | Request handling, cross-cutting concerns |
| **Configuration** | `Configuration/` | Startup and service registration |
| **Clients** | `Clients/{Vendor}/` | External API integrations |
| **Domain** | `Models/Entities/`, `Enums/`, `Services/` | Business logic, entities, enumerations |
| **Data** | `Data/`, `Data/Repositories/` | Data access, EF Core context, migrations |
| **DTOs** | `Models/DTOs/` | Request/response data transfer objects |
| **Utilities** | `Extensions/`, `Helpers/` | Reusable utilities and constants |
| **Testing** | `tests/` | Unit and integration tests |

---

## 📊 Laravel to ASP.NET Core Mapping

| Laravel | ASP.NET Core | Notes |
| :--- | :--- | :--- |
| `app/Http/Controllers/` | `Controllers/` | Thin controllers delegating to services |
| `app/Http/Requests/` | `Models/DTOs/{Feature}/` | Feature-grouped DTOs |
| `app/Http/Resources/` | `Models/DTOs/Common/` | Shared response DTOs |
| `app/Models/` | `Models/Entities/` | Entity classes |
| `app/Services/` | `Services/` | Business logic layer |
| `app/Repositories/` | `Data/Repositories/` | Data access layer |
| `app/Policies/` | `Filters/` or custom auth handlers | Authorization logic |
| `database/migrations/` | `Data/Migrations/` | EF Core migrations |
| `routes/api.php` | Controller attributes | Route attributes on controllers/actions |
| `config/` | `Configuration/` + `appsettings.json` | Configuration classes and files |
| `.env` | `appsettings.*.json` | Environment-specific config |
| N/A | `Clients/{Vendor}/` | External API client integrations |
