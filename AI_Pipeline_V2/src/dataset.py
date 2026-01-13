import torch
from torch.utils.data import Dataset
import pandas as pd
from pathlib import Path
from PIL import Image
import os

class WoundDataset(Dataset):
    """
    Custom Dataset for Wound Classification.
    
    Args:
        csv_file (str or Path): Path to the CSV file with annotations.
        root_dir (str or Path): Root directory for the dataset (used to resolve relative paths).
        transform (callable, optional): Optional transform to be applied on a sample.
        binary_mode (bool): If True, maps 'healthy' to 0 and all other classes to 1.
                            If False, uses the standard class mapping.
    """
    def __init__(self, csv_file, root_dir=None, transform=None, binary_mode=False):
        self.annotations = pd.read_csv(csv_file)
        self.root_dir = Path(root_dir) if root_dir else Path(".")
        self.transform = transform
        self.binary_mode = binary_mode
        
        # Determine label column: check for 'label' first, then 'class'
        if 'label' in self.annotations.columns:
            self.label_col = 'label'
        elif 'class' in self.annotations.columns:
            self.label_col = 'class'
        else:
            raise KeyError("CSV must contain either 'label' or 'class' column.")
        
        # Define Class Mappings
        self.classes = sorted(list(self.annotations[self.label_col].unique()))
        
        # Specific fixed mapping to ensure consistency
        # healthy is 0, others are mapped accordingly if not binary
        if self.binary_mode:
            self.class_to_idx = {
                'healthy': 0,
                'diabetic_foot': 1,
                'abrasion': 1,
                'bruise': 1,
                'burn': 1,
                'cut': 1,
                'laceration': 1,
                'surgical': 1,
                # Fallback for any other class
            }
        else:
            # Standard mapping (alphabetical usually, but let's be explicit if possible)
            # For now, we trust the sorted order, but in production we might want a fixed dict
            self.class_to_idx = {cls_name: idx for idx, cls_name in enumerate(self.classes)}

    def __len__(self):
        return len(self.annotations)

    def __getitem__(self, index):
        # row: filename, class, path
        row = self.annotations.iloc[index]
        rel_path = row['path']
        
        # Handle path resolution
        # The CSV paths are like "..\data\raw\..."
        # We need to resolve them relative to root_dir
        # If root_dir is provided, we join, otherwise we assume the path is valid relative to CWD
        
        # Clean up path separators for cross-platform compatibility
        rel_path = str(rel_path).replace('\\', os.sep).replace('/', os.sep)
        
        img_path = self.root_dir / rel_path
        
        # If the path starts with '..', it might need special handling depending on where script is run
        # Ideally, we resolve it fully.
        
        try:
            image = Image.open(img_path).convert("RGB")
        except FileNotFoundError:
            # Fallback: try to find it without the leading '..' if it failed
            # This is a hack for robustness
            if rel_path.startswith(".."):
                try:
                    stripped = rel_path[3:] # remove "../"
                    img_path_fallback = self.root_dir / stripped
                    image = Image.open(img_path_fallback).convert("RGB")
                    # print(f"Recovered path: {img_path_fallback}")
                except:
                    raise FileNotFoundError(f"Colud not find image at {img_path} or fallback")
            else:
                raise FileNotFoundError(f"Could not find image at {img_path}")

        label_str = row[self.label_col]
        
        if self.binary_mode:
            # Default to 1 (Wound) if not 'healthy'
            label = 0 if label_str.lower() == 'healthy' else 1
        else:
            label = self.class_to_idx[label_str]

        if self.transform:
            image = self.transform(image)

        return image, torch.tensor(label, dtype=torch.long)
