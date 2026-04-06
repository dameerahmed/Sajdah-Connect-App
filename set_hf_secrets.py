import os
from huggingface_hub import HfApi
from dotenv import dotenv_values

# Configuration
# TODO: Update this if your space ID is different
REPO_ID = "dameerahmed/sajdah-connect-backend"
DOTENV_PATH = "backend/.env"

def upload_secrets():
    # Initialize HF API
    # Ensure you have logged in via 'huggingface-cli login' or HF_TOKEN env var
    api = HfApi()
    
    # Load .env file
    if not os.path.exists(DOTENV_PATH):
        print(f"ERROR: .env file not found at {DOTENV_PATH}")
        return

    secrets = dotenv_values(DOTENV_PATH)
    
    print(f"Found {len(secrets)} secrets. Starting upload to {REPO_ID}...")
    
    for key, value in secrets.items():
        if value is not None:
            # Clean possible quote wrapping for multi-line secrets
            clean_value = value.strip('"').replace('\\n', '\n')
            
            try:
                # Add or update the secret
                api.add_space_secret(repo_id=REPO_ID, key=key, value=clean_value)
                print(f"Successfully uploaded: {key}")
            except Exception as e:
                print(f"Failed to upload {key}: {str(e)}")

    print("\nAll secrets have been processed!")
    print("NOTE: You must have a valid HF_TOKEN for this to work.")

if __name__ == "__main__":
    upload_secrets()
