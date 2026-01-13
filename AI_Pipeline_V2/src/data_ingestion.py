import os
import shutil
import hashlib
from tqdm import tqdm
from pathlib import Path

# --- CONFIGURATION ---
SOURCE_ROOT = Path("f:/Housepital-AI/Housepital-AI")
DEST_ROOT =  Path("f:/Housepital-AI/Housepital-AI/AI_Pipeline_V2/data/raw")

# Mapping: Destination Class -> List of Source Paths (relative to SOURCE_ROOT)
# We prioritize "Wound_dataset" sources as they seem cleaner.
# "Surgical" & "Normal" taken from Kaggle working dirs.
TYPE_MAPPING = {
    "abrasion": [
        "dfu_dataset/Wound_dataset/Abrasions",
        "dfu_dataset/dataset/kaggle/working/dataset/val/Abrasions",
        "dfu_dataset/Wound Multitask Data Set/Wound Images/Abrasion",
        "dfu_dataset/basic-wound-classify.v2i.folder/train/abrasion",
        "dfu_dataset/basic-wound-classify.v2i.folder/valid/abrasion",
        "dfu_dataset/extra_data/abrasion/train/abrasion",
        "dfu_dataset/extra_data/abrasion/test/abrasion",
        "dfu_dataset/extra_data/abrasion/valid/abrasion", 
    ],
    "bruise": [
        "dfu_dataset/Wound_dataset/Bruises",
        "dfu_dataset/dataset/kaggle/working/dataset/val/Bruises",
        "dfu_dataset/Wound Multitask Data Set/Wound Images/Bruise",
        "dfu_dataset/basic-wound-classify.v2i.folder/train/bruise",
        "dfu_dataset/basic-wound-classify.v2i.folder/valid/bruise",
        "dfu_dataset/extra_data/Bruise.v3-bruise.folder/train/BRUISE 161", # Added based on folder view
    ],
    "burn": [
        "dfu_dataset/Wound_dataset/Burns",
        "dfu_dataset/basic-wound-classify.v2i.folder/train/burn",
        "dfu_dataset/basic-wound-classify.v2i.folder/valid/burn",
        "dfu_dataset/Human_skin_burns", 
        "dfu_dataset/skin_burn_dataset/burns",
    ],
    "cut": [
        "dfu_dataset/Wound_dataset/Cut",
        "dfu_dataset/Wound_dataset/Stab_wound",
        "dfu_dataset/Wound Multitask Data Set/Wound Images/Cut",
        "dfu_dataset/extra_data/cuts_severity_2class.v2-cuts_severity.folder/train/serious_cut",
        "dfu_dataset/extra_data/cuts_severity_2class.v2-cuts_severity.folder/train/simple_cut",
        "dfu_dataset/extra_data/cuts_severity_2class.v2-cuts_severity.folder/valid/serious_cut",
        "dfu_dataset/extra_data/cuts_severity_2class.v2-cuts_severity.folder/valid/simple_cut",
        "dfu_dataset/extra_data/cuts_severity_2class.v2-cuts_severity.folder/test/serious_cut",
        "dfu_dataset/extra_data/cuts_severity_2class.v2-cuts_severity.folder/test/simple_cut",
    ],
    "laceration": [
        "dfu_dataset/Wound_dataset/Laceration",
        "dfu_dataset/Wound Multitask Data Set/Wound Images/Laceration",
        "dfu_dataset/basic-wound-classify.v2i.folder/train/laceration",
        "dfu_dataset/basic-wound-classify.v2i.folder/valid/laceration",
    ],
    "diabetic_foot": [
        "dfu_dataset/dfu_dataset/train/Grade 1",
        "dfu_dataset/dfu_dataset/train/Grade 2",
        "dfu_dataset/dfu_dataset/train/Grade 3",
        "dfu_dataset/dfu_dataset/train/Grade 4",
        "dfu_dataset/extra_data/wound-classification-using-images-and-locations-main/dataset/Train/Train/D",
        "dfu_dataset/extra_data/wound-classification-using-images-and-locations-main/dataset/Test/Test/D",
    ],
    "surgical": [
        "dfu_dataset/dataset/kaggle/working/dataset/val/Surgical Wounds",
        "dfu_dataset/dataset/kaggle/working/dataset/test/Surgical Wounds",
        "dfu_dataset/Wound Multitask Data Set/Wound Images/Surgical",
        "dfu_dataset/extra_data/wound-classification-using-images-and-locations-main/dataset/Train/Train/S",
        "dfu_dataset/extra_data/wound-classification-using-images-and-locations-main/dataset/Test/Test/S",
    ],
    "healthy": [
        "dfu_dataset/dataset/kaggle/working/dataset/val/Normal",
        "dfu_dataset/dataset/kaggle/working/dataset/test/Normal",
        "dfu_dataset/Wound Multitask Data Set/Fresh Images",
        "dfu_dataset/basic-wound-classify.v2i.folder/train/normal skin",
        "dfu_dataset/basic-wound-classify.v2i.folder/valid/normal skin",
        "dfu_dataset/extra_data/wound-classification-using-images-and-locations-main/dataset/Train/Train/N",
        "dfu_dataset/extra_data/wound-classification-using-images-and-locations-main/dataset/Test/Test/N",
    ]
}

