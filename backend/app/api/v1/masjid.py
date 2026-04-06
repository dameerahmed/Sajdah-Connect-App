from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile, Form
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, text
import json

from app.db.session import get_db
from app.models.masjid import Masjid, MasjidStatus
from app.models.user import User, UserRole
from app.api.deps import get_current_active_user
from app.services.media_service import upload_multiple_images
from typing import List, Optional

router = APIRouter()

@router.get("/my", response_model=List[Masjid])
async def get_my_masjids(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get all masjids owned by the current user.
    """
    query = select(Masjid).where(Masjid.owner_id == current_user.id)
    result = await db.execute(query)
    return result.scalars().all()

@router.get("/nearby", response_model=List[Masjid])
async def get_nearby_masjids(
    lat: float,
    lon: float,
    radius: float = 5.0,
    maslak: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
):
    # Professional nearby search placeholder for now
    query = select(Masjid).where(Masjid.status == MasjidStatus.ACTIVE)
    if maslak:
        query = query.where(Masjid.maslak == maslak)
    
    result = await db.execute(query)
    return result.scalars().all()

@router.post("/register", response_model=Masjid)
async def register_masjid(
    name: str = Form(...),
    address: str = Form(...),
    latitude: float = Form(...),
    longitude: float = Form(...),
    maslak: str = Form(...),
    fajr: str = Form(...),
    dhuhr: str = Form(...),
    asr: str = Form(...),
    maghrib: str = Form(...),
    isha: str = Form(...),
    jummah: str = Form(...),
    documents: List[UploadFile] = File([]),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    # Upload documents to Cloudinary
    doc_urls = []
    if documents:
        # Convert files to format suitable for uploader
        files_to_upload = [file.file for file in documents]
        doc_urls = upload_multiple_images(files_to_upload, folder=f"masjids/{name}")
    
    # Create new masjid record
    new_masjid = Masjid(
        name=name,
        address=address,
        latitude=latitude,
        longitude=longitude,
        maslak=maslak,
        fajr=fajr,
        dhuhr=dhuhr,
        asr=asr,
        maghrib=maghrib,
        isha=isha,
        jummah=jummah,
        document_urls=json.dumps(doc_urls), # Store as JSON string
        owner_id=current_user.id,
        status=MasjidStatus.PENDING
    )
    
    db.add(new_masjid)
    await db.commit()
    await db.refresh(new_masjid)
    return new_masjid

@router.get("/{masjid_id}", response_model=Masjid)
async def get_masjid_profile(
    masjid_id: int,
    db: AsyncSession = Depends(get_db)
):
    masjid = await db.get(Masjid, masjid_id)
    if not masjid:
        raise HTTPException(status_code=404, detail="Masjid not found")
    return masjid
