from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from typing import List
from pydantic import BaseModel
from app.db.session import get_db
from app.models.notification import Notification
from app.services import notification_service
from app.core.config import settings

router = APIRouter()


# ── Schemas ────────────────────────────────────────────────────────────────
class NotificationOut(BaseModel):
    id: int
    title: str
    body: str
    is_read: bool
    sender_icon: str | None
    deep_link: str | None
    created_at: str

    class Config:
        from_attributes = True


class BroadcastPayload(BaseModel):
    title: str
    body: str
    deep_link: str | None = None


# ── Endpoints ──────────────────────────────────────────────────────────────

@router.get("/", response_model=List[NotificationOut])
async def get_notifications(
    user_id: int,   # TODO: replace with JWT dependency
    db: AsyncSession = Depends(get_db),
):
    """Return all notifications for the current user (newest first)."""
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == user_id)
        .order_by(Notification.created_at.desc())
    )
    notifs = result.scalars().all()
    return [
        NotificationOut(
            id=n.id,
            title=n.title,
            body=n.body,
            is_read=n.is_read,
            sender_icon=n.sender_icon,
            deep_link=n.deep_link,
            created_at=n.created_at.isoformat(),
        )
        for n in notifs
    ]


@router.get("/unread-count")
async def unread_count(
    user_id: int,   # TODO: replace with JWT dependency
    db: AsyncSession = Depends(get_db),
):
    """Return unread notification count for badge."""
    count = await notification_service.get_unread_count(db, user_id)
    return {"unread_count": count}


@router.post("/mark-as-read")
async def mark_as_read(
    user_id: int,   # TODO: replace with JWT dependency
    db: AsyncSession = Depends(get_db),
):
    """Mark all notifications as read. Called when user opens the notification page."""
    await notification_service.mark_all_read(db, user_id)
    return {"status": "ok"}


@router.post("/broadcast-all")
async def broadcast_all(payload: BroadcastPayload):
    """Super Admin: broadcast push to all_users FCM topic."""
    # TODO: Add super admin auth dependency
    try:
        msg_id = notification_service.send_to_all(payload.title, payload.body)
        return {"status": "sent", "message_id": msg_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/broadcast-admins")
async def broadcast_admins(payload: BroadcastPayload):
    """Super Admin: broadcast push to masjid_admins FCM topic."""
    # TODO: Add super admin auth dependency
    try:
        msg_id = notification_service.send_to_admins(payload.title, payload.body)
        return {"status": "sent", "message_id": msg_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
