import pandas as pd
from pathlib import Path
from sklearn.model_selection import StratifiedKFold, GroupKFold, train_test_split
import numpy as np
import re

# Configuration
DATA_ROOT = Path(r"f:\Housepital-AI\Housepital-AI\AI_Pipeline_V2\data\raw\type_classification")
OUTPUT_DIR = Path(r"f:\Housepital-AI\Housepital-AI\AI_Pipeline_V2\data\loaders")
RANDOM_SEED = 42
BLOCK_SIZE = 100 # Group frames into blocks of 100 to simulate video clips

def extract_frame_number(filename):
    # Extract number from filename like "cut_01525.jpg" -> 1525
    match = re.search(r'(\d+)', filename)
    if match:
        return int(match.group(1))
    return 0

def create_splits():
    # 1. Collect all data
    data = []
    print(f"Scanning data from: {DATA_ROOT}")
    
    if not DATA_ROOT.exists():
        print(f"Error: Data directory not found: {DATA_ROOT}")
        return

    classes = [d.name for d in DATA_ROOT.iterdir() if d.is_dir()]
    print(f"Found classes: {classes}")

    for class_name in classes:
        class_dir = DATA_ROOT / class_name
        files = list(class_dir.glob("*"))
        valid_files = [f for f in files if f.suffix.lower() in ['.jpg', '.jpeg', '.png']]
        
        for f in valid_files:
            frame_num = extract_frame_number(f.name)
            # Create a group ID. e.g., "cut_15" for range 1500-1599
            group_id = f"{class_name}_{frame_num // BLOCK_SIZE}"
            
            data.append({
                "path": str(f),
                "label": class_name,
                "group_id": group_id
            })
            
    df = pd.DataFrame(data)
    print(f"Total images found: {len(df)}")
    print(f"Unique Groups found: {df['group_id'].nunique()}")
    print("Class distribution:")
    print(df['label'].value_counts())

    # 2. Split out Test Set (15%) - respecting groups
    # We use GroupShuffleSplit or similar logic, or simply split by unique groups
    
    # Simple manual split by groups to verify leakage prevention
    # Get unique groups per class to stratify manually
    train_val_indices = []
    test_indices = []
    
    # We want a stratified split of groups
    gkf_test = GroupKFold(n_splits=int(1/0.15)) # Approx split
    
    # To reliably split 15% test, we iterate splitting groups
    # Let's use a simpler heuristic: assign groups randomly to test
    mapper = {g: np.random.rand() for g in df['group_id'].unique()}
    df['random_split'] = df['group_id'].map(mapper)
    
    # Select roughly 15% for test, ensuring class balance logic roughly holds if random is uniform
    # Better: Stratified Group Split is hard without external lib, so we will use GroupKFold(5) and keep 1 fold as Test?
    # No, user wants separated Test.
    
    # Let's use sklearn's GroupShuffleSplit? No, just manual logic for clarity.
    # Assign groups to Test if random < 0.15
    # Warning: This might unbalance classes. 
    # Proper way: Iterate classes, pick 15% of GROUPS for test.
    
    groups_train = []
    groups_test = []
    
    for cls in df['label'].unique():
        cls_groups = df[df['label'] == cls]['group_id'].unique()
        np.random.shuffle(cls_groups)
        n_test = max(1, int(len(cls_groups) * 0.15))
        
        groups_test.extend(cls_groups[:n_test])
        groups_train.extend(cls_groups[n_test:])
        
    test_df = df[df['group_id'].isin(groups_test)].reset_index(drop=True)
    train_val_df = df[df['group_id'].isin(groups_train)].reset_index(drop=True)
    
    print(f"\nTest set size: {len(test_df)} (Groups: {len(groups_test)})")
    print(f"Train/Val set size: {len(train_val_df)} (Groups: {len(groups_train)})")
    
    # 3. Create Cross-Validation Folds (GroupKFold)
    # We use GroupKFold on the remaining Data
    gkf = GroupKFold(n_splits=5)
    
    train_val_df['fold'] = -1
    
    # Note: GroupKFold doesn't take random_state, it's deterministic based on group order.
    # So we shuffle df first if we want randomness (we already shuffled groups implicitly?)
    # Actually explicit shuffle is better.
    train_val_df = train_val_df.sample(frac=1, random_state=RANDOM_SEED).reset_index(drop=True)
    
    for fold, (train_idx, val_idx) in enumerate(gkf.split(train_val_df, groups=train_val_df['group_id'])):
        train_val_df.loc[val_idx, 'fold'] = fold
        
    print(f"Folds created: 5")
    
    # Check distribution
    for i in range(5):
        fold_n = len(train_val_df[train_val_df['fold'] == i])
        print(f"Fold {i} size: {fold_n}")

    # 4. Save
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    test_csv = OUTPUT_DIR / "test.csv"
    train_folds_csv = OUTPUT_DIR / "train_folds.csv"
    
    test_df.to_csv(test_csv, index=False)
    train_val_df.to_csv(train_folds_csv, index=False)
    
    print(f"\nSaved splits to:")
    print(f"- {test_csv}")
    print(f"- {train_folds_csv}")

if __name__ == "__main__":
    np.random.seed(RANDOM_SEED)
    create_splits()
