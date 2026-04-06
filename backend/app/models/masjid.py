from typing import Optional, List
from sqlmodel import SQLModel, Field, Relationship
from datetime import datetime
import enum

class MasjidStatus(str, enum.Enum):
    PENDING = "pending"
    ACTIVE = "active"
    REJECTED = "rejected"

class MasjidBase(SQLModel):
    name: str = Field(index=True)
    address: str
    latitude: float
    longitude: float
    status: MasjidStatus = MasjidStatus.PENDING
    maslak: Optional[str] = None
    document_urls: Optional[str] = Field(default="[]") # JSON string of URLs
    
    # Jam'at Timings (Simple string for now, can be expanded)
    fajr: str
    dhuhr: str
    asr: str
    maghrib: str
    isha: str
    jummah: str

class Masjid(MasjidBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    owner_id: Optional[int] = Field(default=None, foreign_key="user.id")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relationships
    owner: Optional["User"] = Relationship(back_populates="masjids")
    reels: List["Reel"] = Relationship(back_populates="masjid")

# Forward references for relationships
from app.models.user import User
from app.models.reel import Reel
