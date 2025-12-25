# 🏥 Housepital AI Medical Triage - Clinical BERT Training

## Quick Start (Google Colab)

### Step 1: Install Dependencies
```python
!pip install transformers datasets torch scikit-learn accelerate -q
```

### Step 2: Upload Data
Upload `generated_symptom_texts_clean.csv` to Colab (use the file upload button)

### Step 3: Upload Training Script
Upload `train_clinical_bert.py` to Colab

### Step 4: Run Training
```python
!python train_clinical_bert.py
```

Training takes ~30-45 minutes on Colab GPU (T4).

---

## Expected Output

```
🏥 HOUSEPITAL AI - CLINICAL BERT TRIAGE TRAINING
============================================================
Model: emilyalsentzer/Bio_ClinicalBERT
Target: 90%+ accuracy on 4-class classification
Device: cuda

📊 Loading data...
   Total samples: 13,439

📊 Class Distribution:
   Emergency   : 2,316 (17.2%)
   High        : 2,090 (15.6%)
   Medium      : 3,855 (28.7%)
   Low         : 5,178 (38.5%)

✂️ Data Split:
   Train: 10,751
   Val:   1,344
   Test:  1,344

🚀 Starting training...
[Training progress bars...]

📊 FINAL EVALUATION ON TEST SET
🎯 ACCURACY: XX.XX%
🎯 MACRO F1: X.XXXX

✅ TRAINING COMPLETE
```

---

## After Training

1. Download the `triage_model/` folder
2. Use `inference_clinical_bert.py` for predictions

### Usage:
```python
from inference_clinical_bert import TriageClassifier

classifier = TriageClassifier("./triage_model")
result = classifier.predict("I have severe chest pain")
print(result['risk_level'])  # "Emergency"
```

---

## Files in This Project

| File | Description |
|------|-------------|
| `generated_symptom_texts_clean.csv` | Balanced training data (13,439 samples) |
| `train_clinical_bert.py` | Training script (run on Colab) |
| `inference_clinical_bert.py` | Production inference |
| `augment_high_risk_data.py` | Data augmentation script |
| `triage_model/` | Trained model (created after training) |
