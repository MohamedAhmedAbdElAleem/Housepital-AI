"""
Housepital AI Medical Triage - Clinical BERT Training Script
=============================================================
Target: 90%+ accuracy on 4-class triage classification
Model: Bio_ClinicalBERT (emilyalsentzer/Bio_ClinicalBERT)

To run on Google Colab:
1. Upload generated_symptom_texts_clean.csv to Colab
2. Run: !pip install transformers datasets scikit-learn torch accelerate
3. Run this script

Author: AI Engineer
Date: December 2024
"""

import os
import torch
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, f1_score
from sklearn.utils.class_weight import compute_class_weight
from torch.utils.data import Dataset, DataLoader
from transformers import (
    AutoTokenizer, 
    AutoModelForSequenceClassification,
    TrainingArguments,
    Trainer,
    EarlyStoppingCallback
)
import warnings
warnings.filterwarnings('ignore')

# =============================================================================
# CONFIGURATION
# =============================================================================
CONFIG = {
    # Model
    "model_name": "emilyalsentzer/Bio_ClinicalBERT",
    "num_labels": 4,
    
    # Data
    "data_path": "generated_symptom_texts_clean.csv",
    "max_length": 128,  # Symptom texts are short
    "test_size": 0.1,
    "val_size": 0.1,
    
    # Training
    "learning_rate": 2e-5,
    "batch_size": 16,
    "num_epochs": 5,
    "warmup_ratio": 0.1,
    "weight_decay": 0.01,
    
    # Output
    "output_dir": "./triage_model",
    "random_seed": 42,
}

# Label mappings
LABEL2ID = {"Emergency": 0, "High": 1, "Medium": 2, "Low": 3}
ID2LABEL = {v: k for k, v in LABEL2ID.items()}

print("=" * 60)
print("🏥 HOUSEPITAL AI - CLINICAL BERT TRIAGE TRAINING")
print("=" * 60)
print(f"Model: {CONFIG['model_name']}")
print(f"Target: 90%+ accuracy on 4-class classification")
print(f"Device: {'cuda' if torch.cuda.is_available() else 'cpu'}")
print("=" * 60)


# =============================================================================
# DATA LOADING & PREPROCESSING
# =============================================================================
class TriageDataset(Dataset):
    """Custom dataset for triage classification."""
    
    def __init__(self, texts, labels, tokenizer, max_length):
        self.texts = texts
        self.labels = labels
        self.tokenizer = tokenizer
        self.max_length = max_length
    
    def __len__(self):
        return len(self.texts)
    
    def __getitem__(self, idx):
        text = str(self.texts[idx])
        label = self.labels[idx]
        
        encoding = self.tokenizer(
            text,
            truncation=True,
            padding='max_length',
            max_length=self.max_length,
            return_tensors='pt'
        )
        
        return {
            'input_ids': encoding['input_ids'].squeeze(0),
            'attention_mask': encoding['attention_mask'].squeeze(0),
            'labels': torch.tensor(label, dtype=torch.long)
        }


def load_and_prepare_data():
    """Load and split the dataset."""
    print("\n📊 Loading data...")
    
    df = pd.read_csv(CONFIG['data_path'])
    print(f"   Total samples: {len(df):,}")
    
    # Map labels to IDs
    df['label'] = df['risk_level'].map(LABEL2ID)
    
    # Print distribution
    print("\n📊 Class Distribution:")
    for risk, count in df['risk_level'].value_counts().sort_index().items():
        pct = count / len(df) * 100
        print(f"   {risk:12}: {count:5,} ({pct:5.1f}%)")
    
    # Split: 80% train, 10% val, 10% test
    texts = df['text'].values
    labels = df['label'].values
    
    # First split: train+val vs test
    X_temp, X_test, y_temp, y_test = train_test_split(
        texts, labels, 
        test_size=CONFIG['test_size'], 
        stratify=labels, 
        random_state=CONFIG['random_seed']
    )
    
    # Second split: train vs val
    val_ratio = CONFIG['val_size'] / (1 - CONFIG['test_size'])
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp,
        test_size=val_ratio,
        stratify=y_temp,
        random_state=CONFIG['random_seed']
    )
    
    print(f"\n✂️ Data Split:")
    print(f"   Train: {len(X_train):,}")
    print(f"   Val:   {len(X_val):,}")
    print(f"   Test:  {len(X_test):,}")
    
    return X_train, X_val, X_test, y_train, y_val, y_test


