from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, func
from app.db.session import get_db
from app.models.interactions import Follow, ReelLike, ReelSave, ReelComment, BadWord
from app.models.user import User
from app.api.v1.auth import get_current_user
from typing import List, Optional
from datetime import datetime

router = APIRouter()

# ── Follow/Unfollow ───────────────────────────────────────────────────────
@router.post("/follow/{masjid_id}")
async def toggle_follow(
    masjid_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = select(Follow).where(Follow.user_id == current_user.id, Follow.masjid_id == masjid_id)
    result = await db.execute(query)
    follow = result.scalar_one_or_none()
    
    if follow:
        await db.delete(follow)
        status = "unfollowed"
    else:
        new_follow = Follow(user_id=current_user.id, masjid_id=masjid_id)
        db.add(new_follow)
        status = "followed"
    
    await db.commit()
    return {"status": status}

# ── Like/Unlike ───────────────────────────────────────────────────────────
@router.post("/like/{reel_id}")
async def toggle_like(
    reel_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = select(ReelLike).where(ReelLike.user_id == current_user.id, ReelLike.reel_id == reel_id)
    result = await db.execute(query)
    like = result.scalar_one_or_none()
    
    if like:
        await db.delete(like)
        status = "unliked"
    else:
        new_like = ReelLike(user_id=current_user.id, reel_id=reel_id)
        db.add(new_like)
        status = "liked"
    
    await db.commit()
    return {"status": status}

# ── Save/Unsave ───────────────────────────────────────────────────────────
@router.post("/save/{reel_id}")
async def toggle_save(
    reel_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = select(ReelSave).where(ReelSave.user_id == current_user.id, ReelSave.reel_id == reel_id)
    result = await db.execute(query)
    save = result.scalar_one_or_none()
    
    if save:
        await db.delete(save)
        status = "unsaved"
    else:
        new_save = ReelSave(user_id=current_user.id, reel_id=reel_id)
        db.add(new_save)
        status = "saved"
    
    await db.commit()
    return {"status": status}

# ── Paginated Comments ────────────────────────────────────────────────────
@router.get("/comments/{reel_id}")
async def get_comments(
    reel_id: int,
    page: int = Query(1, ge=1),
    size: int = Query(20, le=50),
    db: AsyncSession = Depends(get_db)
):
    offset = (page - 1) * size
    query = select(ReelComment).where(ReelComment.reel_id == reel_id).order_by(ReelComment.created_at.desc()).limit(size).offset(offset)
    result = await db.execute(query)
    return result.scalars().all()

@router.post("/comment/{reel_id}")
async def add_comment(
    reel_id: int,
    text: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Word Filter logic
    words_query = select(BadWord)
    words_result = await db.execute(words_query)
    bad_words = [bw.word.lower() for bw in words_result.scalars().all()]
    
    for bad_word in bad_words:
        if bad_word in text.lower():
            text = text.replace(bad_word, "***") # Simple censoring
            
    comment = ReelComment(user_id=current_user.id, reel_id=reel_id, text=text)
    db.add(comment)
    await db.commit()
    await db.refresh(comment)
    return comment
