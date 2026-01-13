import os
import torch
from torchvision import datasets, transforms
from torch.utils.data import DataLoader
from PIL import Image
import numpy as np
from tqdm import tqdm

def check_dataset_integrity(root_dir, remove_corrupt=False):
    """
    Scans the dataset to identify and optionally remove corrupt or unreadable images.
    This prevents training crashes later.
    """
    print(f"Checking dataset integrity in: {root_dir}")
    corrupt_files = []
    total_files = 0
    
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.tiff')):
                total_files += 1
                file_path = os.path.join(subdir, file)
                try:
                    with Image.open(file_path) as img:
                        img.verify() # Verify file integrity
                except (IOError, SyntaxError) as e:
                    print(f"Corrupt file found: {file_path} - {e}")
                    corrupt_files.append(file_path)
    
    print(f"Scan complete. Found {len(corrupt_files)} corrupt files out of {total_files}.")
    
    if remove_corrupt and corrupt_files:
        print("Removing corrupt files...")
        for f in corrupt_files:
            try:
                os.remove(f)
                print(f"Deleted: {f}")
            except OSError as e:
                print(f"Error deleting {f}: {e}")
                
    return corrupt_files

def get_dataset_stats(root_dir, image_size=(224, 224), batch_size=64):
    """
    Calculates the Mean and Standard Deviation of the entire dataset.
    This ensures our normalization is perfectly tuned to OUR images, 
    not just ImageNet defaults.
    """
    print(f"Calculating stats for dataset: {root_dir}")
    
    # transform just to tensor for calculation
    temp_transform = transforms.Compose([
        transforms.Resize(image_size),
        transforms.ToTensor()
    ])
    
    dataset = datasets.ImageFolder(root=root_dir, transform=temp_transform)
    loader = DataLoader(dataset, batch_size=batch_size, shuffle=False, num_workers=4)
    
    mean = 0.
    std = 0.
    total_images_count = 0
    
    for images, _ in tqdm(loader, desc="Computing Stats"):
        batch_samples = images.size(0) # batch size (the last batch can have smaller size!)
        images = images.view(batch_samples, images.size(1), -1)
        mean += images.mean(2).sum(0)
        std += images.std(2).sum(0)
        total_images_count += batch_samples

    mean /= total_images_count
    std /= total_images_count
    
    print(f"Dataset Mean: {mean}")
    print(f"Dataset Std: {std}")
    
    return mean.tolist(), std.tolist()

def get_transforms(image_size=(224, 224), mean=None, std=None):
    """
    Returns standard training and validation transforms.
    If mean/std are provided, uses them for normalization.
    Otherwise uses ImageNet defaults (good starting point).
    """
    if mean is None:
        mean = [0.485, 0.456, 0.406] # ImageNet defaults
    if std is None:
        std = [0.229, 0.224, 0.225] # ImageNet defaults
        
    print(f"Building transforms with Mean={mean}, Std={std}")

    data_transforms = {
        'train': transforms.Compose([
            transforms.Resize(image_size),
            # Note: We will add more augmentations (rotation, lighting) in the training loop 
            # or a specific augmentation config later. This is the BASE transform.
            transforms.ToTensor(),
            transforms.Normalize(mean, std)
        ]),
        'val': transforms.Compose([
            transforms.Resize(image_size),
            transforms.ToTensor(),
            transforms.Normalize(mean, std)
        ]),
    }
    return data_transforms