def compute_class_weights(y_train):
    """Compute class weights for imbalanced data."""
    classes = np.unique(y_train)
    weights = compute_class_weight('balanced', classes=classes, y=y_train)
    class_weights = torch.tensor(weights, dtype=torch.float32)
    print(f"\n⚖️ Class Weights: {dict(zip([ID2LABEL[i] for i in range(4)], weights.round(3)))}")
    return class_weights


# =============================================================================
# MODEL & TRAINING
# =============================================================================
class WeightedTrainer(Trainer):
    """Custom trainer with class weights for imbalanced data."""
    
    def __init__(self, class_weights=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.class_weights = class_weights
        
    def compute_loss(self, model, inputs, return_outputs=False, num_items_in_batch=None):
        labels = inputs.pop("labels")
        outputs = model(**inputs)
        logits = outputs.logits
        
        if self.class_weights is not None:
            weight = self.class_weights.to(logits.device)
            loss_fn = torch.nn.CrossEntropyLoss(weight=weight)
        else:
            loss_fn = torch.nn.CrossEntropyLoss()
            
        loss = loss_fn(logits, labels)
        
        return (loss, outputs) if return_outputs else loss


def compute_metrics(eval_pred):
    """Compute accuracy and F1 for evaluation."""
    predictions, labels = eval_pred
    predictions = np.argmax(predictions, axis=1)
    
    acc = accuracy_score(labels, predictions)
    f1 = f1_score(labels, predictions, average='macro')
    
    return {
        'accuracy': acc,
        'f1': f1,
    }


def train_model(X_train, X_val, y_train, y_val, class_weights):
    """Train the Clinical BERT model."""
    
    print("\n🧠 Loading Bio_ClinicalBERT...")
    
    # Load tokenizer and model
    tokenizer = AutoTokenizer.from_pretrained(CONFIG['model_name'])
    model = AutoModelForSequenceClassification.from_pretrained(
        CONFIG['model_name'],
        num_labels=CONFIG['num_labels'],
        id2label=ID2LABEL,
        label2id=LABEL2ID,
        ignore_mismatched_sizes=True
    )
    
    print(f"   Model loaded: {model.num_parameters():,} parameters")
    
    # Create datasets
    train_dataset = TriageDataset(X_train, y_train, tokenizer, CONFIG['max_length'])
    val_dataset = TriageDataset(X_val, y_val, tokenizer, CONFIG['max_length'])
    
    # Training arguments
    training_args = TrainingArguments(
        output_dir=CONFIG['output_dir'],
        num_train_epochs=CONFIG['num_epochs'],
        per_device_train_batch_size=CONFIG['batch_size'],
        per_device_eval_batch_size=CONFIG['batch_size'] * 2,
        learning_rate=CONFIG['learning_rate'],
        warmup_ratio=CONFIG['warmup_ratio'],
        weight_decay=CONFIG['weight_decay'],
        logging_dir='./logs',
        logging_steps=50,
        eval_strategy="epoch",
        save_strategy="epoch",
        load_best_model_at_end=True,
        metric_for_best_model='f1',
        greater_is_better=True,
        fp16=torch.cuda.is_available(),  # Use FP16 on GPU
        report_to="none",  # Disable wandb/tensorboard
        seed=CONFIG['random_seed'],
    )
    
    # Create trainer with class weights
    trainer = WeightedTrainer(
        class_weights=class_weights,
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=val_dataset,
        compute_metrics=compute_metrics,
        callbacks=[EarlyStoppingCallback(early_stopping_patience=2)]
    )
    
    print("\n🚀 Starting training...")
    print("=" * 60)
    
    # Train
    trainer.train()
    
    print("=" * 60)
    print("✅ Training complete!")
    
    # Save model and tokenizer
    trainer.save_model(CONFIG['output_dir'])
    tokenizer.save_pretrained(CONFIG['output_dir'])
    print(f"💾 Model saved to {CONFIG['output_dir']}")
    
    return model, tokenizer, trainer


# =============================================================================
# EVALUATION
# =============================================================================
def evaluate_model(model, tokenizer, X_test, y_test):
    """Comprehensive evaluation on test set."""
    
    print("\n" + "=" * 60)
    print("📊 FINAL EVALUATION ON TEST SET")
    print("=" * 60)
    
    model.eval()
    device = next(model.parameters()).device
    
    predictions = []
    
    # Predict in batches
    batch_size = 32
    for i in range(0, len(X_test), batch_size):
        batch_texts = X_test[i:i+batch_size]
        
        inputs = tokenizer(
            list(batch_texts),
            truncation=True,
            padding=True,
            max_length=CONFIG['max_length'],
            return_tensors='pt'
        ).to(device)
        
        with torch.no_grad():
            outputs = model(**inputs)
            preds = torch.argmax(outputs.logits, dim=1).cpu().numpy()
            predictions.extend(preds)
    
    predictions = np.array(predictions)
    
    # Calculate metrics
    accuracy = accuracy_score(y_test, predictions)
    f1 = f1_score(y_test, predictions, average='macro')
    
    print(f"\n🎯 ACCURACY: {accuracy:.2%}")
    print(f"🎯 MACRO F1: {f1:.4f}")
    
    if accuracy >= 0.90:
        print("\n🎉 " + "=" * 50)
        print("🎉 TARGET ACHIEVED: 90%+ ACCURACY!")
        print("🎉 " + "=" * 50)
    else:
        print(f"\n⚠️ {0.90 - accuracy:.1%} away from 90% target")
    
    # Classification report
    print("\n📋 Classification Report:")
    print(classification_report(
        y_test, predictions,
        target_names=['Emergency', 'High', 'Medium', 'Low'],
        digits=4
    ))
    
    # Confusion matrix
    print("🔢 Confusion Matrix (E, H, M, L):")
    cm = confusion_matrix(y_test, predictions)
    print(cm)
    
    # Per-class accuracy
    print("\n📊 Per-Class Accuracy:")
    for i, label in enumerate(['Emergency', 'High', 'Medium', 'Low']):
        class_mask = y_test == i
        class_acc = (predictions[class_mask] == i).mean()
        print(f"   {label:12}: {class_acc:.2%}")
    
    # Check Emergency recall (critical!)
    emergency_mask = y_test == 0
    emergency_recall = (predictions[emergency_mask] == 0).mean()
    print(f"\n⚠️ EMERGENCY RECALL: {emergency_recall:.2%}")
    if emergency_recall < 0.95:
        print("   WARNING: Emergency recall should be ≥95% for safety!")
    
    return accuracy, f1, predictions


def quick_test(model, tokenizer):
    """Test with sample symptoms."""
    
    print("\n" + "=" * 60)
    print("🔬 QUICK TEST WITH SAMPLE SYMPTOMS")
    print("=" * 60)
    
    test_cases = [
        ("I have severe chest pain radiating to my left arm and I'm sweating profusely", "Emergency"),
        ("I can't breathe properly and my lips are turning blue", "Emergency"),
        ("High fever of 104°F with confusion and stiff neck", "High"),
        ("The sharp chest pain is constant and makes every day a struggle", "High"),
        ("I've had a mild headache for two days and feel tired", "Medium"),
        ("Persistent cold symptoms and runny nose for over a week", "Medium"),
        ("I have a small rash on my arm that's been there for a week", "Low"),
        ("Minor cut on my finger from cooking", "Low"),
    ]
    
    model.eval()
    device = next(model.parameters()).device
    
    correct = 0
    for symptom, expected in test_cases:
        inputs = tokenizer(
            symptom,
            truncation=True,
            padding=True,
            max_length=CONFIG['max_length'],
            return_tensors='pt'
        ).to(device)
        
        with torch.no_grad():
            outputs = model(**inputs)
            pred_id = torch.argmax(outputs.logits, dim=1).item()
            predicted = ID2LABEL[pred_id]
        
        match = "✅" if predicted == expected else "❌"
        if predicted == expected:
            correct += 1
        
        print(f"{match} Expected: {expected:10} | Got: {predicted:10} | {symptom[:50]}...")
    
    print(f"\nQuick Test: {correct}/{len(test_cases)} ({correct/len(test_cases):.0%})")


# =============================================================================
# MAIN
# =============================================================================
def main():
    """Main training pipeline."""
    
    # Set seed
    torch.manual_seed(CONFIG['random_seed'])
    np.random.seed(CONFIG['random_seed'])
    
    # Load data
    X_train, X_val, X_test, y_train, y_val, y_test = load_and_prepare_data()
    
    # Compute class weights
    class_weights = compute_class_weights(y_train)
    
    # Train model
    model, tokenizer, trainer = train_model(X_train, X_val, y_train, y_val, class_weights)
    
    # Move model to GPU if available
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model.to(device)
    
    # Evaluate
    accuracy, f1, predictions = evaluate_model(model, tokenizer, X_test, y_test)
    
    # Quick test
    quick_test(model, tokenizer)
    
    print("\n" + "=" * 60)
    print("✅ TRAINING COMPLETE")
    print("=" * 60)
    print(f"Model saved to: {CONFIG['output_dir']}")
    print(f"Final Accuracy: {accuracy:.2%}")
    print(f"Final Macro F1: {f1:.4f}")
    
    return model, tokenizer, accuracy


if __name__ == "__main__":
    model, tokenizer, accuracy = main()
