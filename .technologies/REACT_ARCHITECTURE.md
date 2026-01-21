# 🏗️ React Project Structure (V2)

> **Directory-focused guide** for a production-grade React application emphasizing modularity, scalability, and maintainability.

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
frontend/
├── public/                    # Static assets served at root (favicon, manifest)
├── src/                       # Application source code
│   ├── app/                   # Application shell and global setup
│   │   ├── providers/         # React Context providers (Auth, Theme, Query)
│   │   └── routes/            # Route definitions and lazy-loading config
│   ├── features/              # Feature-based modules (domain logic)
│   │   └── [feature-name]/    # Self-contained feature slice
│   │       ├── components/    # Feature-specific UI components
│   │       ├── hooks/         # Feature-specific React hooks
│   │       ├── api/           # Feature API calls and queries
│   │       ├── types/         # Feature TypeScript types
│   │       └── utils/         # Feature helper functions
│   ├── components/            # Shared, reusable UI components
│   │   ├── ui/                # Atomic primitives (Button, Input, Modal)
│   │   ├── layout/            # Page structure (Header, Sidebar, Footer)
│   │   └── common/            # Composed components (DataTable, Pagination)
│   ├── hooks/                 # Shared custom React hooks
│   ├── lib/                   # Third-party library wrappers and config
│   ├── services/              # API layer and external integrations
│   │   └── api/               # HTTP client, interceptors, endpoints
│   ├── stores/                # Global state management (Zustand, Redux)
│   ├── types/                 # Shared TypeScript types and interfaces
│   ├── utils/                 # Pure utility functions and constants
│   ├── assets/                # Static assets processed by bundler
│   │   ├── images/            # Raster images and illustrations
│   │   ├── icons/             # SVG icons and sprites
│   │   └── fonts/             # Custom font files (WOFF, WOFF2)
│   ├── styles/                # Global styles and theming
│   └── config/                # App configuration and environment
```

---

## 📁 Directory Reference

| Directory | Purpose |
| :--- | :--- |
| `public/` | Static assets served at root URL, not processed by bundler. |
| `src/` | All application source code. |

### `src/app/` — Application Shell

| Directory | Purpose |
| :--- | :--- |
| `providers/` | Context providers wrapping the app (Auth, Theme, QueryClient). |
| `routes/` | Route definitions, guards, and lazy-loading configuration. |

### `src/features/` — Feature Modules

Self-contained vertical slices of domain logic. Each feature follows this structure:

| Directory | Purpose |
| :--- | :--- |
| `components/` | UI components exclusive to this feature. |
| `hooks/` | React hooks scoped to this feature. |
| `api/` | API calls and TanStack Query hooks. |
| `types/` | TypeScript types for this feature. |
| `utils/` | Helper functions for this feature. |

> Features import from shared directories but never from other features. Cross-feature communication uses stores or routing.

### `src/components/` — Shared UI

| Directory | Purpose |
| :--- | :--- |
| `ui/` | Atomic primitives (Button, Input, Modal, Card). |
| `layout/` | Page structure (Header, Sidebar, Footer). |
| `common/` | Composed components (DataTable, Pagination, SearchBar). |

### `src/` — Shared Directories

| Directory | Purpose |
| :--- | :--- |
| `hooks/` | Shared React hooks (useDebounce, useLocalStorage, useMediaQuery). |
| `lib/` | Third-party library wrappers (Axios, QueryClient, Analytics). |
| `services/api/` | HTTP client, interceptors, endpoint constants. |
| `stores/` | Global state (Zustand/Redux) for auth, UI, app-wide state. |
| `types/` | Shared TypeScript types (API wrappers, utility types). |
| `utils/` | Pure utilities (formatters, validators, constants). |
| `config/` | Environment variables, feature flags, API URLs. |

### `src/assets/` — Static Assets

| Directory | Purpose |
| :--- | :--- |
| `images/` | Raster images and illustrations. |
| `icons/` | SVG icons and sprites. |
| `fonts/` | Custom font files. |

### `src/styles/` — Global Styles

CSS reset, design tokens, Tailwind directives, and global animations.

---

## 📏 Path Aliases

Use path aliases to simplify imports and avoid relative path complexity:

```text
@/          → src/
@components → src/components/
@features   → src/features/
@hooks      → src/hooks/
@lib        → src/lib/
@services   → src/services/
@stores     → src/stores/
@types      → src/types/
@utils      → src/utils/
@assets     → src/assets/
@config     → src/config/
```

---

## ✅ Summary

| Layer | Directories | Scope |
| :--- | :--- | :--- |
| **Shell** | `app/`, `config/` | Bootstrap, routing, providers, configuration |
| **Features** | `features/[name]/` | Domain-specific, self-contained modules |
| **Shared UI** | `components/ui/`, `layout/`, `common/` | Reusable, feature-agnostic components |
| **Infrastructure** | `lib/`, `services/`, `stores/` | External integrations, API layer, global state |
| **Utilities** | `hooks/`, `utils/`, `types/` | Shared logic, helpers, type definitions |
| **Assets** | `assets/`, `styles/`, `public/` | Static files, styling, theming |
