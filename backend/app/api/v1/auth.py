from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from firebase_admin import auth as firebase_auth
from google.oauth2 import id_token as google_id_token
from google.auth.transport import requests as google_requests
from datetime import timedelta

from app.db.session import get_db
from app.models.user import User, UserRole
from app.core.config import settings
from app.core.security import create_access_token, get_password_hash, verify_password
from pydantic import BaseModel, EmailStr
from typing import Optional

router = APIRouter()

class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: int
    role: str

class UserSignup(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    maslak: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class GoogleLoginRequest(BaseModel):
    id_token: str
    maslak: Optional[str] = None

@router.post("/signup", response_model=Token)
async def signup(payload: UserSignup, db: AsyncSession = Depends(get_db)):
    # Check if user exists
    result = await db.execute(select(User).where(User.email == payload.email))
    if result.scalars().first():
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Create user
    new_user = User(
        email=payload.email,
        full_name=payload.full_name,
        hashed_password=get_password_hash(payload.password),
        maslak=payload.maslak,
        role=UserRole.USER
    )
    
    # Assign super admin role if in list
    if payload.email in settings.super_admin_list:
        new_user.role = UserRole.SUPER_ADMIN
        
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    
    access_token = create_access_token(subject=new_user.id)
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": new_user.id,
        "role": new_user.role
    }

@router.post("/login", response_model=Token)
async def login(payload: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == payload.email))
    user = result.scalars().first()
    
    if not user or not user.hashed_password or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Incorrect email or password")
    
    access_token = create_access_token(subject=user.id)
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": user.id,
        "role": user.role
    }

@router.post("/google-login", response_model=Token)
async def google_login(payload: GoogleLoginRequest, db: AsyncSession = Depends(get_db)):
    try:
        decoded_token = None

        # First try Firebase token verification.
        try:
            decoded_token = firebase_auth.verify_id_token(payload.id_token)
        except Exception:
            decoded_token = None

        # Fallback to direct Google OAuth ID token verification.
        if decoded_token is None:
            decoded_token = google_id_token.verify_oauth2_token(
                payload.id_token,
                google_requests.Request(),
                settings.GOOGLE_CLIENT_ID,
            )

        email = decoded_token.get("email")
        full_name = decoded_token.get("name")
        
        if not email:
            raise HTTPException(status_code=400, detail="Invalid token: no email found")
            
        # Check if user exists
        result = await db.execute(select(User).where(User.email == email))
        user = result.scalars().first()
        
        if not user:
            # Auto-create user
            user = User(
                email=email,
                full_name=full_name,
                maslak=payload.maslak,
                role=UserRole.USER
            )
            if email in settings.super_admin_list:
                user.role = UserRole.SUPER_ADMIN
            db.add(user)
            await db.commit()
            await db.refresh(user)
            
        access_token = create_access_token(subject=user.id)
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user_id": user.id,
            "role": user.role
        }
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Google authentication failed: {str(e)}")

from app.api.deps import get_current_active_user

@router.get("/me", response_model=User)
async def get_current_user(current_user: User = Depends(get_current_active_user)):
    """
    Get current logged in user details.
    """
    return current_user
