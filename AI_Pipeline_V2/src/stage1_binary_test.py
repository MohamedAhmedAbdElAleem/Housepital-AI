
import os
import sys
import torch
import torch.nn as nn
import pandas as pd
import numpy as np
import timm
from pathlib import Path
from tqdm.auto import tqdm
from sklearn.metrics import accuracy_score, f1_score, roc_auc_score, classification_report, confusion_matrix
from torch.utils.data import DataLoader, Dataset
from PIL import Image
import albumentations as A
from albumentations.pytorch import ToTensorV2

# Config
CONFIG = {
    "seed": 42,
    "img_size": 224,
    "batch_size": 32,
    "num_workers": 0,
    "model_name": "tf_efficientnet_b0",
    "model_path": "../models/stage1_binary/best_model_fold_0.pth",
    "test_csv": "../data/loaders/test.csv",
    "root_dir": "../"
}

# Resolve Paths
CURRENT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = CURRENT_DIR.parent
CONFIG["model_path"] = PROJECT_ROOT / "models" / "stage1_binary" / "best_model_fold_0.pth"
CONFIG["test_csv"] = PROJECT_ROOT / "data" / "loaders" / "test.csv"
CONFIG["root_dir"] = PROJECT_ROOT

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using Device: {device}")

# --- Data Loading ---
class WoundDatasetDF(Dataset):
    def __init__(self, df, root_dir=None, transform=None, binary_mode=False):
        self.annotations = df
        self.root_dir = Path(root_dir) if root_dir else Path(".")
        self.transform = transform
        self.binary_mode = binary_mode
        
    def __len__(self):
        return len(self.annotations)

    def __getitem__(self, index):
        row = self.annotations.iloc[index]
        rel_path = row['path']
        rel_path = str(rel_path).replace('\\', os.sep).replace('/', os.sep)
        
        img_path = self.root_dir / rel_path
        
        try:
            image = Image.open(img_path).convert("RGB")
        except:
            if rel_path.startswith(".."):
                 img_path = self.root_dir / rel_path[3:]
            try:
                image = Image.open(img_path).convert("RGB")
            except:
                print(f"Warning: Could not open {img_path}, using black image.")
                image = Image.new('RGB', (224, 224), color='black')
            
        label_str = row['label'] 
        
        if self.binary_mode:
            label = 0 if label_str.lower() == 'healthy' else 1
        else:
            pass 
            
        if self.transform:
            image = np.array(image)
            augmented = self.transform(image=image)
            image = augmented['image']
            
        return image, torch.tensor(label, dtype=torch.float32)

def test(model, loader, device):
    model.eval()
    preds_all = []
    targets_all = []
    
    with torch.no_grad():
        for images, labels in tqdm(loader, desc="Testing", leave=False):
            images = images.to(device)
            # labels are not needed for inference if we didn't have them, 
            # but here we do for evaluation.
            
            outputs = model(images)
            preds_all.extend(torch.sigmoid(outputs).cpu().numpy())
            targets_all.extend(labels.cpu().numpy())
            
    return np.array(preds_all), np.array(targets_all)

if __name__ == "__main__":
    print(f"Loading Test Data from {CONFIG['test_csv']}...")
    
    # Test Transforms (Same as Validation)
    test_transforms = A.Compose([
        A.Resize(CONFIG['img_size'], CONFIG['img_size']),
        A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ToTensorV2(),
    ])

    if not CONFIG["test_csv"].exists():
        print(f"Error: Test CSV not found at {CONFIG['test_csv']}")
        sys.exit(1)

    df_test = pd.read_csv(CONFIG['test_csv'])
    print(f"Test Samples: {len(df_test)}")
    
    test_ds = WoundDatasetDF(df_test, root_dir=CONFIG['root_dir'], transform=test_transforms, binary_mode=True)
    test_loader = DataLoader(test_ds, batch_size=CONFIG['batch_size'], shuffle=False, num_workers=0, pin_memory=False)

    print("Loading Model...")
    model = timm.create_model(CONFIG['model_name'], pretrained=False, num_classes=1)
    
    if not CONFIG["model_path"].exists():
        print(f"Error: Model weights not found at {CONFIG['model_path']}")
        sys.exit(1)
        
    model.load_state_dict(torch.load(CONFIG['model_path']))
    model.to(device)
    
    print("Running Inference...")
    preds, targets = test(model, test_loader, device)
    
    # Metrics
    preds_binary = (preds > 0.5).astype(int)
    acc = accuracy_score(targets, preds_binary)
    f1 = f1_score(targets, preds_binary)
    try:
        roc = roc_auc_score(targets, preds)
    except:
        roc = 0.5
        
    print("\n" + "="*30)
    print("TEST RESULTS")
    print("="*30)
    print(f"Accuracy: {acc:.4f}")
    print(f"F1 Score: {f1:.4f}")
    print(f"ROC AUC : {roc:.4f}")
    print("-" * 30)
    print("Confusion Matrix:")
    print(confusion_matrix(targets, preds_binary))
    print("-" * 30)
    print("Classification Report:")
    print(classification_report(targets, preds_binary, target_names=['Healthy', 'Wound']))
    print("="*30)
