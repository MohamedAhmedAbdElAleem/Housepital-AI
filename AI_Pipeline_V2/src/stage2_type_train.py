
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
from sklearn.metrics import accuracy_score, f1_score, classification_report
from torch.utils.data import DataLoader, Dataset
from PIL import Image
import albumentations as A
from albumentations.pytorch import ToTensorV2

# Config
CONFIG = {
    "seed": 42,
    "img_size": 224,
    "batch_size": 64,
    "num_workers": 4,
    "epochs": 10, # Slightly more epochs for multi-class
    "lr": 1e-3,
    "model_name": "tf_efficientnet_b0",
    "model_dir": "../models/stage2_type/",
    "data_train_csv": "../data/loaders/wound_type_train.csv",
    "data_val_csv": "../data/loaders/wound_type_val.csv", # Use separate CSVs if they exist, seemingly they do
    "root_dir": "../"
}

# Resolve Paths
CURRENT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = CURRENT_DIR.parent
CONFIG["model_dir"] = PROJECT_ROOT / "models" / "stage2_type"
CONFIG["data_train_csv"] = PROJECT_ROOT / "data" / "loaders" / "wound_type_train.csv"
CONFIG["data_val_csv"] = PROJECT_ROOT / "data" / "loaders" / "wound_type_val.csv"
CONFIG["root_dir"] = PROJECT_ROOT

os.makedirs(CONFIG["model_dir"], exist_ok=True)

# Class Mapping (Alphabetical)
CLASS_NAMES = ['abrasion', 'bruise', 'burn', 'cut', 'diabetic_foot', 'laceration', 'surgical']
CLASS_TO_IDX = {name: i for i, name in enumerate(CLASS_NAMES)}
IDX_TO_CLASS = {i: name for i, name in enumerate(CLASS_NAMES)}

