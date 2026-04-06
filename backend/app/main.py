from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import firebase_admin
from firebase_admin import credentials

from app.core.config import settings
from app.api.v1 import auth, masjid, reels, super_admin, notifications

def init_firebase():
    if not firebase_admin._apps:
        try:
            # Clean and parse the private key string
            key = settings.FIREBASE_PRIVATE_KEY
            parsed_key = key.strip('"').replace("\\n", "\n").replace('\\n', '\n')
            
            cred_dict = {
                "type": settings.FIREBASE_TYPE,
                "project_id": settings.FIREBASE_PROJECT_ID,
                "private_key_id": settings.FIREBASE_PRIVATE_KEY_ID,
                "private_key": parsed_key,
                "client_email": settings.FIREBASE_CLIENT_EMAIL,
                "client_id": settings.FIREBASE_CLIENT_ID,
                "auth_uri": settings.FIREBASE_AUTH_URI,
                "token_uri": settings.FIREBASE_TOKEN_URI,
                "auth_provider_x509_cert_url": settings.FIREBASE_AUTH_PROVIDER_CERT_URL,
                "client_x509_cert_url": settings.FIREBASE_CLIENT_CERT_URL,
            }
            cred = credentials.Certificate(cred_dict)
            firebase_admin.initialize_app(cred)
            print("INFO: Firebase Admin SDK initialized successfully.")
        except Exception as e:
            print(f"ERROR: Firebase initialization failed: {e}")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Initialize Firebase
    init_firebase()
    yield
    # Shutdown logic (if any)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan,
)

# Set up CORS
if settings.CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

from app.api.v1 import auth, masjid, reels, super_admin, notifications, prayers

# Include Routers
app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["auth"])
app.include_router(masjid.router, prefix=f"{settings.API_V1_STR}/masjids", tags=["masjids"])
app.include_router(reels.router, prefix=f"{settings.API_V1_STR}/reels", tags=["reels"])
app.include_router(super_admin.router, prefix=f"{settings.API_V1_STR}/super-admin", tags=["super-admin"])
app.include_router(notifications.router, prefix=f"{settings.API_V1_STR}/notifications", tags=["notifications"])
app.include_router(prayers.router, prefix=f"{settings.API_V1_STR}/prayers", tags=["prayers"])

@app.get("/")
async def root():
    return {"message": "Welcome to Masjid Connect Pro API"}
