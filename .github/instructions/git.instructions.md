---
applyTo: '**'
---

# 🌿 Git & Workflow Standards

## 📝 Commit Message Guidelines
We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for all commit messages. This ensures a clean, readable history and automates changelog generation.

### Format: `<type>(<scope>): <description>`

- **Types**:
  - `feat`: A new feature for the user.
  - `fix`: A bug fix for the user.
  - `docs`: Documentation changes.
  - `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc).
  - `refactor`: A code change that neither fixes a bug nor adds a feature.
  - `perf`: A code change that improves performance.
  - `test`: Adding missing tests or correcting existing tests.
  - `chore`: Changes to the build process or auxiliary tools and libraries.
  - `ci`: Changes to CI configuration files and scripts.
- **Scope**: (Optional) The module or feature being changed (e.g., `backend`, `frontend`, `auth`, `rom-explorer`).
- **Description**: A short, imperative-style summary of the change.

### Example:
- `feat(backend): add async search endpoint`
- `fix(frontend): resolve memory leak in ROM list`
- `docs: update setup instructions in README`

## 🌿 Branching Strategy
- **Main Branch**: `main` is protected and should always be in a deployable state.
- **Feature Branches**: Create descriptive branches from `main`. Use the format: `feature/<feature-name>` or `fix/<issue-description>`.
- **Merging**: Prefer **Squash and Merge** on GitHub to keep the `main` history clean and linear.

## 🤝 Pull Request (PR) Policy
- **Self-Review**: Before opening a PR, review your own changes to catch obvious errors, console logs, or commented-out code.
- **Description**: Provide a clear summary of changes, motivation, and any testing performed.
- **Focus**: Keep PRs small and focused on a single task. Avoid "scope creep" where unrelated changes are bundled together.

## 🧹 Repository Hygiene
- **Large Files**: Never commit raw ROMs, large datasets, or the contents of the `.romhacking/` directory.
- **Environment Variables**: Never commit `.env` files. Ensure sensitive data is managed via environment-specific configurations.
- **Git Ignore**: Maintain `backend/.gitignore` and `frontend/.gitignore` to keep environment-specific artifacts (like `node_modules`, `.venv`, `__pycache__`) out of the repository.
- **Formatting**: Ensure code is linted and formatted according to project standards (`black`/`ruff` for Python, `eslint` for React) before committing.
