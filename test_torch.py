
import os
import sys

print(f"Python: {sys.version}")
print(f"Executable: {sys.executable}")

try:
    import numpy as np
    print(f"Numpy: {np.__version__}")
    import pandas as pd
    print(f"Pandas: {pd.__version__}")
    import albumentations as A
    print(f"Albumentations: {A.__version__}")
    import timm
    print(f"Timm: {timm.__version__}")
    from sklearn.metrics import accuracy_score
    print("Sklearn imported.")
except ImportError as e:
    print(f"Import Error: {e}")
    sys.exit(1)

try:
    import torch
    print(f"Torch: {torch.__version__}")
    print(f"CUDA Available: {torch.cuda.is_available()}")
    
    # Try creating a model
    model = timm.create_model("tf_efficientnet_b0", pretrained=True)
    print("Model created successfully.")
    
    if torch.cuda.is_available():
        model = model.cuda()
        print("Model moved to CUDA.")
        
    x = torch.randn(2, 3, 224, 224).cuda()
    y = model(x)
    print(f"Inference successful. Output shape: {y.shape}")

    # Test DataLoader
    from torch.utils.data import Dataset, DataLoader
    from PIL import Image
    
    class FakeDataset(Dataset):
        def __init__(self, length=10):
            self.len = length
        def __len__(self):
            return self.len
        def __getitem__(self, idx):
            # Create fake image
            img = np.zeros((224, 224, 3), dtype=np.uint8)
            # transform
            aug = A.Compose([A.Resize(224,224), A.Normalize(), A.pytorch.ToTensorV2()])
            img = aug(image=img)['image']
            return img, torch.tensor(0, dtype=torch.float32)
            
    ds = FakeDataset()
    # Test with same settings as notebook
    dl = DataLoader(ds, batch_size=2, num_workers=0, pin_memory=False)
    
    print("DataLoader created. Iterating...")
    for i, (imgs, lbls) in enumerate(dl):
        imgs = imgs.cuda()
        lbls = lbls.cuda()
        out = model(imgs)
        print(f"Batch {i} processed. Shape: {out.shape}")
        
    print("DataLoader iteration successful.")
    
except Exception as e:
    print(f"Torch/Model Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
