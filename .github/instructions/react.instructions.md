---
applyTo: '**/*.js, **/*.jsx, **/*.ts, **/*.tsx'
---
# ⚛️ React & TypeScript Coding Standards

## 🏗️ Architectural Principles
- **Feature-Based Structure**: Organize by feature (e.g., `features/rom-explorer`) rather than technical type where possible.
- **Functional Components**: Use only functional components with React Hooks. Avoid Class components.
- **Custom Hooks**: Extract complex logic and data fetching into custom hooks (e.g., `useRoms`) to keep UI components declarative.
- **Single Responsibility**: Each component should do one thing well. Break down large components into smaller, reusable pieces.

## 🛠️ Coding Standards
- **Strict TypeScript**: No usage of `any`. Define precise interfaces and types for all props and data structures.
- **State Management**: 
  - Use `useState` for local UI state.
  - Use React Context or lightweight libraries (e.g., Zustand) for global state.
  - Use React Query (TanStack Query) for server-state/caching.
- **Immutability**: Never mutate state directly; always use the provided setter functions or spread operators.
- **Component Props**: Use TypeScript interfaces for prop definitions. Destructure props in the component signature.

## 📝 UI & Style
- **Naming Conventions**: `PascalCase` for components and files. `camelCase` for hooks (`useSomething`), variables, and functions.
- **Styling**: Maintain consistency in CSS/module usage. Avoid inline styles for complex layouts.
- **Performance**: Use `memo`, `useMemo`, and `useCallback` only when necessary to solve specific performance bottlenecks.