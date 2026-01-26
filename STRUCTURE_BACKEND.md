# 🏗️ Backend Project Structure

> **Directory-focused guide** for the Laravel backend API (PHP 8+), emphasizing modularity, scalability, and maintainability.

---

## 🎯 Design Principles

| Principle | Description |
| :--- | :--- |
| **Service Layer** | Keep controllers thin; business logic in services. |
| **Repository Pattern** | All database access through repositories. |
| **Single Responsibility** | Each directory has one clear purpose. |
| **Clear Boundaries** | Separate HTTP, domain, and data layers. |

---

## 🗺️ Directory Structure

```text
backend/                       # Laravel API (PHP 8+)
├── app/
│   ├── Console/
│   │   └── Commands/          # Artisan console commands
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       └── V1/        # Versioned API controllers
│   │   ├── Requests/          # Form Request validation classes
│   │   └── Resources/         # API Resource transformers
│   ├── Models/                # Eloquent models
│   ├── Policies/              # Authorization policies
│   ├── Providers/             # Service providers
│   ├── Repositories/          # Data access layer
│   └── Services/              # Business logic layer
├── bootstrap/                 # Framework bootstrap and cache
│   └── cache/                 # Cached framework files
├── config/                    # Configuration files
├── database/
│   ├── factories/             # Model factories for testing
│   ├── migrations/            # Database migrations
│   └── seeders/               # Database seeders
├── public/                    # Web server entry point
│   └── index.php              # Application entry point
├── resources/                 # Views and raw assets
│   ├── css/                   # CSS stylesheets
│   ├── js/                    # JavaScript files
│   └── views/                 # Blade templates (if needed)
├── routes/
│   ├── api.php                # API route definitions
│   ├── console.php            # Console command routes
│   └── web.php                # Web route definitions
├── scripts/                   # Utility scripts
├── storage/
│   ├── app/                   # Application-generated files
│   ├── framework/             # Framework cache, sessions, views
│   └── logs/                  # Log files (git-ignored)
└── tests/
    ├── Feature/               # Feature/integration tests
    └── Unit/                  # Unit tests
```

---

## 📁 Directory Reference

| Directory | Purpose |
| :--- | :--- |
| `app/` | Core application code (Laravel). |
| `bootstrap/` | Framework bootstrap files and cache. |
| `config/` | Configuration files for services, database, auth, etc. |
| `database/` | Migrations, seeders, and model factories. |
| `public/` | Web server entry point and compiled assets. |
| `resources/` | Views, CSS, JS, and raw assets. |
| `routes/` | API, web, and console route definitions. |
| `scripts/` | Utility scripts for development and deployment. |
| `storage/` | App files, framework cache, sessions, and logs. |
| `tests/` | Feature and unit tests. |

### `app/Console/` — Console Layer

| Directory | Purpose |
| :--- | :--- |
| `Commands/` | Custom Artisan console commands. |

### `app/Http/` — HTTP Layer

| Directory | Purpose |
| :--- | :--- |
| `Controllers/Api/V1/` | Versioned API controllers (thin, delegate to services). |
| `Requests/` | Form Request validation classes. |
| `Resources/` | API Resource transformers for response formatting. |

### `app/` — Core Directories

| Directory | Purpose |
| :--- | :--- |
| `Models/` | Eloquent ORM models. |
| `Policies/` | Authorization policies for resource access control. |
| `Providers/` | Service providers for dependency injection. |
| `Repositories/` | Data access layer (all database queries). |
| `Services/` | Business logic layer (core application logic). |

### `database/` — Database Layer

| Directory | Purpose |
| :--- | :--- |
| `migrations/` | Database schema migrations. |
| `seeders/` | Database seeders for test/dev data. |
| `factories/` | Model factories for testing. |

### `bootstrap/` — Framework Bootstrap

| Directory | Purpose |
| :--- | :--- |
| `cache/` | Cached framework files (routes, services, packages). |

### `public/` — Web Entry Point

| File/Directory | Purpose |
| :--- | :--- |
| `index.php` | Application entry point for all HTTP requests. |

### `resources/` — Views & Raw Assets

| Directory | Purpose |
| :--- | :--- |
| `css/` | CSS stylesheets. |
| `js/` | JavaScript files. |
| `views/` | Blade templates (if server-side rendering is needed). |

### `routes/` — Route Definitions

| File | Purpose |
| :--- | :--- |
| `api.php` | API route definitions. |
| `console.php` | Artisan console command routes. |
| `web.php` | Web route definitions. |

### `scripts/` — Utility Scripts

| Purpose |
| :--- |
| Development and deployment utility scripts. |

### `storage/` — Generated Files

| Directory | Purpose |
| :--- | :--- |
| `app/` | Application-generated files (uploads, exports). |
| `framework/` | Framework cache, sessions, compiled views. |
| `logs/` | Application log files (git-ignored). |

---

## 📏 Path Aliases (PHP/Composer)

Laravel uses PSR-4 autoloading with the `App\` namespace:

```text
App\Console\Commands\  → app/Console/Commands/
App\Http\Controllers\  → app/Http/Controllers/
App\Http\Requests\     → app/Http/Requests/
App\Http\Resources\    → app/Http/Resources/
App\Models\            → app/Models/
App\Policies\          → app/Policies/
App\Providers\         → app/Providers/
App\Repositories\      → app/Repositories/
App\Services\          → app/Services/
```

---

## ✅ Summary

### Backend Layers

| Layer | Directories | Scope |
| :--- | :--- | :--- |
| **Console** | `Console/Commands/` | Artisan console commands |
| **HTTP** | `Http/Controllers/`, `Requests/`, `Resources/` | Request handling, validation, response formatting |
| **Domain** | `Models/`, `Services/`, `Policies/` | Business logic, data models, authorization |
| **Data** | `Repositories/`, `database/` | Data access, migrations, seeders |
| **Infrastructure** | `Providers/`, `config/` | Dependency injection, configuration |
| **Web** | `public/`, `resources/`, `bootstrap/` | Entry point, views, framework bootstrap |
| **Storage** | `storage/` | Generated files, logs |
