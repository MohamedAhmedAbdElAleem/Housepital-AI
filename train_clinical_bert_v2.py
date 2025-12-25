"""
Housepital AI Medical Triage - Clinical BERT Training V2
=========================================================
IMPROVED VERSION with better regularization to reach 90%+ accuracy

Key improvements:
1. Lower learning rate (1e-5 instead of 2e-5)
2. Stronger dropout in classification head
3. Label smoothing
4. Gradient clipping
5. More warmup steps
6. Longer max_length for complete symptom capture

Author: AI Engineer
Date: December 2024
"""

import os
import torch
import torch.nn as nn
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, f1_score
from sklearn.utils.class_weight import compute_class_weight
from torch.utils.data import Dataset, DataLoader
from transformers import (
    AutoTokenizer, 
    AutoModel,
    TrainingArguments,
    Trainer,
    EarlyStoppingCallback
)
import warnings
warnings.filterwarnings('ignore')

# =============================================================================
# CONFIGURATION - OPTIMIZED FOR 90%+ ACCURACY
# =============================================================================
CONFIG = {
    # Model
    "model_name": "emilyalsentzer/Bio_ClinicalBERT",
    "num_labels": 4,
    
    # Data
    "data_path": "generated_symptom_texts_clean.csv",
    "max_length": 256,  # Increased from 128 to capture full symptoms
    "test_size": 0.1,
    "val_size": 0.1,
    
    # Training - OPTIMIZED
    "learning_rate": 1e-5,  # Lower LR to prevent overfitting
    "batch_size": 16,
    "num_epochs": 10,  # More epochs with early stopping
    "warmup_ratio": 0.2,  # More warmup
    "weight_decay": 0.1,  # Stronger regularization
    "dropout": 0.5,  # Higher dropout
    "label_smoothing": 0.1,  # Prevent overconfidence
    "max_grad_norm": 1.0,  # Gradient clipping
    
    # Output
    "output_dir": "./triage_model_v2",
    "random_seed": 42,
}

# Label mappings
LABEL2ID = {"Emergency": 0, "High": 1, "Medium": 2, "Low": 3}
ID2LABEL = {v: k for k, v in LABEL2ID.items()}

print("=" * 60)
print("🏥 HOUSEPITAL AI - CLINICAL BERT TRIAGE V2")
print("=" * 60)
print(f"Model: {CONFIG['model_name']}")
print(f"Target: 90%+ accuracy")
print(f"Device: {'cuda' if torch.cuda.is_available() else 'cpu'}")
print("\n🔧 Optimizations:")
print(f"   Learning Rate: {CONFIG['learning_rate']} (lower)")
print(f"   Dropout: {CONFIG['dropout']} (higher)")
print(f"   Label Smoothing: {CONFIG['label_smoothing']}")
print(f"   Weight Decay: {CONFIG['weight_decay']}")
print(f"   Max Length: {CONFIG['max_length']}")
print("=" * 60)


# =============================================================================
# CUSTOM MODEL WITH BETTER CLASSIFICATION HEAD
# =============================================================================
class ClinicalBERTClassifier(nn.Module):
    """Clinical BERT with improved classification head."""
    
    def __init__(self, model_name, num_labels, dropout=0.5):
        super().__init__()
        self.bert = AutoModel.from_pretrained(model_name)
        self.dropout1 = nn.Dropout(dropout)
        self.fc1 = nn.Linear(768, 256)
        self.bn1 = nn.BatchNorm1d(256)
        self.dropout2 = nn.Dropout(dropout)
        self.fc2 = nn.Linear(256, num_labels)
        self.relu = nn.ReLU()
        
    def forward(self, input_ids, attention_mask, labels=None):
        outputs = self.bert(input_ids=input_ids, attention_mask=attention_mask)
        pooled = outputs.last_hidden_state[:, 0, :]  # CLS token
        
        x = self.dropout1(pooled)
        x = self.fc1(x)
        x = self.bn1(x)
        x = self.relu(x)
        x = self.dropout2(x)
        logits = self.fc2(x)
        
        loss = None
        if labels is not None:
            loss_fn = nn.CrossEntropyLoss(label_smoothing=CONFIG['label_smoothing'])
            loss = loss_fn(logits, labels)
            
        return {"loss": loss, "logits": logits}


# =============================================================================
# DATA LOADING
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
    
    # Remove duplicates
    original_len = len(df)
    df = df.drop_duplicates(subset=['text'])
    if len(df) < original_len:
        print(f"   Removed {original_len - len(df)} duplicates")
    
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
    
    X_temp, X_test, y_temp, y_test = train_test_split(
        texts, labels, 
        test_size=CONFIG['test_size'], 
        stratify=labels, 
        random_state=CONFIG['random_seed']
    )
    
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


