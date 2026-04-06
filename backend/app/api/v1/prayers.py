from fastapi import APIRouter, HTTPException, Query
import httpx
from typing import Optional
import datetime

router = APIRouter()

ALADHAN_API_URL = "http://api.aladhan.com/v1/timings"

@router.get("/timings")
async def get_prayer_timings(
    latitude: float = Query(...),
    longitude: float = Query(...),
    method: int = Query(2), # Default to ISNA, for Pakistan/Karachi use 1 (Karachi)
    date: Optional[str] = None
):
    """
    Fetch real-time prayer timings from Aladhan API based on coordinates.
    """
    if not date:
        date = datetime.date.today().strftime("%d-%m-%Y")

    params = {
        "latitude": latitude,
        "longitude": longitude,
        "method": method
    }

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{ALADHAN_API_URL}/{date}", params=params)
            
            if response.status_code != 200:
                raise HTTPException(status_code=500, detail="Failed to fetch prayer timings from external service")
            
            data = response.json()
            if data["code"] != 200:
                raise HTTPException(status_code=500, detail=data.get("status", "Unknown error from Aladhan API"))

            return data["data"]["timings"]
            
    except httpx.RequestError as e:
        raise HTTPException(status_code=503, detail=f"External prayer service unavailable: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"System error calculating prayers: {str(e)}")
