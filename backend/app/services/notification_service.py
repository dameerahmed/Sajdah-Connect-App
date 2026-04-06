"""
notification_service.py

Modular Firebase Cloud Messaging notification service.

Capabilities:
- send_to_all         : Broadcast to all users via FCM topic
- send_to_admins      : Broadcast to masjid admins via FCM topic
- send_to_followers   : Send to followers of a specific masjid by device token
- save_notification   : Persist notification to DB for in-app bell icon
"""

import firebase_admin
from firebase_admin import credentials, messaging
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from typing import List, Optional
import json, os

from app.core.config import settings
from app.models.notification import Notification
# FCM Helpers ──────────────────────────────────────────────────────────────

def send_to_all(title: str, body: str, data: Optional[dict] = None) -> str:
    """Broadcast to all_users FCM topic (Super Admin only)."""
    msg = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data=data or {},
        topic="all_users",
        android=messaging.AndroidConfig(priority="high"),
        apns=messaging.APNSConfig(payload=messaging.APNSPayload(aps=messaging.Aps(sound="default"))),
    )
    return messaging.send(msg)


def send_to_admins(title: str, body: str, data: Optional[dict] = None) -> str:
    """Broadcast to masjid_admins FCM topic."""
    msg = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data=data or {},
        topic="masjid_admins",
        android=messaging.AndroidConfig(priority="high"),
        apns=messaging.APNSConfig(payload=messaging.APNSPayload(aps=messaging.Aps(sound="default"))),
    )
    return messaging.send(msg)


def send_to_followers(device_tokens: List[str], title: str, body: str, data: Optional[dict] = None) -> messaging.BatchResponse:
    """Send follower-based alert to specific FCM device tokens."""
    if not device_tokens:
        return None
    msg = messaging.MulticastMessage(
        notification=messaging.Notification(title=title, body=body),
        data=data or {},
        tokens=device_tokens,
        android=messaging.AndroidConfig(priority="high"),
        apns=messaging.APNSConfig(payload=messaging.APNSPayload(aps=messaging.Aps(sound="default"))),
    )
    return messaging.send_each_for_multicast(msg)


# ── DB Helpers ───────────────────────────────────────────────────────────────

async def save_notification(
    db: AsyncSession,
    user_id: int,
    title: str,
    body: str,
    deep_link: Optional[str] = None,
    sender_icon: Optional[str] = None,
) -> Notification:
    """Persist an in-app notification to the DB."""
    notif = Notification(
        user_id=user_id,
        title=title,
        body=body,
        deep_link=deep_link,
        sender_icon=sender_icon,
    )
    db.add(notif)
    await db.commit()
    await db.refresh(notif)
    return notif


async def get_unread_count(db: AsyncSession, user_id: int) -> int:
    """Return count of unread notifications for a user."""
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == user_id)
        .where(Notification.is_read == False)
    )
    return len(result.scalars().all())


async def mark_all_read(db: AsyncSession, user_id: int) -> None:
    """Mark all notifications as read for a user."""
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == user_id)
        .where(Notification.is_read == False)
    )
    notifs = result.scalars().all()
    for n in notifs:
        n.is_read = True
        db.add(n)
    await db.commit()
