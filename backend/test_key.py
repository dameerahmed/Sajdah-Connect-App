import os
from dotenv import load_dotenv

load_dotenv()

key = os.getenv("FIREBASE_PRIVATE_KEY")
if key:
    print(f"Key Length: {len(key)}")
    print(f"Key Starts: {key[:50]}")
    print(f"Key Ends: {key[-50:]}")
    
    # Check for literal backslashes
    backslashes = [i for i, char in enumerate(key) if char == '\\']
    print(f"Backslashes at positions: {backslashes}")
    
    # Try parsing like the service does
    parsed_key = key.replace("\\n", "\n").replace('\\n', '\n').strip('"')
    print(f"Parsed Key Length: {len(parsed_key)}")
    
    if "\\n" in parsed_key:
        print("WARNING: Literal '\\n' still present in parsed key!")
else:
    print("FIREBASE_PRIVATE_KEY not found in .env")
