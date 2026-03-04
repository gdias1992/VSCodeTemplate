# 🤖 AI Agent Instructions (AGENTS.md)

This file provides system instructions and necessary context to AI agents (like GitHub Copilot, Cline, or Windsurf) working within this repository.
The goal is to ensure consistent, high-quality contributions that align with project standards and conventions.

## 🏢 Project Context
*   **Project Name:** QuantAI - Engineering & Floor Plans
*   **Purpose:** A React frontend application for floor plan management with automatic material takeoff and counting.
*   **Key Technologies:** React 19+, TypeScript 5.x, Vite, Tailwind CSS 4.x, React Router 7.x, TanStack Query 5.x, Shadcn UI.
*   **Architecture:** Feature-first feature-sliced React frontend (`src/features/*`), colocation of related files, and separation of UI components (`src/components/ui/*`) from domain logic. See full structure in `STRUCTURE.md`.

## 📚 Core Documentation
To fully grasp the setup, architecture, and design, refer to the following critical files:
*   [**README.md**](README.md): High-level project description, tech stack overview, and setup procedures.
*   [**STRUCTURE.md**](STRUCTURE.md): Frontend directory structure and architectural feature-first patterns.
*   [**DESIGN.md**](DESIGN.md): Minimalist mobile-first design system with color palettes, typography, spacing, and responsive breakpoints.
*   [**TECHNOLOGIES.md**](TECHNOLOGIES.md): Detailed specification of all major libraries, frameworks, and tools used.
*   *Maintenance Policy*: Any core project document must be updated whenever changes occur in the project's scope, architecture, or tools.

## 📜 Standard Operating Procedures (SOPs)
All specialized rules are stored in the `.github/instructions/` directory. AI agents **must** adhere strictly to them:
*   [**React & Coding Standards**](.github/instructions/react.instructions.md): KISS, DRY, SRP, Component Design, Hooks, TanStack Query, and Sonner/Laravel-422 Error Handling.
*   [**Testing & Validation**](.github/instructions/agent.instructions.md): Mandatory Playwright MCP visual/functional testing before completing any task.
*   [**Git & Workflow Standards**](.github/instructions/git.instructions.md): Conventional Commits, PR policy, Branching strategy. (Agents must *suggest* commit messages, but never commit or push directly).
*   [**Scripts**](.github/instructions/scripts.instructions.md): Usage of the `.scripts/` directory for automation.

## 🛠️ General Instructions
*   **TypeScript:** Use strict TypeScript. Avoid `any` unles absolutely necessary. Use interfaces/types.
*   **UI Components:** Use Shadcn UI (`src/components/ui/`) and Tailwind CSS for styling. Use Lucide React for icons.
*   **Forms & Validation:** Use `react-hook-form` paired with `zod` for handling forms and validation.
*   **Command Line Tooling:** 
    *   Use `npm` for package management (e.g. `npm run dev`, `npm install`). 
    *   Avoid dangerous terminal commands like `rm -rf`. 
*   **State & Network:** Use TanStack Query for remote state. Keep local state as close to where it's used as possible.

## ✅ Task Validation
Before concluding any implementation task:
1.  Run the development server locally (`npm run dev`).
2.  Use tools (like `mcp_microsoft_pla_browser` / Playwright) to validate that the UI functions and renders without errors.
3.  Check the browser console output and development terminal for errors or warnings.
