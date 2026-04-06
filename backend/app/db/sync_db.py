import asyncio
from sqlalchemy import text
from sqlmodel import SQLModel
from app.db.session import engine
# Import all models
from app.models.user import User
from app.models.masjid import Masjid
from app.models.reel import Reel
from app.models.notification import Notification

async def reset_db():
    print("🚀 Starting Aggressive Database Reset...")
    async with engine.begin() as conn:
        # Drop and recreate the public schema to ensure EVERYTHING is gone
        print("Cleaning out the public schema...")
        await conn.execute(text("DROP SCHEMA public CASCADE;"))
        await conn.execute(text("CREATE SCHEMA public;"))
        await conn.execute(text("GRANT ALL ON SCHEMA public TO public;"))
        await conn.execute(text("COMMENT ON SCHEMA public IS 'standard public schema';"))
        
        print("Creating fresh tables based on current models...")
        await conn.run_sync(SQLModel.metadata.create_all)
    print("Database is now clean and fresh! ✅")

if __name__ == "__main__":
    asyncio.run(reset_db())
