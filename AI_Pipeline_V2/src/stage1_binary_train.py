
import os
import sys
import torch
import torch.nn as nn
import torch.optim as optim
import pandas as pd
import numpy as np
import timm
from pathlib import Path
from tqdm.auto import tqdm
from sklearn.metrics import accuracy_score, f1_score, roc_auc_score
from torch.utils.data import DataLoader, Dataset
from PIL import Image
import albumentations as A
from albumentations.pytorch import ToTensorV2

# Config
CONFIG = {
    "seed": 42,
    "img_size": 224,
    "batch_size": 32,
    "num_workers": 0, # Windows compatibility
    "epochs": 5,
    "lr": 1e-3,
    "model_name": "tf_efficientnet_b0",
    "model_dir": "../models/stage1_binary/",
    "data_csv": "../data/loaders/train_folds.csv",
    "root_dir": "../"
}

# Ensure model directory exists (handle relative paths carefully)
# Script is in src/ so ../models is correct relative to execution in src/
# BUT if we run from root, we need to adjust.
# Best practice: make paths absolute based on script location
CURRENT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = CURRENT_DIR.parent
CONFIG["model_dir"] = PROJECT_ROOT / "models" / "stage1_binary"
CONFIG["data_csv"] = PROJECT_ROOT / "data" / "loaders" / "train_folds.csv"
CONFIG["root_dir"] = PROJECT_ROOT

os.makedirs(CONFIG["model_dir"], exist_ok=True)

