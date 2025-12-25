# 🏥 Housepital AI Medical Triage System

**92.55% Accuracy | 99.4% Emergency Recall**

## Quick Start

```bash
# Clone
git clone https://github.com/iOmarSh/Housepital_Triage.git
cd Housepital_Triage

# Install
pip install pandas scikit-learn

# Train (30 seconds)
python train_final_production.py
```

## Files

| File | Description |
|------|-------------|
| `generated_symptom_texts_clean.csv` | Original dataset (15K samples) |
| `fix_labels.py` | Corrects medical labels |
| `triage_dataset_corrected.csv` | Corrected dataset (10K balanced) |
| `train_final_production.py` | Training script (RandomForest + Rules) |
| `triage_production_model.pkl` | Trained model |

## Results

```
🎯 ACCURACY:         92.55%
⚠️ EMERGENCY RECALL: 99.40%

Per-class:
- Emergency: 99.4%
- High:      81.8%
- Medium:    89.0%
- Low:       100%
```

## Usage

```python
import pickle

# Load model
with open('triage_production_model.pkl', 'rb') as f:
    data = pickle.load(f)
    vectorizer = data['vectorizer']
    model = data['model']
    reverse_map = data['reverse_map']

# Predict
text = "I have severe chest pain"
X = vectorizer.transform([text])
pred = reverse_map[model.predict(X)[0]]
print(pred)  # "Emergency"
```
