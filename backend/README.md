---
title: Sajdah Connect App
emoji: 🕌
colorFrom: yellow
colorTo: gray
sdk: docker
app_port: 7860
pinned: false
license: mit
---

# Sajdah Connect (Backend) 🕌

A high-performance community platform for Masjids, engineered with **FastAPI** and **PostgreSQL**. This project is fully containerized and deployable to **Hugging Face Spaces** with a built-in CI/CD pipeline.

## 🚀 DevOps Core
- **Dockerized**: Ready for any container-orchestrated environment.
- **CI/CD**: Automatic synchronization to Hugging Face Spaces on every push to `main`.
- **Secrets Management**: Local environment variables can be automatically migrated to Hugging Face.

## 📁 Repository Structure
- `/backend`: The core FastAPI application logic and database models.
- `/frontend`: Premium Flutter-based user application.
- `/.github/workflows`: The automated deployment pipeline.

## 🏗️ Local Development
To run the project locally using `uv`:
```bash
# Backend
cd backend
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Frontend
cd frontend
flutter run
```

## 📜 License
This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.
