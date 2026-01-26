# 🔷 Backend Technologies (C#)

> Official backend technology stack for C# API development.

---

## 🔷 Core

| Status | Category | Technology | Version | Purpose | Documentation |
|------:|----------|------------|---------|---------|---------------|
| ✅ | Language | C# | 12+ | Modern, type-safe language for building robust applications | https://learn.microsoft.com/en-us/dotnet/csharp/ |
| ✅ | Framework | ASP.NET Core | 8.x | High-performance, cross-platform framework for building web APIs | https://learn.microsoft.com/en-us/aspnet/core/ |
| ✅ | Runtime | .NET | 8.x | Cross-platform runtime with LTS support | https://learn.microsoft.com/en-us/dotnet/ |
| ✅ | Web Server | Kestrel | 8.x | High-performance, cross-platform web server built into ASP.NET Core | https://learn.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel |
| ✅ | Database | PostgreSQL | 18.x | Advanced open-source relational database with strong data integrity | https://www.postgresql.org/docs/ |

---

## 🔐 Authentication & Authorization

| Status | Category | Technology | Version | Purpose | Documentation |
|------:|----------|------------|---------|---------|---------------|
| ✅ | Authentication | JWT Bearer | 8.x | Token-based authentication for SPAs and mobile apps | https://learn.microsoft.com/en-us/aspnet/core/security/authentication/ |
| ✅ | Identity | ASP.NET Core Identity | 8.x | Membership system for user management, passwords, roles | https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity |
| ✅ | Authorization | Policy-Based Auth | 8.x | Flexible authorization using policies and requirements | https://learn.microsoft.com/en-us/aspnet/core/security/authorization/policies |

---

## 🗃️ Data Layer

| Status | Category | Technology | Version | Purpose | Documentation |
|------:|----------|------------|---------|---------|---------------|
| ✅ | ORM | Entity Framework Core | 8.x | Modern ORM with LINQ support for database operations | https://learn.microsoft.com/en-us/ef/core/ |
| ✅ | DB Provider | Npgsql.EntityFrameworkCore | 8.x | PostgreSQL provider for Entity Framework Core | https://www.npgsql.org/efcore/ |
| ✅ | Migrations | EF Core Migrations | 8.x | Code-first database schema management | https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/ |
| ✅ | Validation | FluentValidation | 11.x | Strongly-typed validation rules with clean syntax | https://docs.fluentvalidation.net/ |
| ✅ | Mapping | AutoMapper | 13.x | Object-to-object mapping for DTOs and entities | https://automapper.org/ |

---

## 📡 API & Communication

| Status | Category | Technology | Version | Purpose | Documentation |
|------:|----------|------------|---------|---------|---------------|
| ✅ | API Docs | Swagger/OpenAPI | Latest | Interactive API documentation and testing | https://learn.microsoft.com/en-us/aspnet/core/tutorials/web-api-help-pages-using-swagger |
| ✅ | Serialization | System.Text.Json | 8.x | High-performance JSON serialization | https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/ |
| ✅ | HTTP Client | HttpClientFactory | 8.x | Managed HTTP client instances with resilience patterns | https://learn.microsoft.com/en-us/dotnet/core/extensions/httpclient-factory |

---

## 📐 Standards & Tooling

| Status | Category | Technology | Version | Purpose | Documentation |
|------:|----------|------------|---------|---------|---------------|
| ✅ | Testing | xUnit | Latest | Modern testing framework for .NET | https://xunit.net/ |
| ✅ | Mocking | Moq | Latest | Mocking library for unit tests | https://github.com/moq/moq4 |
| ✅ | Testing | FluentAssertions | Latest | Readable assertion syntax for tests | https://fluentassertions.com/ |
| ✅ | Logging | Serilog | Latest | Structured logging with rich sinks support | https://serilog.net/ |
| ✅ | Code Analysis | .NET Analyzers | 8.x | Built-in static analysis and code quality rules | https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/ |
| ✅ | Formatting | CSharpier | Latest | Opinionated code formatter for C# | https://csharpier.com/ |
| ✅ | Code Style | EditorConfig | N/A | Consistent coding style across editors and IDEs | https://editorconfig.org/ |
| ✅ | Package Manager | NuGet | Latest | Dependency management for .NET packages | https://learn.microsoft.com/en-us/nuget/ |
| ✅ | Version Control | Git | N/A | Distributed version control system | https://git-scm.com/doc |
| ✅ | Environment Config | appsettings.json | N/A | Configuration files with environment-specific overrides | https://learn.microsoft.com/en-us/aspnet/core/fundamentals/configuration/ |
| ✅ | Secrets | User Secrets | 8.x | Development-time secret storage | https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets |

---

## 🔧 Development Tools

| Status | Category | Technology | Version | Purpose | Documentation |
|------:|----------|------------|---------|---------|---------------|
| ✅ | IDE | Visual Studio / VS Code | Latest | Full-featured IDE with debugging and IntelliSense | https://visualstudio.microsoft.com/ |
| ✅ | CLI | .NET CLI | 8.x | Command-line interface for building and running apps | https://learn.microsoft.com/en-us/dotnet/core/tools/ |
| ✅ | Hot Reload | dotnet watch | 8.x | Live reload during development | https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-watch |
| ✅ | Containerization | Docker | Latest | Containerized development and deployment | https://docs.docker.com/ |
