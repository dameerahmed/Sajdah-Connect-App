from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from sqlalchemy import func
from app.db.session import get_db
from app.models.masjid import Masjid, MasjidStatus
from app.models.user import User, UserRole
from app.models.reel import Reel
from app.api.deps import get_current_active_user
from typing import List

router = APIRouter()

def check_super_admin(current_user: User = Depends(get_current_active_user)):
    """
    Dependency to ensure only Super Admins (Dameer) can trigger these actions.
    """
    if current_user.role != UserRole.SUPER_ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Sirf Dameer bhai (Super Admin) hi ye action kar saktay hain!"
        )
    return current_user

@router.get("/stats")
async def get_stats(
    current_user: User = Depends(check_super_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    Get real-time statistics for the Super Admin dashboard.
    """
    total_users = (await db.execute(select(func.count(User.id)))).scalar()
    active_masjids = (await db.execute(select(func.count(Masjid.id)).where(Masjid.status == MasjidStatus.ACTIVE))).scalar()
    pending_requests = (await db.execute(select(func.count(Masjid.id)).where(Masjid.status == MasjidStatus.PENDING))).scalar()
    total_reels = (await db.execute(select(func.count(Reel.id)))).scalar()
    
    return {
        "total_users": total_users or 0,
        "active_masjids": active_masjids or 0,
        "pending_requests": pending_requests or 0,
        "total_reels": total_reels or 0
    }

@router.get("/pending-masjids", response_model=List[Masjid])
async def get_pending_masjids(
    current_user: User = Depends(check_super_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    List all masjids awaiting approval.
    """
    query = select(Masjid).where(Masjid.status == MasjidStatus.PENDING)
    result = await db.execute(query)
    return result.scalars().all()

@router.get("/approved-masjids", response_model=List[Masjid])
async def get_approved_masjids(
    current_user: User = Depends(check_super_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    List all approved and active masjids.
    """
    query = select(Masjid).where(Masjid.status == MasjidStatus.ACTIVE)
    result = await db.execute(query)
    return result.scalars().all()

@router.get("/rejected-masjids", response_model=List[Masjid])
async def get_rejected_masjids(
    current_user: User = Depends(check_super_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    List all rejected masjid registrations.
    """
    query = select(Masjid).where(Masjid.status == MasjidStatus.REJECTED)
    result = await db.execute(query)
    return result.scalars().all()

@router.post("/approve-masjid/{masjid_id}")
async def approve_masjid(
    masjid_id: int,
    current_user: User = Depends(check_super_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    Approve a pending masjid and make it LIVE.
    """
    masjid = await db.get(Masjid, masjid_id)
    if not masjid:
        raise HTTPException(status_code=404, detail="Masjid not found")
        
    masjid.status = MasjidStatus.ACTIVE
    db.add(masjid)
    await db.commit()
    
    # Optional: Logic to notify the owner can be added here via app.services.notification_service
    
    return {"message": f"'{masjid.name}' approve ho gayi hai! 🎉"}

@router.post("/reject-masjid/{masjid_id}")
async def reject_masjid(
    masjid_id: int,
    current_user: User = Depends(check_super_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    Reject a pending masjid registration.
    """
    masjid = await db.get(Masjid, masjid_id)
    if not masjid:
        raise HTTPException(status_code=404, detail="Masjid not found")
        
    masjid.status = MasjidStatus.REJECTED
    db.add(masjid)
    await db.commit()
    return {"message": "Masjid reject kar di gayi hai."}
