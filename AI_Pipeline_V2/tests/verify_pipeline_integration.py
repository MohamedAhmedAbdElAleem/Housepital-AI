
import sys
import os
from pathlib import Path

# Add src to path
sys.path.append(str(Path(__file__).parent.parent / "src"))

from inference_pipeline import InferencePipeline

def test_pipeline():
    print("Initializing Pipeline...")
    try:
        pipeline = InferencePipeline()
    except Exception as e:
        print(f"Failed to initialize pipeline: {e}")
        return

    print("\n--- Model Class Names ---")
    print(f"Stage 0 Classes: {pipeline.stage0_model.names}")

    # Test Images
    base_data_path = Path(r"f:\Housepital-AI\Housepital-AI\AI_Pipeline_V2\data\raw")
    
    test_cases = [
        ("Diabetic Foot", base_data_path / "type_classification/diabetic_foot/diabetic_foot_00000.jpg"),
        ("Healthy", base_data_path / "type_classification/healthy/healthy_00000.jpg"),
        ("Background", base_data_path / "background_class_highres/bg_highres_00000.jpg")
    ]

    print("\n--- Running Predictions ---")
    for name, path in test_cases:
        print(f"\nTesting: {name}")
        print(f"Path: {path}")
        if not path.exists():
            print("  [ERROR] File not found!")
            continue
            
        try:
            result = pipeline.predict(path)
            print(f"  Result: {result}")
        except Exception as e:
            print(f"  [ERROR] Prediction failed: {e}")

if __name__ == "__main__":
    test_pipeline()