# For Severity Model: We map specific Grades to a separate folder
SEVERITY_MAPPING = {
    "grade_1": ["dfu_dataset/dfu_dataset/train/Grade 1"],
    "grade_2": ["dfu_dataset/dfu_dataset/train/Grade 2"],
    "grade_3": ["dfu_dataset/dfu_dataset/train/Grade 3"],
    "grade_4": ["dfu_dataset/dfu_dataset/train/Grade 4"],
}

def get_file_hash(filepath):
    """Calculate MD5 hash to detect duplicates."""
    hasher = hashlib.md5()
    with open(filepath, 'rb') as f:
        buf = f.read()
        hasher.update(buf)
    return hasher.hexdigest()

def ingest_data():
    print("Starting Data Ingestion...")
    
    # 1. Ingest Wound Types (and Build Binary Positive Set Implicitly)
    for class_name, sources in TYPE_MAPPING.items():
        dest_dir = DEST_ROOT / "type_classification" / class_name
        dest_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"\nProcessing Class: {class_name} -> {dest_dir}")
        count = 0
        seen_hashes = set()
        
        for rel_source in sources:
            source_path = SOURCE_ROOT / rel_source
            if not source_path.exists():
                print(f"  Warning: Source not found: {source_path}")
                continue
                
            files = [f for f in os.listdir(source_path) if f.lower().endswith(('.jpg', '.png', '.jpeg'))]
            print(f"  Source: {rel_source} ({len(files)} potential images)")
            
            for f in tqdm(files, desc=f"  Copying {rel_source}", leave=False):
                src_file = source_path / f
                
                # prevent duplicates by Content Hash
                file_hash = get_file_hash(src_file)
                if file_hash in seen_hashes:
                    continue
                seen_hashes.add(file_hash)
                
                # Copy
                dest_file = dest_dir / f"{class_name}_{count:05d}{src_file.suffix}"
                shutil.copy2(src_file, dest_file)
                count += 1
                
        print(f"  -> Final Count for {class_name}: {count}")

    # 2. Ingest DFU Severity (Separate Dataset)
    print("\nProcessing DFU Severity Dataset...")
    for grade, sources in SEVERITY_MAPPING.items():
        dest_dir = DEST_ROOT / "severity_dfu" / grade
        dest_dir.mkdir(parents=True, exist_ok=True)
        
        count = 0 
        for rel_source in sources:
            source_path = SOURCE_ROOT / rel_source
            files = [f for f in os.listdir(source_path) if f.lower().endswith(('.jpg', '.png', '.jpeg'))]
            
            for f in tqdm(files, desc=f"  Copying {grade}", leave=False):
                src_file = source_path / f
                # Simple copy for severity (we know they are likely unique per folder)
                dest_file = dest_dir / f"{grade}_{count:05d}{src_file.suffix}"
                shutil.copy2(src_file, dest_file)
                count += 1
        print(f"  -> Final Count for {grade}: {count}")

    print("\nIngestion Complete!")

if __name__ == "__main__":
    ingest_data()
