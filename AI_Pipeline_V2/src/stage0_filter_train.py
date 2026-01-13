
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import pandas as pd
import numpy as np
from pathlib import Path
from PIL import Image
import albumentations as A
from albumentations.pytorch import ToTensorV2
import timm
from sklearn.model_selection import train_test_split
from tqdm import tqdm
import os
import glob

# Configuration
BASE_DIR = Path(__file__).resolve().parent.parent # Points to AI_Pipeline_V2
CONFIG = {
    "seed": 42,
    "img_size": 224, # EfficientNet/MobileNet standard
    "batch_size": 128, # Increased batch size for speed (MobileNet is tiny)
    "num_workers": 0,
    "epochs": 10,
    "lr": 1e-3,
    "model_name": "mobilenetv3_small_100", 
    "model_dir": BASE_DIR / "models/stage0_filter/",
    "positive_csv": BASE_DIR / "data/loaders/train_folds.csv", 
    "negative_dir": BASE_DIR / "data/raw/background_class",    
    "root_dir": BASE_DIR
}

# Device
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using Device: {device}")

# Seed
def seed_everything(seed=42):
    os.environ['PYTHONHASHSEED'] = str(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.backends.cudnn.deterministic = True

seed_everything(CONFIG['seed'])

# Dataset Class
class InputFilterDataset(Dataset):
    def __init__(self, df, transform=None):
        self.df = df
        self.transform = transform
        
    def __len__(self):
        return len(self.df)
    
    def __getitem__(self, idx):
        row = self.df.iloc[idx]
        img_path = row['path']
        label = row['label'] # 0 = Irrelevant, 1 = Relevant
        
        try:
            image = np.array(Image.open(img_path).convert("RGB"))
            
            if self.transform:
                augmented = self.transform(image=image)
                image = augmented['image']
                
            return image, torch.tensor(label, dtype=torch.float)
            
        except Exception as e:
            print(f"Error loading {img_path}: {e}")
            # Return dummy tensor to prevent crash, ideally should handle better
            return torch.zeros((3, CONFIG['img_size'], CONFIG['img_size'])), torch.tensor(label, dtype=torch.float)

# Logic to prepare unified dataframe
def prepare_data():
    # 1. Positives (Wounds + Healthy Skin)
    # We load the existing CSV, but we only need 'path'. Label is automatically 1.
    df_pos = pd.read_csv(CONFIG['positive_csv'])
    df_pos = df_pos[['path']].copy()
    df_pos['label'] = 1
    
    # 2. Negatives (CIFAR Background)
    neg_files = glob.glob(str(Path(CONFIG['negative_dir']) / "*.jpg"))
    df_neg = pd.DataFrame({'path': neg_files, 'label': 0})
    
    print(f"Found {len(df_pos)} Positive samples (Skin/Wound)")
    print(f"Found {len(df_neg)} Negative samples (Background)")
    
    if len(df_neg) == 0:
        raise ValueError("No negative data found! Did you run download_negative_data.py?")

    # 3. Concatenate
    full_df = pd.concat([df_pos, df_neg], axis=0).sample(frac=1, random_state=CONFIG['seed']).reset_index(drop=True)
    
    return full_df

# Training Functions
def train_one_epoch(model, loader, criterion, optimizer, device, scaler):
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0
    
    pbar = tqdm(loader, desc="Training", leave=False)
    
    for images, labels in pbar:
        images = images.to(device)
        labels = labels.to(device).unsqueeze(1)
        
        optimizer.zero_grad()
        
        with torch.cuda.amp.autocast(enabled=True):
            outputs = model(images)
            loss = criterion(outputs, labels)
            
        scaler.scale(loss).backward()
        scaler.step(optimizer)
        scaler.update()
        
        running_loss += loss.item() * images.size(0)
        
        preds = (torch.sigmoid(outputs) > 0.5).float()
        correct += (preds == labels).sum().item()
        total += labels.size(0)
        
        pbar.set_postfix({'loss': loss.item()})
        
    return running_loss / total, correct / total

def validate(model, loader, criterion, device):
    model.eval()
    running_loss = 0.0
    correct = 0
    total = 0
    
    pbar = tqdm(loader, desc="Validating", leave=False)
    
    with torch.no_grad():
        for images, labels in pbar:
            images = images.to(device)
            labels = labels.to(device).unsqueeze(1)
            
            with torch.cuda.amp.autocast(enabled=True):
                outputs = model(images)
                loss = criterion(outputs, labels)
                
            running_loss += loss.item() * images.size(0)
            
            preds = (torch.sigmoid(outputs) > 0.5).float()
            correct += (preds == labels).sum().item()
            total += labels.size(0)
            
    return running_loss / total, correct / total

if __name__ == "__main__":
    # Create Model Dir
    Path(CONFIG['model_dir']).mkdir(parents=True, exist_ok=True)
    
    print("Preparing Data...")
    df = prepare_data()
    
    # Split Train/Val (90/10 - simple split is enough for this task)
    train_df, val_df = train_test_split(df, test_size=0.1, random_state=CONFIG['seed'], stratify=df['label'])
    
    print(f"Train Size: {len(train_df)} | Val Size: {len(val_df)}")
    
    # Transforms
    train_transforms = A.Compose([
        A.Resize(CONFIG['img_size'], CONFIG['img_size']),
        A.HorizontalFlip(p=0.5),
        A.VerticalFlip(p=0.5),
        A.Rotate(limit=30, p=0.5),
        A.RandomBrightnessContrast(p=0.2),
        A.Normalize(),
        ToTensorV2(),
    ])

    val_transforms = A.Compose([
        A.Resize(CONFIG['img_size'], CONFIG['img_size']),
        A.Normalize(),
        ToTensorV2(),
    ])
    
    # Loaders
    train_ds = InputFilterDataset(train_df, transform=train_transforms)
    val_ds = InputFilterDataset(val_df, transform=val_transforms)
    
    train_loader = DataLoader(train_ds, batch_size=CONFIG['batch_size'], shuffle=True, num_workers=CONFIG['num_workers'], pin_memory=False)
    val_loader = DataLoader(val_ds, batch_size=CONFIG['batch_size'], shuffle=False, num_workers=CONFIG['num_workers'], pin_memory=False)
    
    # Model
    model = timm.create_model(CONFIG['model_name'], pretrained=True, num_classes=1).to(device)
    
    criterion = nn.BCEWithLogitsLoss()
    optimizer = optim.AdamW(model.parameters(), lr=CONFIG['lr'])
    scaler = torch.cuda.amp.GradScaler()
    
    best_acc = 0.0
    save_path = Path(CONFIG['model_dir']) / "stage0_mobilenet_v3.pth"
    
    print(f"Starting Training ({CONFIG['model_name']})...")
    
    for epoch in range(CONFIG['epochs']):
        train_loss, train_acc = train_one_epoch(model, train_loader, criterion, optimizer, device, scaler)
        val_loss, val_acc = validate(model, val_loader, criterion, device)
        
        print(f"Epoch {epoch+1}/{CONFIG['epochs']}")
        print(f"Train Loss: {train_loss:.4f} | Acc: {train_acc:.4f}")
        print(f"Val   Loss: {val_loss:.4f}   | Acc: {val_acc:.4f}")
        
        if val_acc > best_acc:
            print(f"🔥 Accuracy Improved ({best_acc:.4f} -> {val_acc:.4f}). Saving Model...")
            best_acc = val_acc
            torch.save(model.state_dict(), save_path)
            
    print("Training Complete.")
