# 🐘 Backend Technologies

> Official backend technology stack for the JobHunter application.

---

## 🐘 Core

| Status | Category | Technology | Version | Purpose | Documentation |
|------:|----------|------------|---------|---------|---------------|
| ✅ | Language | PHP | 8.2+ | Server-side scripting language for building robust web applications | https://www.php.net/docs.php |
| ✅ | Framework | Laravel | 12.x | Full-featured PHP framework providing elegant syntax, ORM, routing, and tooling | https://laravel.com/docs |
| ✅ | Web Server | Nginx | Latest | High-performance reverse proxy and web server for serving the application | https://nginx.org/en/docs/ |
| ✅ | Database | PostgreSQL | 18.x | Advanced open-source relational database with strong data integrity | https://www.postgresql.org/docs/ |

---

## 🔐 Authentication & Authorization

| Status | Category | Technology | Version | Purpose | Documentation |
|------:|----------|------------|---------|---------|---------------|
| ✅ | Authentication | Laravel Sanctum | Latest | Lightweight API token authentication for SPAs and mobile apps | https://laravel.com/docs/sanctum |
| ✅ | Authorization | Policies | 12.x | Laravel's built-in policy classes for resource access control | https://laravel.com/docs/authorization |

---

## 🗃️ Data Layer

| Status | Category | Technology | Version | Purpose | Documentation |
|------:|----------|------------|---------|---------|---------------|
| ✅ | ORM | Eloquent | 12.x | Laravel's built-in ActiveRecord ORM for database operations | https://laravel.com/docs/eloquent |
| ✅ | API Resources | Laravel Resources | 12.x | Transform models into JSON responses with consistent structure | https://laravel.com/docs/eloquent-resources |
| ✅ | Validation | Form Requests | 12.x | Dedicated request classes for input validation and authorization | https://laravel.com/docs/validation |

---

## 📐 Standards & Tooling

| Status | Category | Technology | Version | Purpose | Documentation |
|------:|----------|------------|---------|---------|---------------|
| ✅ | Testing | PHPUnit | Latest | Unit and feature testing framework for PHP applications | https://phpunit.de/documentation.html |
| ✅ | Static Analysis | PHPStan / Larastan | Latest | Static analysis tool for finding bugs and enforcing type safety | https://phpstan.org/user-guide/getting-started |
| ✅ | Code Style | Laravel Pint | Latest | Opinionated PHP code style fixer built on PHP-CS-Fixer | https://laravel.com/docs/pint |
| ✅ | Package Manager | Composer | 2.x | Dependency management for PHP packages | https://getcomposer.org/doc/ |
| ✅ | Version Control | Git | N/A | Distributed version control system for collaboration and code history | https://git-scm.com/doc |
| ✅ | Environment Config | .env files | N/A | Backend environment variables (database, secrets, services) | https://laravel.com/docs/configuration |
