
import requests
import os
from pathlib import Path
from tqdm import tqdm
import concurrent.futures

# Config
NUM_IMAGES = 1000  # Number of negative images
IMG_SIZE = 640     # YOLOv11 standard size (high res)
OUTPUT_DIR = Path(__file__).resolve().parent.parent / "data/raw/background_class_highres"

def download_image(idx):
    try:
        # Lorem Picsum provides random valid images
        # We add a random seed to url to ensure uniqueness if needed, 
        # but the /seed/{idx}/ endpoint is better for reproducibility.
        url = f"https://picsum.photos/seed/{idx}/{IMG_SIZE}/{IMG_SIZE}"
        
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            file_path = OUTPUT_DIR / f"bg_highres_{idx:05d}.jpg"
            with open(file_path, 'wb') as f:
                f.write(response.content)
            return True
    except Exception as e:
        return False
    return False

def main():
    if OUTPUT_DIR.exists():
        print(f"Directory {OUTPUT_DIR} exists. Cleaning up old low-res data if mixed...")
        # Optional: Clean up if you want a fresh start
        # shutil.rmtree(OUTPUT_DIR) 
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    print(f"Downloading {NUM_IMAGES} High-Res images to {OUTPUT_DIR}...")
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=50) as executor:
        results = list(tqdm(executor.map(download_image, range(NUM_IMAGES)), total=NUM_IMAGES))
        
    success_count = sum(results)
    print(f"Successfully downloaded {success_count}/{NUM_IMAGES} images.")

if __name__ == "__main__":
    main()
