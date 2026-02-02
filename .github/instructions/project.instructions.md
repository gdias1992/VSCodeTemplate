---
applyTo: '**'
---

# 📜 Project Guidelines

This repository follows a strict organizational structure to ensure scalability and ease of use in a local environment.

## 📚 General Standards
- **Maintenance Policy**: Any core project document (README, STRUCTURE, DATABASE, TECHNOLOGIES, TECHNOLOGIES) must be updated whenever changes occur in the project's scope, architecture, or tools. Always ensure `DATABASE.md` reflects current migrations. Keep `backend.postman_collection.json` updated when API endpoints are added, modified, or removed.

## 📝 Core Documentation
- **README.md**: High-level project description, tech stack overview, and setup procedures. Reference: [README.md](../../README.md)
- **STRUCTURE_FRONTEND.md**: Frontend directory structure and architectural patterns. Reference: [STRUCTURE_FRONTEND.md](../../STRUCTURE_FRONTEND.md)
- **STRUCTURE_BACKEND.md**: Backend directory structure and architectural patterns. Reference: [STRUCTURE_BACKEND.md](../../STRUCTURE_BACKEND.md)
- **DATABASE.md**: Database diagram and schema documentation. Reference: [DATABASE.md](../../DATABASE.md)
- **FRONTEND_DESIGN.md**: Minimalist mobile-first design system with color palettes, typography, spacing, and responsive breakpoints. Reference: [FRONTEND_DESIGN.md](../../FRONTEND_DESIGN.md)
- **TECHNOLOGIES_FRONTEND.md**: Detailed specification of all major libraries, frameworks, and tools used. Reference: [TECHNOLOGIES_FRONTEND.md](../../TECHNOLOGIES_FRONTEND.md)
- **TECHNOLOGIES_BACKEND.md**: Detailed specification of all major libraries, frameworks, and tools used. Reference: [TECHNOLOGIES_BACKEND.md](../../TECHNOLOGIES_BACKEND.md)
- **LOGGING.md**: Logging architecture and standards for backend and frontend. Reference: [LOGGING.md](../../LOGGING.md)

## 📡 API Documentation
- **Postman Collection**: A comprehensive Postman collection for the JobHunter API is maintained at [backend.postman_collection.json](../../backend.postman_collection.json).
  - **Import**: Drag and drop the file into Postman or use the Import button.
  - **Variables**: The collection uses `{{baseUrl}}` (defaults to `http://localhost`) and `{{token}}` for authentication.
