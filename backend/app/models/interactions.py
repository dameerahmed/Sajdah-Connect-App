from typing import Optional
from sqlmodel import SQLModel, Field, Relationship
from datetime import datetime

class Follow(SQLModel, table=True):
    user_id: int = Field(foreign_key="user.id", primary_key=True)
    masjid_id: int = Field(foreign_key="masjid.id", primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

class ReelLike(SQLModel, table=True):
    user_id: int = Field(foreign_key="user.id", primary_key=True)
    reel_id: int = Field(foreign_key="reel.id", primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

class ReelSave(SQLModel, table=True):
    user_id: int = Field(foreign_key="user.id", primary_key=True)
    reel_id: int = Field(foreign_key="reel.id", primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

class ReelComment(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    reel_id: int = Field(foreign_key="reel.id", index=True) # Index 1
    text: str
    created_at: datetime = Field(default_factory=datetime.utcnow, index=True) # Index 2

    # Relationships
    user: "User" = Relationship()
    reel: "Reel" = Relationship(back_populates="comments")

class BadWord(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    word: str = Field(unique=True)
