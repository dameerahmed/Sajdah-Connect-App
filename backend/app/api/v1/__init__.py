from fastapi import APIRouter
from app.api.v1 import auth, masjid, reels, super_admin, interactions, prayers, notifications

router = APIRouter()
router.include_router(auth.router, prefix="/auth", tags=["auth"])
router.include_router(masjid.router, prefix="/masjid", tags=["masjid"])
router.include_router(reels.router, prefix="/reels", tags=["reels"])
router.include_router(super_admin.router, prefix="/super-admin", tags=["super-admin"])
router.include_router(interactions.router, prefix="/interactions", tags=["interactions"])
router.include_router(prayers.router, prefix="/prayers", tags=["prayers"])
router.include_router(notifications.router, prefix="/notifications", tags=["notifications"])