# =============================================================================
# TRAINING
# =============================================================================
def train_model(X_train, X_val, y_train, y_val):
    """Train the improved Clinical BERT model."""
    
    print("\n🧠 Loading Bio_ClinicalBERT with improved head...")
    
    # Load tokenizer
    tokenizer = AutoTokenizer.from_pretrained(CONFIG['model_name'])
    
    # Create custom model
    model = ClinicalBERTClassifier(
        CONFIG['model_name'], 
        CONFIG['num_labels'],
        CONFIG['dropout']
    )
    
    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"   Total parameters: {total_params:,}")
    print(f"   Trainable: {trainable_params:,}")
    
    # Create datasets
    train_dataset = TriageDataset(X_train, y_train, tokenizer, CONFIG['max_length'])
    val_dataset = TriageDataset(X_val, y_val, tokenizer, CONFIG['max_length'])
    
    # Compute class weights for weighted loss
    classes = np.unique(y_train)
    weights = compute_class_weight('balanced', classes=classes, y=y_train)
    print(f"\n⚖️ Class Weights: {dict(zip([ID2LABEL[i] for i in range(4)], weights.round(3)))}")
    
    # Training arguments
    training_args = TrainingArguments(
        output_dir=CONFIG['output_dir'],
        num_train_epochs=CONFIG['num_epochs'],
        per_device_train_batch_size=CONFIG['batch_size'],
        per_device_eval_batch_size=CONFIG['batch_size'] * 2,
        learning_rate=CONFIG['learning_rate'],
        warmup_ratio=CONFIG['warmup_ratio'],
        weight_decay=CONFIG['weight_decay'],
        max_grad_norm=CONFIG['max_grad_norm'],
        logging_dir='./logs',
        logging_steps=100,
        eval_strategy="epoch",
        save_strategy="epoch",
        load_best_model_at_end=True,
        metric_for_best_model='f1',
        greater_is_better=True,
        fp16=torch.cuda.is_available(),
        report_to="none",
        seed=CONFIG['random_seed'],
        dataloader_drop_last=True,  # Helps with BatchNorm
    )
    
    # Custom trainer
    class CustomTrainer(Trainer):
        def compute_loss(self, model, inputs, return_outputs=False, num_items_in_batch=None):
            labels = inputs.pop("labels")
            outputs = model(**inputs, labels=labels)
            loss = outputs["loss"]
            return (loss, outputs) if return_outputs else loss
    
    def compute_metrics(eval_pred):
        predictions, labels = eval_pred
        if isinstance(predictions, tuple):
            predictions = predictions[0]
        predictions = np.argmax(predictions, axis=1)
        
        acc = accuracy_score(labels, predictions)
        f1 = f1_score(labels, predictions, average='macro')
        
        return {'accuracy': acc, 'f1': f1}
    
    trainer = CustomTrainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=val_dataset,
        compute_metrics=compute_metrics,
        callbacks=[EarlyStoppingCallback(early_stopping_patience=3)]
    )
    
    print("\n🚀 Starting training with improved settings...")
    print("=" * 60)
    
    trainer.train()
    
    print("=" * 60)
    print("✅ Training complete!")
    
    # Save model
    torch.save(model.state_dict(), f"{CONFIG['output_dir']}/model.pt")
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
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model.to(device)
    
    predictions = []
    all_probs = []
    
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
            logits = outputs["logits"]
            probs = torch.softmax(logits, dim=1)
            preds = torch.argmax(logits, dim=1).cpu().numpy()
            predictions.extend(preds)
            all_probs.extend(probs.cpu().numpy())
    
    predictions = np.array(predictions)
    
    # Metrics
    accuracy = accuracy_score(y_test, predictions)
    f1 = f1_score(y_test, predictions, average='macro')
    
    print(f"\n🎯 ACCURACY: {accuracy:.2%}")
    print(f"🎯 MACRO F1: {f1:.4f}")
    
    if accuracy >= 0.90:
        print("\n🎉 " + "=" * 50)
        print("🎉 TARGET ACHIEVED: 90%+ ACCURACY!")
        print("🎉 " + "=" * 50)
    elif accuracy >= 0.85:
        print(f"\n📈 Good progress! {0.90 - accuracy:.1%} away from 90%")
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
    
    # Emergency recall
    emergency_mask = y_test == 0
    emergency_recall = (predictions[emergency_mask] == 0).mean()
    print(f"\n⚠️ EMERGENCY RECALL: {emergency_recall:.2%}")
    
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
            pred_id = torch.argmax(outputs["logits"], dim=1).item()
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
    
    torch.manual_seed(CONFIG['random_seed'])
    np.random.seed(CONFIG['random_seed'])
    
    # Load data
    X_train, X_val, X_test, y_train, y_val, y_test = load_and_prepare_data()
    
    # Train
    model, tokenizer, trainer = train_model(X_train, X_val, y_train, y_val)
    
    # Move to GPU
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model.to(device)
    
    # Evaluate
    accuracy, f1, predictions = evaluate_model(model, tokenizer, X_test, y_test)
    
    # Quick test
    quick_test(model, tokenizer)
    
    print("\n" + "=" * 60)
    print("✅ TRAINING V2 COMPLETE")
    print("=" * 60)
    print(f"Model saved to: {CONFIG['output_dir']}")
    print(f"Final Accuracy: {accuracy:.2%}")
    print(f"Final Macro F1: {f1:.4f}")
    
    return model, tokenizer, accuracy


if __name__ == "__main__":
    model, tokenizer, accuracy = main()
