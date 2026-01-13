
import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image
import timm
import argparse
from pathlib import Path
import matplotlib.pyplot as plt
import glob
import os

# Configuration
CONFIG = {
    "img_size": 224,
    "model_name": "mobilenetv3_small_100",
    "model_path": "../models/stage0_filter/stage0_mobilenet_v3.pth",
    "threshold": 0.5
}

# Device
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

def load_model(model_path):
    print(f"Loading model from {model_path}...")
    model = timm.create_model(CONFIG['model_name'], pretrained=False, num_classes=1)
    
    # Load weights
    try:
        state_dict = torch.load(model_path, map_location=device)
        model.load_state_dict(state_dict)
    except Exception as e:
        print(f"Error loading weights: {e}")
        return None
        
    model.to(device)
    model.eval()
    return model

def predict_image(model, image_path):
    # Transforms (Must match training)
    preprocess = transforms.Compose([
        transforms.Resize((CONFIG['img_size'], CONFIG['img_size'])),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]) # Standard ImageNet norm used in training
    ])
    
    try:
        image = Image.open(image_path).convert("RGB")
        img_tensor = preprocess(image).unsqueeze(0).to(device)
        
        with torch.no_grad():
            output = model(img_tensor)
            prob = torch.sigmoid(output).item()
            
        return prob
    except Exception as e:
        print(f"Could not process {image_path}: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Stage 0: Input Filter Test")
    parser.add_argument("--input", type=str, help="Path to image or folder")
    parser.add_argument("--threshold", type=float, default=0.5, help="Probability threshold for 'Relevant'")
    
    args = parser.parse_args()
    
    # Resolve paths relative to script
    BASE_DIR = Path(__file__).resolve().parent.parent
    model_path = BASE_DIR / "models/stage0_filter/stage0_mobilenet_v3.pth"
    
    model = load_model(str(model_path))
    if not model:
        return

    # Determine input type
    if not args.input:
        print("Please provide input path using --input")
        # Default test: Try a few from raw data if available
        test_dir = BASE_DIR / "data/raw/background_class"
        if test_dir.exists():
            print(f"No input provided. Testing random samples from {test_dir}...")
            files = list(test_dir.glob("*.jpg"))[:5]
            for f in files:
                prob = predict_image(model, str(f))
                label = "RELEVANT (Skin/Wound)" if prob > args.threshold else "IRRELEVANT (Background)"
                print(f"[{label}] Prob: {prob:.4f} - {f.name}")
        return

    input_path = Path(args.input)
    
    if input_path.is_file():
        prob = predict_image(model, str(input_path))
        label = "✅ RELEVANT (Skin)" if prob > args.threshold else "⛔ IRRELEVANT (Trash)"
        color = "green" if prob > args.threshold else "red"
        print(f"\nImage: {input_path.name}")
        print(f"Result: {label}")
        print(f"Confidence (Skin): {prob:.2%}")
        
    elif input_path.is_dir():
        print(f"\nScanning folder: {input_path}...")
        files = list(input_path.glob("*.*"))
        valid_exts = ['.jpg', '.jpeg', '.png', '.bmp']
        files = [f for f in files if f.suffix.lower() in valid_exts]
        
        print(f"{'Filename':<30} | {'Prediction':<20} | {'Score':<10}")
        print("-" * 65)
        
        for f in files:
            prob = predict_image(model, str(f))
            if prob is not None:
                pred = "✅ Skin" if prob > args.threshold else "⛔ Trash"
                print(f"{f.name[:30]:<30} | {pred:<20} | {prob:.4f}")

if __name__ == "__main__":
    main()
