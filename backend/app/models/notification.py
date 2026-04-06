from typing import Optional
from sqlmodel import SQLModel, Field, Relationship
from datetime import datetime

class Notification(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    title: str
    body: str
    is_read: bool = Field(default=False, index=True)
    sender_icon: Optional[str] = None
    deep_link: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relationships
    user: "User" = Relationship(back_populates="notifications")

# Forward references
from app.models.user import User
