
import os
import shutil
import torch
import torchvision
import numpy as np
from pathlib import Path
from PIL import Image
from tqdm import tqdm

# Config
OUTPUT_DIR = Path(r"../data/raw/background_class")
NUM_IMAGES = 2000 # Enough to balance roughly
CLASSES_TO_KEEP = ['airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck'] 
# Actually, we want ALL of these as 'background' except maybe 'person' if it existed? 
# CIFAR-10 classes are: airplane, automobile, bird, cat, deer, dog, frog, horse, ship, truck. 
# None are human skin/wounds. So all are good negatives.

def download_and_extract_cifar():
    print("Downloading CIFAR-10...")
    cifar_train = torchvision.datasets.CIFAR10(root='./temp_data', train=True, download=True)
    cifar_test = torchvision.datasets.CIFAR10(root='./temp_data', train=False, download=True)
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Combine
    data = np.concatenate([cifar_train.data, cifar_test.data])
    targets = np.concatenate([cifar_train.targets, cifar_test.targets])
    
    print(f"Total CIFAR images: {len(data)}")
    
    # Select random subset
    indices = np.random.choice(len(data), NUM_IMAGES, replace=False)
    
    print(f"Extracting {NUM_IMAGES} images to {OUTPUT_DIR}...")
    
    for i, idx in enumerate(tqdm(indices)):
        img_array = data[idx]
        img = Image.fromarray(img_array)
        
        # CIFAR is 32x32, which is small. We might want to upscale or accept they are low res.
        # EfficientNet expects ~224. Upscaling 32->224 is ugly but sufficient for "texture" check.
        # Alternatively, we could use ImageNet validation set if available, but CIFAR is easiest to auto-download.
        # Let's upscale with bicubic to reduce pixelation artifacts slightly.
        img = img.resize((224, 224), Image.BICUBIC)
        
        save_path = OUTPUT_DIR / f"cifar_bg_{i:05d}.jpg"
        img.save(save_path)
        
    print("Cleanup...")
    if os.path.exists('./temp_data'):
        shutil.rmtree('./temp_data')
        
    print("Done.")

if __name__ == "__main__":
    download_and_extract_cifar()
