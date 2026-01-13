
import os
import sys
from pathlib import Path
from inference_pipeline import InferencePipeline

# Config
PROJECT_ROOT = Path(__file__).parent.parent
DATA_DIR = PROJECT_ROOT / "data" / "raw"

# Test Images
DFU_IMG = DATA_DIR / "severity_dfu" / "grade_1" / "grade_1_00000.jpg"
ABRASION_IMG = DATA_DIR / "type_classification" / "abrasion" / "abrasion_00000.jpg"

def verify_pipeline():
    print(f"Project Root: {PROJECT_ROOT}")
    
    # 1. Initialize Pipeline
    print("\n--- Initializing Pipeline ---")
    try:
        pipeline = InferencePipeline()
    except Exception as e:
        print(f"❌ Failed to initialize pipeline: {e}")
        return

    # 2. Test DFU Image (Should trigger Stage 3)
    print(f"\n--- Testing DFU Image: {DFU_IMG} ---")
    if DFU_IMG.exists():
        res_dfu = pipeline.predict(DFU_IMG)
        print("Result Summary:")
        print(f"  Final Verdict: {res_dfu.get('final_verdict')}")
        
        # Check Stage 3
        if 'stage3' in res_dfu:
            print(f"  ✅ Stage 3 Triggered! Grade: {res_dfu['stage3']['grade']} (Conf: {res_dfu['stage3']['confidence']:.2f})")
        else:
            print("  ❌ Stage 3 NOT Triggered (Unexpected for DFU image)")
            print(f"  Stage 2 Output: {res_dfu.get('stage2', 'Missing')}")
    else:
        print(f"⚠️ DFU Test Image not found at {DFU_IMG}")

    # 3. Test Abrasion Image (Should NOT trigger Stage 3)
    print(f"\n--- Testing Abrasion Image: {ABRASION_IMG} ---")
    if ABRASION_IMG.exists():
        res_abr = pipeline.predict(ABRASION_IMG)
        print("Result Summary:")
        print(f"  Final Verdict: {res_abr.get('final_verdict')}")
        
        # Check Stage 3
        if 'stage3' in res_abr:
            print(f"  ❌ Stage 3 Triggered! (Unexpected for Abrasion image)")
        else:
            print("  ✅ Stage 3 NOT Triggered (Correct)")
            print(f"  Stage 2 Output: {res_abr.get('stage2', 'Missing')}")
    else:
        print(f"⚠️ Abrasion Test Image not found at {ABRASION_IMG}")

if __name__ == "__main__":
    verify_pipeline()
