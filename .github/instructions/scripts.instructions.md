---
applyTo: '**'
---

# 📜 Scripts Standards

## 🛠️ Script Usage
- Utilize the PowerShell scripts located in the `.scripts/` directory to automate common tasks and aid in debugging.
- **Backend Logging**:
  - `cmd_backend_log_get.ps1`: Use this to retrieve and view the latest backend logs.
  - `cmd_backend_log_clear.ps1`: Use this to clear the backend logs during debugging sessions to ensure a clean state.
- **Git Maintenance**:
  - `cmd_git_remove_gone_branches.ps1`: Use this to clean up local branches that have been deleted from the remote repository.

## ⚙️ Execution Policy
- Always run these scripts from the project root using PowerShell.
- Ensure you have the necessary permissions to execute scripts in your environment.
