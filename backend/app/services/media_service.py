import cloudinary
import cloudinary.uploader
from app.core.config import settings

# Configure Cloudinary
cloudinary.config(
    cloudinary_url=settings.CLOUDINARY_URL
)

def upload_image(file, folder: str = "masjids") -> str:
    """Uploads an image file to Cloudinary and returns the secure URL."""
    try:
        upload_result = cloudinary.uploader.upload(
            file,
            folder=folder,
            resource_type="auto"
        )
        return upload_result.get("secure_url")
    except Exception as e:
        print(f"Cloudinary upload failed: {e}")
        return None

def upload_multiple_images(files: list, folder: str = "masjids") -> list:
    """Uploads multiple image files to Cloudinary."""
    urls = []
    for file in files:
        url = upload_image(file, folder)
        if url:
            urls.append(url)
    return urls
