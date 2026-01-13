
import cv2
import torch
import numpy as np
from PIL import Image
from pathlib import Path
from ultralytics import YOLO
import timm


# Config
# Ideally these should be loaded from a config file
STAGE0_MODEL_PATH = Path("F:/Housepital-AI/Housepital-AI/AI_Pipeline_V2/models/stage0_yolo_v11/weights/best.pt")
STAGE1_MODEL_PATH = Path("F:/Housepital-AI/Housepital-AI/AI_Pipeline_V2/models/stage1_binary/best_model_fold_0.pth")
STAGE2_MODEL_PATH = Path("F:/Housepital-AI/Housepital-AI/AI_Pipeline_V2/models/stage2_type/best_model.pth")
STAGE3_MODEL_PATH = Path("F:/Housepital-AI/Housepital-AI/AI_Pipeline_V2/models/stage3_severity/best_model.pth")

# Stage 2 Classes (Must match training order)
STAGE2_CLASSES = ['abrasion', 'bruise', 'burn', 'cut', 'diabetic_foot', 'laceration', 'surgical']
STAGE3_CLASSES = ['grade_1', 'grade_2', 'grade_3', 'grade_4']

class InferencePipeline:
    def __init__(self, stage0_path=None, stage1_path=None, stage2_path=None, stage3_path=None):
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        # Load Stage 0 (YOLOv11)
        s0_path = stage0_path if stage0_path else STAGE0_MODEL_PATH
        if not Path(s0_path).exists():
            raise FileNotFoundError(f"Stage 0 Model not found at {s0_path}")
        self.stage0_model = YOLO(s0_path)
        print(f"✅ Stage 0 (YOLOv11) Loaded on {self.device}")
        
        # Load Stage 1 (EfficientNet Binary)
        s1_path = stage1_path if stage1_path else STAGE1_MODEL_PATH
        if not Path(s1_path).exists():
            raise FileNotFoundError(f"Stage 1 Model not found at {s1_path}")
        
        self.stage1_model = timm.create_model('tf_efficientnet_b0_ns', pretrained=False, num_classes=1)
        s1_checkpoint = torch.load(s1_path, map_location=self.device)
        if isinstance(s1_checkpoint, dict) and 'model_state_dict' in s1_checkpoint:
            self.stage1_model.load_state_dict(s1_checkpoint['model_state_dict'])
        else:
            self.stage1_model.load_state_dict(s1_checkpoint)
        self.stage1_model.to(self.device)
        self.stage1_model.eval()
        print(f"✅ Stage 1 (EfficientNet Binary) Loaded on {self.device}")
        
        # Load Stage 2 (EfficientNet Multi-class)
        s2_path = stage2_path if stage2_path else STAGE2_MODEL_PATH
        if not Path(s2_path).exists():
             print(f"⚠️ Stage 2 Model not found at {s2_path}. Running without Stage 2.")
             self.stage2_model = None
        else:
            self.stage2_model = timm.create_model('tf_efficientnet_b0', pretrained=False, num_classes=len(STAGE2_CLASSES))
            s2_checkpoint = torch.load(s2_path, map_location=self.device)
            # Stage 2 saved state dict directly usually, but let's handle both
            if isinstance(s2_checkpoint, dict) and 'model_state_dict' in s2_checkpoint:
                self.stage2_model.load_state_dict(s2_checkpoint['model_state_dict'])
            else:
                self.stage2_model.load_state_dict(s2_checkpoint)
            
            self.stage2_model.to(self.device).eval()
            print(f"✅ Stage 2 (Wound Type) Loaded on {self.device}")

        # Load Stage 3 (DFU Severity - EfficientNet-B0)
        s3_path = stage3_path if stage3_path else STAGE3_MODEL_PATH
        if not Path(s3_path).exists():
             print(f"⚠️ Stage 3 Model not found at {s3_path}. Running without Stage 3.")
             self.stage3_model = None
        else:
            self.stage3_model = timm.create_model('tf_efficientnet_b0', pretrained=False, num_classes=len(STAGE3_CLASSES))
            s3_checkpoint = torch.load(s3_path, map_location=self.device)
            if isinstance(s3_checkpoint, dict) and 'model_state_dict' in s3_checkpoint:
                self.stage3_model.load_state_dict(s3_checkpoint['model_state_dict'])
            else:
                self.stage3_model.load_state_dict(s3_checkpoint)
            
            self.stage3_model.to(self.device).eval()
            print(f"✅ Stage 3 (DFU Severity) Loaded on {self.device}")
        
        # Common Transforms
        import torchvision.transforms as T
        self.common_transform = T.Compose([
            T.Resize((224, 224)),
            T.ToTensor(),
            T.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])

    def predict(self, image_path_or_array):
        """
        Runs the full pipeline:
        Image -> Stage 0 -> (If Relevant) -> Stage 1 -> (If Wound) -> Stage 2 -> (If DFU) -> Stage 3 -> Result
        """
        results = {}
        
        # 1. Preprocessing (Handle path or numpy/PIL)
        if isinstance(image_path_or_array, (str, Path)):
            img_src = str(image_path_or_array)
            img_pil = Image.open(image_path_or_array).convert('RGB')
        else:
            img_src = image_path_or_array # For YOLO
            img_pil = Image.fromarray(image_path_or_array).convert('RGB')
            
        # --- STAGE 0: VALIDATION ---
        # YOLO inference
        yolo_res = self.stage0_model(img_src, verbose=False)[0]
        top1_idx = yolo_res.probs.top1
        s0_class = yolo_res.names[top1_idx]
        s0_conf = yolo_res.probs.top1conf.item()
        
        results['stage0'] = {
            'class': s0_class,
            'confidence': s0_conf,
            'is_relevant': s0_class in ['wound', 'skin', 'diabetic_foot', 'healthy'] # Adjust based on actual YOLO classes
        }
        
        if not results['stage0']['is_relevant'] and s0_class != 'diabetic_foot': # Example override
            results['final_verdict'] = f"Irrelevant ({s0_class})"
            return results
            
        # --- STAGE 1: TRIAGE (Binary) ---
        # Prepare for EfficientNet
        img_tensor = self.common_transform(img_pil).unsqueeze(0).to(self.device)
        
        with torch.no_grad():
            s1_out = self.stage1_model(img_tensor)
            prob = torch.sigmoid(s1_out).item()
            
        is_wound = prob > 0.5
        results['stage1'] = {
            'probability': prob,
            'is_wound': is_wound
        }
        
        if not is_wound:
            results['final_verdict'] = "Healthy Skin"
            return results
            
        # --- STAGE 2: WOUND TYPE (Multi-class) ---
        wound_type = "unknown"
        if self.stage2_model:
            with torch.no_grad():
                s2_out = self.stage2_model(img_tensor)
                s2_probs = torch.softmax(s2_out, dim=1)[0]
                top1_idx = torch.argmax(s2_probs).item()
                top1_prob = s2_probs[top1_idx].item()
                
            wound_type = STAGE2_CLASSES[top1_idx]
            results['stage2'] = {
                'type': wound_type,
                'confidence': top1_prob,
                'all_probs': {cls: conf for cls, conf in zip(STAGE2_CLASSES, s2_probs.tolist())}
            }
            results['final_verdict'] = f"Wound Detected: {wound_type}"
        else:
            results['final_verdict'] = "Wound Detected (Type Unknown - Stage 2 Missing)"
        
        # --- STAGE 3: DFU SEVERITY (If DFU) ---
        if wound_type == 'diabetic_foot' and self.stage3_model:
            with torch.no_grad():
                s3_out = self.stage3_model(img_tensor)
                s3_probs = torch.softmax(s3_out, dim=1)[0]
                s3_top1_idx = torch.argmax(s3_probs).item()
                s3_conf = s3_probs[s3_top1_idx].item()
                severity_grade = STAGE3_CLASSES[s3_top1_idx]
            
            results['stage3'] = {
                'grade': severity_grade,
                'confidence': s3_conf,
                'all_probs': {cls: conf for cls, conf in zip(STAGE3_CLASSES, s3_probs.tolist())}
            }
            results['final_verdict'] += f" ({severity_grade})"

        return results

if __name__ == "__main__":
    # Test
    try:
        pipeline = InferencePipeline()
        print("Pipeline initialized. Ready.")
    except Exception as e:
        print(f"Init failed: {e}")
