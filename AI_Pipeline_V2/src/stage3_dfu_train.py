import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from pathlib import Path
import pandas as pd
import numpy as np
from PIL import Image
import timm
from tqdm import tqdm
import albumentations as A
from albumentations.pytorch import ToTensorV2
from sklearn.metrics import accuracy_score, f1_score, classification_report

# --- CONFIG ---
PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_ROOT / "data" / "raw" / "severity_dfu"
TRAIN_CSV = PROJECT_ROOT / "data" / "loaders" / "dfu_severity_train.csv"
VAL_CSV = PROJECT_ROOT / "data" / "loaders" / "dfu_severity_val.csv"
MODEL_SAVE_DIR = PROJECT_ROOT / "models" / "stage3_severity"
MODEL_SAVE_DIR.mkdir(parents=True, exist_ok=True)

IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 20
LEARNING_RATE = 1e-4
DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
NUM_WORKERS = 0 # Windows compatibility

# Classes (Ordinal)
CLASSES = ['grade_1', 'grade_2', 'grade_3', 'grade_4']
CLASS_TO_IDX = {name: i for i, name in enumerate(CLASSES)}

print(f"Project Root: {PROJECT_ROOT}")
print(f"Device: {DEVICE}")

# --- DATASET ---
class DfuSeverityDataset(Dataset):
    def __init__(self, csv_file, root_dir, transform=None):
        self.df = pd.read_csv(csv_file)
        self.root_dir = root_dir
        self.transform = transform
        
        # Filter valid classes only (just in case)
        self.df = self.df[self.df['class'].isin(CLASSES)].reset_index(drop=True)
        
    def __len__(self):
        return len(self.df)
    
    def __getitem__(self, idx):
        row = self.df.iloc[idx]
        cls_name = row['class']
        label = CLASS_TO_IDX[cls_name]
        
        # Path handling (CSV handles relative paths differently sometimes)
        # CSV path: ..\data\raw\severity_dfu\grade_2\grade_2_01071.jpg
        # We need absolute path
        rel_path = str(row['path']).replace('\\', os.sep).replace('/', os.sep)
        
        # If path starts with .., resolve from project root/data/loaders usually, 
        # but here we can just join with PROJECT_ROOT if we Strip the relative parts
        # A robust way:
        if "data" in rel_path:
             # Extract from 'data' onwards
             clean_path = rel_path[rel_path.find("data"):]
             img_path = PROJECT_ROOT / clean_path
        else:
             img_path = self.root_dir / rel_path
             
        try:
            image = Image.open(img_path).convert("RGB")
            image = np.array(image)
            
            if self.transform:
                augmented = self.transform(image=image)
                image = augmented['image']
                
            return image, torch.tensor(label, dtype=torch.long)
            
        except Exception as e:
            print(f"Error loading {img_path}: {e}")
            # Return dummy (black image) to avoid crash
            dummy = torch.zeros((3, IMG_SIZE, IMG_SIZE))
            return dummy, torch.tensor(label, dtype=torch.long)

# --- TRANSFORMS ---
train_transform = A.Compose([
    A.Resize(IMG_SIZE, IMG_SIZE),
    A.HorizontalFlip(p=0.5),
    A.VerticalFlip(p=0.5),
    A.Rotate(limit=30, p=0.5),
    A.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2, hue=0.1, p=0.5),
    A.CoarseDropout(max_holes=8, max_height=20, max_width=20, p=0.3),
    A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ToTensorV2(),
])

val_transform = A.Compose([
    A.Resize(IMG_SIZE, IMG_SIZE),
    A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ToTensorV2(),
])

# --- TRAINING FUNCTIONS ---
def train_one_epoch(model, loader, criterion, optimizer, scaler):
    model.train()
    running_loss = 0.0
    all_preds = []
    all_labels = []
    
    pbar = tqdm(loader, desc="Training")
    for images, labels in pbar:
        images, labels = images.to(DEVICE), labels.to(DEVICE)
        
        optimizer.zero_grad()
        
        with torch.cuda.amp.autocast():
            outputs = model(images)
            loss = criterion(outputs, labels)
            
        scaler.scale(loss).backward()
        scaler.step(optimizer)
        scaler.update()
        
        running_loss += loss.item()
        
        # Metrics
        probs = torch.softmax(outputs, dim=1)
        preds = torch.argmax(probs, dim=1)
        all_preds.extend(preds.cpu().numpy())
        all_labels.extend(labels.cpu().numpy())
        
        pbar.set_postfix(loss=loss.item())
        
    epoch_loss = running_loss / len(loader)
    epoch_acc = accuracy_score(all_labels, all_preds)
    return epoch_loss, epoch_acc

def validate(model, loader, criterion):
    model.eval()
    running_loss = 0.0
    all_preds = []
    all_labels = []
    
    with torch.no_grad():
        for images, labels in tqdm(loader, desc="Validation"):
            images, labels = images.to(DEVICE), labels.to(DEVICE)
            
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            running_loss += loss.item()
            
            probs = torch.softmax(outputs, dim=1)
            preds = torch.argmax(probs, dim=1)
            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())
            
    epoch_loss = running_loss / len(loader)
    epoch_acc = accuracy_score(all_labels, all_preds)
    epoch_f1 = f1_score(all_labels, all_preds, average='weighted')
    
    print("\n--- Validation Report ---")
    print(classification_report(all_labels, all_preds, target_names=CLASSES))
    
    return epoch_loss, epoch_acc, epoch_f1

# --- MAIN ---
if __name__ == "__main__":
    # Load Data
    train_dataset = DfuSeverityDataset(TRAIN_CSV, DATA_DIR, transform=train_transform)
    val_dataset = DfuSeverityDataset(VAL_CSV, DATA_DIR, transform=val_transform)
    
    train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True,  num_workers=NUM_WORKERS, pin_memory=True)
    val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False, num_workers=NUM_WORKERS, pin_memory=True)
    
    print(f"Train samples: {len(train_dataset)}")
    print(f"Val samples: {len(val_dataset)}")
    
    # Model
    print("Creating Model (EfficientNet-B0)...")
    model = timm.create_model('tf_efficientnet_b0', pretrained=True, num_classes=len(CLASSES))
    model = model.to(DEVICE)
    
    # Loss & Optimizer
    # Class weights could be useful if imbalanced, but starting simple
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.AdamW(model.parameters(), lr=LEARNING_RATE)
    scaler = torch.cuda.amp.GradScaler()
    
    # Training Loop
    best_f1 = 0.0
    
    for epoch in range(EPOCHS):
        print(f"\nEpoch {epoch+1}/{EPOCHS}")
        
        train_loss, train_acc = train_one_epoch(model, train_loader, criterion, optimizer, scaler)
        val_loss, val_acc, val_f1 = validate(model, val_loader, criterion)
        
        print(f"Train Loss: {train_loss:.4f} | Acc: {train_acc:.4f}")
        print(f"Val Loss: {val_loss:.4f} | Acc: {val_acc:.4f} | F1: {val_f1:.4f}")
        
        if val_f1 > best_f1:
            best_f1 = val_f1
            save_path = MODEL_SAVE_DIR / "best_model.pth"
            torch.save(model.state_dict(), save_path)
            print(f"🔥 New Best Model saved to {save_path}")
            
    print("Training Complete!")
