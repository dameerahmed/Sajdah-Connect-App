from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import func
from sqlmodel import select
from app.db.session import get_db
from app.models.reel import Reel
from app.models.masjid import Masjid
from app.models.user import User
from app.api.deps import get_current_user
from typing import List, Optional
import cloudinary
import cloudinary.uploader
import os

router = APIRouter()

# Configure Cloudinary
cloudinary.config(
  cloud_name = "dmw13a0ft",
  api_key = "117496616145929",
  api_secret = "G6_B-OKGk3KE6i0Va2_fOPC0iDg",
  secure = True
)

from app.models.interactions import Follow

@router.get("/", response_model=List[Reel])
async def get_all_reels(
    filter: str = Query("ALL"), # ALL, FOLLOWING, MASLAK
    maslak: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user)
):
    query = select(Reel)
    
    if filter == "FOLLOWING" and current_user:
        # Join with Follow table to get only followed masjids' reels
        query = query.join(Follow, Reel.masjid_id == Follow.masjid_id).where(Follow.user_id == current_user.id)
    elif filter == "MASLAK" and maslak:
        # Join with Masjid table to filter by sect
        query = query.join(Masjid).where(Masjid.maslak == maslak)
    
    # Randomization for Discover feel
    query = query.order_by(func.random())
    
    result = await db.execute(query)
    return result.scalars().all()

@router.post("/upload")
async def upload_reel(
    masjid_id: int = Form(...),
    title: Optional[str] = Form(None),
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    try:
        # 1. Upload to Cloudinary
        upload_result = cloudinary.uploader.upload_large(
            file.file,
            resource_type = "video",
            folder = "masjid_connect/reels"
        )
        video_url = upload_result.get("secure_url")
        
        # 2. Save to DB
        reel = Reel(
            title=title,
            video_url=video_url,
            masjid_id=masjid_id
        )
        db.add(reel)
        await db.commit()
        await db.refresh(reel)
        
        return reel
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Reel upload failed: {str(e)}")
