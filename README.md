# 🚀 VSCodeTemplate

A template repository for bootstrapping new projects in VS Code with standardized documentation, AI coding assistant instructions, and best practices baked in.

---

## 🛠️ Getting Started

### 1. Create Your Project

Clone or use this template to create a new repository.

### 2. Configure AI Instructions

Add technology-specific instruction files to `.github/instructions/`. Ensure you **add** missing ones, **edit** existing ones to match your project, and **remove** any files for technologies you are not using.

#### ⚙️ Customizing Instruction Scope
Each file in `.github/instructions/` can use frontmatter to define its scope and target audience.

- **`applyTo`**: Use glob patterns to specify which files these instructions apply to.
  - `*`: All files in the current directory.
  - `**` or `**/*`: All files in all directories.
  - `*.py`: All `.py` files in the current directory.
  - `**/*.py`: All `.py` files in all directories (recursive).
  - `src/*.py`: All `.py` files in the `src` directory (non-recursive).
  - `src/**/*.py`: All `.py` files in the `src` directory (recursive).
  - `**/subdir/**/*.py`: All `.py` files in any `subdir` directory at any depth.
- **`excludeAgent`**: Specify which Copilot feature should ignore these instructions. Use either `"coding-agent"` or `"code-review"`.

Example frontmatter:
```markdown
---
applyTo: "**/*.ts,**/*.tsx"
excludeAgent: "code-review"
---
```

#### 📂 Current Sample List
The following instruction sets are provided as baseline templates:
```text
.github/instructions/
├── agent.instructions.md      # Testing and validation standards
├── git.instructions.md        # Git workflow and commit standards
├── php.instructions.md        # PHP/Laravel specific guidelines
├── project.instructions.md    # Repository structure and core docs
├── python.instructions.md     # Python/FastAPI specific guidelines
├── react.instructions.md      # React/TypeScript coding standards
└── <your-tech>.instructions.md
```

### 3. Define Project Documentation

Update the core project documents mentioned in [.github/instructions/project.instructions.md](.github/instructions/project.instructions.md) to reflect your project's specific architecture and stack.

| File | Purpose |
| :--- | :--- |
| [ROADMAP.md](ROADMAP.md) | Development milestones and tasks |
| [DATABASE.md](DATABASE.md) | Database schema and migrations |
| [STRUCTURE_FRONTEND.md](STRUCTURE_FRONTEND.md) | Frontend directory structure |
| [STRUCTURE_BACKEND.md](STRUCTURE_BACKEND.md) | Backend directory structure |
| [TECHNOLOGIES_FRONTEND.md](TECHNOLOGIES_FRONTEND.md) | Frontend tech stack spec |
| [TECHNOLOGIES_BACKEND.md](TECHNOLOGIES_BACKEND.md) | Backend tech stack spec |

