
import torch
import timm
from pathlib import Path
from PIL import Image
import albumentations as A
from albumentations.pytorch import ToTensorV2
import numpy as np
from torch.utils.data import Dataset, DataLoader
import pandas as pd
from sklearn.metrics import classification_report, confusion_matrix
import sys
import os

# Config
PROJECT_ROOT = Path(__file__).resolve().parent.parent
MODEL_PATH = PROJECT_ROOT / "models" / "stage3_severity" / "best_model.pth"
VAL_CSV = PROJECT_ROOT / "data" / "loaders" / "dfu_severity_val.csv"
DATA_DIR = PROJECT_ROOT.parent / "data" / "raw" / "severity_dfu" # Adjust based on actual structure if needed
CLASSES = ['grade_1', 'grade_2', 'grade_3', 'grade_4']
IMG_SIZE = 224
BATCH_SIZE = 16
DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

print(f"Device: {DEVICE}")
print(f"Model Path: {MODEL_PATH}")

class DfuSeverityTestDataset(Dataset):
    def __init__(self, csv_file, root_dir, transform=None):
        self.df = pd.read_csv(csv_file)
        self.root_dir = root_dir
        self.transform = transform
        self.df = self.df[self.df['class'].isin(CLASSES)].reset_index(drop=True)
        self.class_to_idx = {name: i for i, name in enumerate(CLASSES)}

    def __len__(self):
        return len(self.df)

    def __getitem__(self, idx):
        row = self.df.iloc[idx]
        label = self.class_to_idx[row['class']]
        rel_path = str(row['path']).replace('\\', os.sep).replace('/', os.sep)
        
        # Consistent path resolution
        # CSV has paths like: ..\data\raw\severity_dfu\grade_3\grade_3_00225.jpg
        # We want: PROJECT_ROOT / data / raw / severity_dfu / ...
        
        rel_path_clean = rel_path
        if "data" in rel_path:
             # Extract from "data" onwards
             clean_path = rel_path[rel_path.find("data"):]
             img_path = PROJECT_ROOT / clean_path
        else:
             # Fallback: Try straight append
             img_path = PROJECT_ROOT / rel_path.lstrip(".\\/")
             
        if not img_path.exists():
             # Try parent if not found (just in case)
             img_path_parent = PROJECT_ROOT.parent / rel_path.lstrip(".\\/")
             if img_path_parent.exists():
                 img_path = img_path_parent
             
        try:
            image = Image.open(img_path).convert("RGB")
            image = np.array(image)
            
            if self.transform:
                augmented = self.transform(image=image)
                image = augmented['image']
            return image, torch.tensor(label, dtype=torch.long)
        except Exception as e:
            print(f"Error loading {img_path}: {e}")
            # Return dummy
            return torch.zeros((3, IMG_SIZE, IMG_SIZE)), torch.tensor(label, dtype=torch.long)

def test_model():
    if not MODEL_PATH.exists():
        print(f"Error: Model not found at {MODEL_PATH}")
        return

    # Transforms (Same as Val)
    test_transform = A.Compose([
        A.Resize(IMG_SIZE, IMG_SIZE),
        A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ToTensorV2(),
    ])

    # Dataset & Loader
    # Note: Using Validation set as 'Test' for now since user asked to test "like the others" 
    # and we might not have a separate held-out test set configured yet.
    test_ds = DfuSeverityTestDataset(VAL_CSV, PROJECT_ROOT.parent, transform=test_transform)
    test_loader = DataLoader(test_ds, batch_size=BATCH_SIZE, shuffle=False, num_workers=0)
    
    print(f"Test Dataset Size: {len(test_ds)}")

    # Model Load
    model = timm.create_model('tf_efficientnet_b0', pretrained=False, num_classes=len(CLASSES))
    try:
        model.load_state_dict(torch.load(MODEL_PATH, map_location=DEVICE))
    except Exception as e:
        print(f"Failed to load state dict directly, trying 'model_state_dict' key: {e}")
        checkpoint = torch.load(MODEL_PATH, map_location=DEVICE)
        model.load_state_dict(checkpoint['model_state_dict'])
        
    model.to(DEVICE)
    model.eval()

    all_preds = []
    all_lbls = []

    print("Starting Inference...")
    with torch.no_grad():
        for imgs, lbls in test_loader:
            imgs, lbls = imgs.to(DEVICE), lbls.to(DEVICE)
            outputs = model(imgs)
            preds = torch.argmax(outputs, dim=1)
            all_preds.extend(preds.cpu().numpy())
            all_lbls.extend(lbls.cpu().numpy())

    print("\nClassification Report:")
    print(classification_report(all_lbls, all_preds, target_names=CLASSES))
    
    print("\nConfusion Matrix:")
    print(confusion_matrix(all_lbls, all_preds))

if __name__ == "__main__":
    test_model()
