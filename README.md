# 🚀 VSCodeTemplate

A template repository for bootstrapping new projects in VS Code with standardized documentation, AI coding assistant instructions, and best practices baked in.

---

## 📋 Overview

This template provides a consistent starting point for new projects, including:

- **Standardized Documentation** — Pre-configured markdown files for project structure, technologies, logging, and roadmaps.
- **AI Assistant Guidelines** — Instruction files in `.github/instructions/` to guide AI coding assistants (like GitHub Copilot) with project-specific rules and conventions.
- **Best Practices** — Git workflow standards, commit conventions, and code quality guidelines.

---

## 🛠️ Getting Started

### 1. Create Your Project

Clone or use this template to create a new repository.

### 2. Configure AI Instructions

Add technology-specific instruction files to `.github/instructions/`:

```text
.github/instructions/
├── git.instructions.md        # Git & workflow standards (included)
├── project.instructions.md    # Project guidelines (included)
├── python.instructions.md     # Python-specific rules
├── react.instructions.md      # React/TypeScript rules
└── <your-tech>.instructions.md
```

### 3. Define Project Documentation

Update the following files to reflect your project:

| File | Purpose |
| :--- | :--- |
| [STRUCTURE.md](STRUCTURE.md) | Repository map and architectural patterns |
| [TECHNOLOGIES.md](TECHNOLOGIES.md) | Tech stack specification with versions |
| [ROADMAP.md](ROADMAP.md) | Development milestones and tasks |

### 4. Configure Start Script

Update the execution logic in [.scripts/cmd_run.ps1](.scripts/cmd_run.ps1) to define how your project should be started (e.g., launching docker containers, starting dev servers).

### 5. Start Building

Execute your roadmap and build your project with consistent documentation and AI-assisted development.

---

## 📁 Template Contents

```text
VSCodeTemplate/
├── .github/
│   └── instructions/          # AI assistant instruction files
│       ├── git.instructions.md
│       └── project.instructions.md
├── .scripts/                  # Automation and utility scripts
│   └── cmd_run.ps1            # Main entry point for starting the project
├── backend/                   # Backend placeholder
├── frontend/                  # Frontend placeholder
├── LOGGING.md                 # Logging standards template
├── README.md                  # This file
├── ROADMAP.md                 # Development roadmap template
├── ROADMAP_TASK_TEMPLATE.md   # Task template for roadmap items
├── STRUCTURE.md               # Project structure template
└── TECHNOLOGIES.md            # Tech stack template
```

---

## 📚 Documentation

- [STRUCTURE.md](STRUCTURE.md) — Project architecture and directory layout
- [TECHNOLOGIES.md](TECHNOLOGIES.md) — Detailed tech stack specification
- [LOGGING.md](LOGGING.md) — Logging implementation guidelines
- [ROADMAP.md](ROADMAP.md) — Development milestones and progress tracking

---

## 📄 License

This template is provided as-is for personal and commercial use.