def seed_everything(seed):
    os.environ['PYTHONHASHSEED'] = str(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.backends.cudnn.deterministic = True

seed_everything(CONFIG['seed'])
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using Device: {device}")

class WoundTypeDataset(Dataset):
    def __init__(self, df, root_dir=None, transform=None):
        self.annotations = df.copy()
        
        # Filter out 'healthy' and any unknown classes
        self.annotations = self.annotations[self.annotations['class'].isin(CLASS_NAMES)].reset_index(drop=True)
        
        self.root_dir = Path(root_dir) if root_dir else Path(".")
        self.transform = transform
        
    def __len__(self):
        return len(self.annotations)

    def __getitem__(self, index):
        row = self.annotations.iloc[index]
        rel_path = row['path']
        rel_path = str(rel_path).replace('\\', os.sep).replace('/', os.sep)
        
        # Handle '..' prefix
        if rel_path.startswith(".."):
             img_path = self.root_dir / rel_path[3:]
        else:
             img_path = self.root_dir / rel_path
        
        try:
            image = Image.open(img_path).convert("RGB")
        except:
            print(f"Warning: Could not open {img_path}, using black image.")
            image = Image.new('RGB', (224, 224), color='black')
            
        label_str = row['class'] # Use 'class' column from CSV
        label = CLASS_TO_IDX[label_str]
        
        if self.transform:
            image = np.array(image)
            augmented = self.transform(image=image)
            image = augmented['image']
            
        return image, torch.tensor(label, dtype=torch.long)

def train_one_epoch(model, loader, criterion, optimizer, device, scaler=None):
    model.train()
    running_loss = 0.0
    preds_all = []
    targets_all = []
    
    pbar = tqdm(loader, desc="Training", leave=False, dynamic_ncols=True)
    
    for images, labels in pbar:
        images, labels = images.to(device), labels.to(device)
        
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
        
        preds = torch.argmax(outputs, dim=1)
        preds_all.extend(preds.detach().cpu().numpy())
        targets_all.extend(labels.detach().cpu().numpy())
        
        pbar.set_postfix(loss=loss.item())
        
    epoch_loss = running_loss / len(loader.dataset)
    acc = accuracy_score(targets_all, preds_all)
    
    return epoch_loss, acc

def validate(model, loader, criterion, device):
    model.eval()
    running_loss = 0.0
    preds_all = []
    targets_all = []
    
    with torch.no_grad():
        for images, labels in tqdm(loader, desc="Validating", leave=False, dynamic_ncols=True):
            images, labels = images.to(device), labels.to(device)
            
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            running_loss += loss.item() * images.size(0)
            preds = torch.argmax(outputs, dim=1)
            preds_all.extend(preds.cpu().numpy())
            targets_all.extend(labels.cpu().numpy())
            
    epoch_loss = running_loss / len(loader.dataset)
    acc = accuracy_score(targets_all, preds_all)
    f1 = f1_score(targets_all, preds_all, average='macro')
    
    return epoch_loss, acc, f1

if __name__ == "__main__":
    print("Initializing Stage 2 Training...")
    
    # Transforms
    train_transforms = A.Compose([
        A.Resize(CONFIG['img_size'], CONFIG['img_size']),
        A.HorizontalFlip(p=0.5),
        A.ShiftScaleRotate(shift_limit=0.0625, scale_limit=0.1, rotate_limit=30, p=0.5),
        A.RandomBrightnessContrast(p=0.2),
        A.CoarseDropout(max_holes=8, max_height=16, max_width=16, p=0.2), # Cutout
        A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ToTensorV2(),
    ])

    val_transforms = A.Compose([
        A.Resize(CONFIG['img_size'], CONFIG['img_size']),
        A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ToTensorV2(),
    ])

    # Load Dataframes
    if not CONFIG['data_train_csv'].exists():
        print(f"Error: {CONFIG['data_train_csv']} not found!")
        sys.exit(1)
        
    train_full = pd.read_csv(CONFIG['data_train_csv'])
    val_full = pd.read_csv(CONFIG['data_val_csv'])
    
    # Create Datasets (Filtering happens inside)
    train_ds = WoundTypeDataset(train_full, root_dir=CONFIG['root_dir'], transform=train_transforms)
    val_ds = WoundTypeDataset(val_full, root_dir=CONFIG['root_dir'], transform=val_transforms)
    
    print(f"Train Samples (Filtered): {len(train_ds)}")
    print(f"Val Samples (Filtered): {len(val_ds)}")
    
    train_loader = DataLoader(train_ds, batch_size=CONFIG['batch_size'], shuffle=True, num_workers=CONFIG['num_workers'])
    val_loader = DataLoader(val_ds, batch_size=CONFIG['batch_size'], shuffle=False, num_workers=CONFIG['num_workers'])
    
    # Model
    print(f"Creating Model: {CONFIG['model_name']} with {len(CLASS_NAMES)} classes")
    model = timm.create_model(CONFIG['model_name'], pretrained=True, num_classes=len(CLASS_NAMES)).to(device)
    
    # Loss & Optimizer
    # Optional: Weighted Loss if unbalanced
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.AdamW(model.parameters(), lr=CONFIG['lr'])
    scaler = torch.cuda.amp.GradScaler()
    
    # Training Loop
    best_acc = 0.0
    save_path = CONFIG['model_dir'] / "best_model.pth"
    
    for epoch in range(CONFIG['epochs']):
        print(f"\nEpoch {epoch+1}/{CONFIG['epochs']}")
        train_loss, train_acc = train_one_epoch(model, train_loader, criterion, optimizer, device, scaler)
        val_loss, val_acc, val_f1 = validate(model, val_loader, criterion, device)
        
        print(f"Train Loss: {train_loss:.4f} | Acc: {train_acc:.4f}")
        print(f"Val   Loss: {val_loss:.4f} | Acc: {val_acc:.4f} | F1: {val_f1:.4f}")
        
        if val_acc > best_acc:
             print(f"🔥 Accuracy Improved ({best_acc:.4f} -> {val_acc:.4f}). Saving Model...")
             best_acc = val_acc
             torch.save(model.state_dict(), save_path)
             
    print("Training Complete!")
