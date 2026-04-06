# Sajdah Connect App (GitHub) 🕌

This is the main repository for the **Sajdah Connect** application, containing both the backend and frontend code.

## 📁 Repository Structure
- `/backend`: FastAPI backend application. (Auto-synced to [Hugging Face Spaces](https://huggingface.co/spaces/dameerahmed/sajdah-connect-backend))
- `/frontend`: Premium Flutter-based user application.

## 🚀 Deployment Isolation
The backend is automatically isolated and pushed to Hugging Face Spaces on every commit to `main` using a `git subtree` pipeline.

## 🏗️ Local Development

### Backend
```bash
cd backend
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Frontend
```bash
cd frontend
flutter run
```

## 📜 License
This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.
