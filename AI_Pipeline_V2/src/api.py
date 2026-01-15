
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from inference_pipeline import InferencePipeline
from PIL import Image
import io
import uvicorn
import torch

# Initialize App
app = FastAPI(
    title="Housepital-AI Inference API",
    description="Multi-stage Wound Assessment Pipeline API",
    version="1.0"
)

# CORS (Allow all for development)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global Pipeline Variable
pipeline = None

@app.on_event("startup")
async def startup_event():
    global pipeline
    print("⏳ Loading Models...")
    try:
        pipeline = InferencePipeline()
        print("✅ Models Loaded Successfully!")
    except Exception as e:
        print(f"❌ Error loading models: {e}")

@app.get("/")
def home():
    return {"message": "Housepital-AI Inference API is Running"}

@app.get("/health")
def health_check():
    if pipeline:
        return {"status": "healthy", "gpu": torch.cuda.is_available()}
    return {"status": "loading_or_failed"}

@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):
    global pipeline
    if not pipeline:
        raise HTTPException(status_code=503, detail="Model pipeline not initialized")

    print(f"📷 Received file: {file.filename}, content_type: {file.content_type}")
    
    # Validate Content Type - be more flexible
    valid_types = ["image/jpeg", "image/png", "image/jpg", "application/octet-stream"]
    if file.content_type and file.content_type not in valid_types:
        print(f"❌ Invalid content type: {file.content_type}")
        raise HTTPException(status_code=400, detail=f"Invalid file type: {file.content_type}. Only JPEG/PNG supported.")

    try:
        # Read Image
        contents = await file.read()
        print(f"📦 Read {len(contents)} bytes")
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        print(f"🖼️ Image size: {image.size}")
        
        # Run Inference
        import numpy as np
        img_arr = np.array(image)
        
        results = pipeline.predict(img_arr)
        print(f"✅ Prediction: {results.get('final_verdict', 'unknown')}")
        
        # Add filename to result
        results['filename'] = file.filename
        
        return results

    except Exception as e:
        print(f"Error processing image: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("api:app", host="localhost", port=8000, reload=True)
# for swagger use : /docs
