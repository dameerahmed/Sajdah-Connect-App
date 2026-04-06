from typing import Optional, List
from sqlmodel import SQLModel, Field, Relationship
from datetime import datetime

class ReelBase(SQLModel):
    title: Optional[str] = None
    video_url: str
    thumbnail_url: Optional[str] = None
    masjid_id: int = Field(foreign_key="masjid.id")

class Reel(ReelBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relationships
    masjid: "Masjid" = Relationship(back_populates="reels")
    comments: List["ReelComment"] = Relationship(back_populates="reel")
    likes: List["ReelLike"] = Relationship()
    saves: List["ReelSave"] = Relationship()

# Forward references
from app.models.masjid import Masjid
from app.models.interactions import ReelComment, ReelLike, ReelSave