# Set Seed
def seed_everything(seed):
    os.environ['PYTHONHASHSEED'] = str(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.backends.cudnn.deterministic = True

seed_everything(CONFIG['seed'])
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
        # Fix paths
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
            pass # Multi-class not main focus here
            
        if self.transform:
            image = np.array(image)
            augmented = self.transform(image=image)
            image = augmented['image']
            
        return image, torch.tensor(label, dtype=torch.float32)

def train_one_epoch(model, loader, criterion, optimizer, device, scaler=None):
    model.train()
    running_loss = 0.0
    preds_all = []
    targets_all = []
    
    # Use tqdm but careful with notebook/console mismatch
    pbar = tqdm(loader, desc="Training", leave=False, dynamic_ncols=True)
    
    for images, labels in pbar:
        images, labels = images.to(device), labels.to(device).unsqueeze(1)
        
        optimizer.zero_grad()
        
        with torch.cuda.amp.autocast(enabled=(scaler is not None)):
            outputs = model(images)
            loss = criterion(outputs, labels)
            
        if scaler:
            scaler.scale(loss).backward()
            scaler.step(optimizer)
            scaler.update()
        else:
            loss.backward()
            optimizer.step()
            
        running_loss += loss.item() * images.size(0)
        
        preds_all.extend(torch.sigmoid(outputs).detach().cpu().numpy())
        targets_all.extend(labels.detach().cpu().numpy())
        
        pbar.set_postfix(loss=loss.item())
        
    epoch_loss = running_loss / len(loader.dataset)
    preds_binary = (np.array(preds_all) > 0.5).astype(int)
    acc = accuracy_score(targets_all, preds_binary)
    
    return epoch_loss, acc

def validate(model, loader, criterion, device):
    model.eval()
    running_loss = 0.0
    preds_all = []
    targets_all = []
    
    with torch.no_grad():
        for images, labels in tqdm(loader, desc="Validating", leave=False, dynamic_ncols=True):
            images, labels = images.to(device), labels.to(device).unsqueeze(1)
            
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            running_loss += loss.item() * images.size(0)
            preds_all.extend(torch.sigmoid(outputs).cpu().numpy())
            targets_all.extend(labels.cpu().numpy())
            
    epoch_loss = running_loss / len(loader.dataset)
    preds_binary = (np.array(preds_all) > 0.5).astype(int)
    acc = accuracy_score(targets_all, preds_binary)
    f1 = f1_score(targets_all, preds_binary)
    try:
        roc = roc_auc_score(targets_all, preds_all)
    except:
        roc = 0.5
    
    return epoch_loss, acc, f1, roc

# Main execution
if __name__ == "__main__":
    print("Loading Data...")
    # Transforms
    train_transforms = A.Compose([
        A.Resize(CONFIG['img_size'], CONFIG['img_size']),
        A.HorizontalFlip(p=0.5),
        A.VerticalFlip(p=0.5),
        A.Rotate(limit=30, p=0.5),
        A.RandomBrightnessContrast(p=0.2),
        A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ToTensorV2(),
    ])

    val_transforms = A.Compose([
        A.Resize(CONFIG['img_size'], CONFIG['img_size']),
        A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ToTensorV2(),
    ])

    # Load Full Data
    df = pd.read_csv(CONFIG['data_csv'])
    print(f"Total Dataset Size: {len(df)}")

    # 5-Fold Cross Validation Loop
    NUM_FOLDS = 5
    
    for FOLD in range(NUM_FOLDS):
        print("\n" + "="*40)
        print(f"Training Fold {FOLD}/{NUM_FOLDS-1}")
        print("="*40)
        
        # Prepare Data for this Fold
        train_df = df[df['fold'] != FOLD].reset_index(drop=True)
        val_df = df[df['fold'] == FOLD].reset_index(drop=True)

        train_ds = WoundDatasetDF(train_df, root_dir=CONFIG['root_dir'], transform=train_transforms, binary_mode=True)
        val_ds = WoundDatasetDF(val_df, root_dir=CONFIG['root_dir'], transform=val_transforms, binary_mode=True)
        
        train_loader = DataLoader(train_ds, batch_size=CONFIG['batch_size'], shuffle=True, num_workers=CONFIG['num_workers'], pin_memory=False)
        val_loader = DataLoader(val_ds, batch_size=CONFIG['batch_size'], shuffle=False, num_workers=CONFIG['num_workers'], pin_memory=False)

        print(f"Train Samples: {len(train_df)} | Val Samples: {len(val_df)}")
        
        # Initialize Model & Components per Fold
        model = timm.create_model(CONFIG['model_name'], pretrained=True, num_classes=1).to(device)
        criterion = nn.BCEWithLogitsLoss()
        optimizer = optim.AdamW(model.parameters(), lr=CONFIG['lr'])
        scaler = torch.cuda.amp.GradScaler()

        best_score = 0.0 # Use Accuracy or F1 or ROC for best model? Let's use Loss for consistency with previous? 
        # Actually user wants "best model", usually min loss or max metric. 
        # Let's stick to min loss as it's most stable for saving.
        best_loss = float('inf')
        
        save_path = CONFIG['model_dir'] / f"best_model_fold_{FOLD}.pth"

        for epoch in range(CONFIG['epochs']):
            train_loss, train_acc = train_one_epoch(model, train_loader, criterion, optimizer, device, scaler)
            val_loss, val_acc, val_f1, val_roc = validate(model, val_loader, criterion, device)
            
            print(f"Epoch {epoch+1}/{CONFIG['epochs']}")
            print(f"Train Loss: {train_loss:.4f} | Acc: {train_acc:.4f}")
            print(f"Val   Loss: {val_loss:.4f}   | Acc: {val_acc:.4f} | F1: {val_f1:.4f} | ROC: {val_roc:.4f}")
            
            # Save if Valid Loss Improves
            if val_loss < best_loss:
                print(f"🔥 Loss Improved ({best_loss:.4f} -> {val_loss:.4f}). Saving Model...")
                best_loss = val_loss
                torch.save(model.state_dict(), save_path)
        
        # Clean up to free memory
        del model, optimizer, scaler, train_loader, val_loader
        torch.cuda.empty_cache()
                
    print("\nTraining Complete for all Folds.")
