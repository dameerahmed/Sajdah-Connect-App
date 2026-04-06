from typing import Optional, List
from sqlmodel import SQLModel, Field, Relationship
from datetime import datetime
import enum

class UserRole(str, enum.Enum):
    USER = "user"
    MASJID_ADMIN = "masjid_admin"
    SUPER_ADMIN = "super_admin"

class UserBase(SQLModel):
    email: str = Field(unique=True, index=True)
    full_name: Optional[str] = None
    is_active: bool = True
    role: UserRole = UserRole.USER
    maslak: Optional[str] = None
    profile_pic: Optional[str] = None

class User(UserBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    hashed_password: Optional[str] = None  # Store BCrypt/Argon2 hashes
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relationships
    masjids: List["Masjid"] = Relationship(back_populates="owner")
    notifications: List["Notification"] = Relationship(back_populates="user")
    follows: List["Follow"] = Relationship()
    likes: List["ReelLike"] = Relationship()
    saves: List["ReelSave"] = Relationship()

# Forward references
from app.models.masjid import Masjid
from app.models.interactions import Follow, ReelLike, ReelSave
