# 🏗️ Frontend Project Structure

> **Directory-focused guide** for the React frontend application (Vite + TypeScript), emphasizing modularity, scalability, and maintainability.

---

## 🎯 Design Principles

| Principle | Description |
| :--- | :--- |
| **Feature-First** | Organize by feature/domain, not by file type. |
| **Colocation** | Keep tests, styles, and types alongside related code. |
| **Flat Structure** | Avoid deep nesting; favor discoverability. |
| **Clear Boundaries** | Separate shared code from feature-specific code. |
| **Single Responsibility** | Each directory has one clear purpose. |

---

## 🗺️ Directory Structure

```text
frontend/                      # React SPA (Vite + TypeScript)
├── public/                    # Static assets served at root (favicon, manifest)
└── src/                       # Application source code
    ├── app/                   # Application shell and global setup
    │   ├── providers/         # React Context providers (Auth, Theme, Query)
    │   └── routes/            # Route definitions and lazy-loading config
    ├── assets/                # Static assets processed by bundler
    │   ├── fonts/             # Custom font files (WOFF, WOFF2)
    │   ├── icons/             # SVG icons and sprites
    │   └── images/            # Raster images and illustrations
    ├── components/            # Shared, reusable UI components
    │   ├── common/            # Composed components (DataTable, Pagination)
    │   ├── layout/            # Structural pieces (Header, Sidebar, Footer)
    │   └── ui/                # Atomic primitives (Button, Input, Modal)
    ├── config/                # App configuration and environment
    ├── features/              # Feature-based modules (domain logic)
    │   └── [feature]/         # Self-contained feature slice
    │       ├── api/           # Feature API calls and queries
    │       ├── components/    # Feature-specific UI components
    │       ├── hooks/         # Feature-specific React hooks
    │       ├── types/         # Feature TypeScript types
    │       └── utils/         # Feature helper functions
    ├── hooks/                 # Shared custom React hooks
    ├── layouts/               # Page wrappers (AuthLayout, DashboardLayout)
    ├── lib/                   # Third-party library wrappers and config
    ├── pages/                 # Route entry points (thin composition layers)
    │   └── [page]/            # Page components organized by route
    ├── services/              # API layer and external integrations
    │   └── api/               # HTTP client, interceptors, endpoints
    ├── stores/                # Global state management (Zustand)
    ├── styles/                # Global styles and theming
    ├── types/                 # Shared TypeScript types and interfaces
    └── utils/                 # Pure utility functions and constants
```

---

## 📁 Directory Reference

| Directory | Purpose |
| :--- | :--- |
| `public/` | Static assets served at root URL, not processed by bundler. |
| `src/` | All frontend application source code. |

### `src/app/` — Application Shell

| Directory | Purpose |
| :--- | :--- |
| `providers/` | Context providers wrapping the app (Auth, Theme, QueryClient). |
| `routes/` | Route definitions, guards, and lazy-loading configuration. |

### `src/pages/` — Route Entry Points

Thin composition layers that assemble features for each route. Pages contain no business logic.

| Convention | Description |
| :--- | :--- |
| `HomePage.tsx` | Route-level component for `/` |
| `LoginPage.tsx` | Route-level component for `/login` |
| `dashboard/DashboardPage.tsx` | Nested route for `/dashboard` |

> Pages import from `features/`, `components/`, and `layouts/`. They compose UI but delegate logic to features.

### `src/layouts/` — Page Wrappers

Structural wrappers that define where content slots into the page.

| Layout | Purpose |
| :--- | :--- |
| `AuthLayout.tsx` | Wrapper for login/register pages (centered card, no nav). |
| `DashboardLayout.tsx` | Wrapper for authenticated pages (sidebar, header, main content). |
| `PublicLayout.tsx` | Wrapper for public pages (navbar, footer). |

> Layouts handle structural concerns only. No data fetching or business logic.

### `src/features/` — Feature Modules

Self-contained vertical slices of domain logic. Each feature follows this structure:

| Directory | Purpose |
| :--- | :--- |
| `api/` | API calls and TanStack Query hooks. |
| `components/` | UI components exclusive to this feature. |
| `hooks/` | React hooks scoped to this feature. |
| `types/` | TypeScript types for this feature. |
| `utils/` | Helper functions for this feature. |

> **Import Rules:**
> - `pages/` imports from `features/`, `components/`, `layouts/`
> - `features/` imports from `components/`, `hooks/`, `lib/`, `services/`, `types/`, `utils/`
> - `features/` never imports from other `features/` (use stores or routing)
> - `components/` never imports from `features/` or `pages/`
> - `layouts/` imports from `components/` only

### `src/components/` — Shared UI

| Directory | Purpose |
| :--- | :--- |
| `common/` | Composed components (DataTable, Pagination, SearchBar). |
| `layout/` | Structural pieces (Header, Sidebar, Footer, Navbar). |
| `ui/` | Atomic primitives (Button, Input, Modal, Card). |

### `src/` — Shared Directories

| Directory | Purpose |
| :--- | :--- |
| `config/` | Environment variables, feature flags, API URLs. |
| `hooks/` | Shared React hooks (useDebounce, useLocalStorage, useMediaQuery). |
| `lib/` | Third-party library wrappers (Axios, QueryClient, Analytics). |
| `services/api/` | HTTP client, interceptors, endpoint constants. |
| `stores/` | Global state (Zustand) for auth, UI, app-wide state. |
| `types/` | Shared TypeScript types (API wrappers, utility types). |
| `utils/` | Pure utilities (formatters, validators, constants). |

### `src/assets/` — Static Assets

| Directory | Purpose |
| :--- | :--- |
| `fonts/` | Custom font files. |
| `icons/` | SVG icons and sprites. |
| `images/` | Raster images and illustrations. |

### `src/styles/` — Global Styles

CSS reset, design tokens, Tailwind directives, and global animations.

---

## 📏 Path Aliases (TypeScript)

Use path aliases to simplify imports and avoid relative path complexity:

```text
@/          → src/
@assets     → src/assets/
@components → src/components/
@config     → src/config/
@features   → src/features/
@hooks      → src/hooks/
@layouts    → src/layouts/
@lib        → src/lib/
@pages      → src/pages/
@services   → src/services/
@stores     → src/stores/
@types      → src/types/
@utils      → src/utils/
```

---

## ✅ Summary

### Frontend Layers

| Layer | Directories | Scope |
| :--- | :--- | :--- |
| **Assets** | `assets/`, `public/`, `styles/` | Static files, styling, theming |
| **Features** | `features/[name]/` | Domain-specific, self-contained modules |
| **Infrastructure** | `lib/`, `services/`, `stores/` | External integrations, API layer, global state |
| **Layouts** | `layouts/` | Page structure wrappers (AuthLayout, DashboardLayout) |
| **Pages** | `pages/` | Route entry points, thin composition layers |
| **Shared UI** | `components/common/`, `components/layout/`, `components/ui/` | Reusable, feature-agnostic components |
| **Shell** | `app/`, `config/` | Bootstrap, routing, providers, configuration |
| **Utilities** | `hooks/`, `types/`, `utils/` | Shared logic, helpers, type definitions |
