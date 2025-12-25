"""
RULE-FIRST TRIAGE SYSTEM (90%+ TARGET)
======================================
A completely different approach:

1. PRIMARY: Rule-based keyword matching (like real medical triage)
2. SECONDARY: Simple ML (TF-IDF + LogisticRegression) for ambiguous cases

This mimics how ACTUAL triage nurses work:
- First, check for obvious emergencies
- Then, check for obvious low-risk
- Only use judgment for unclear cases

Key insight: BERT overfits because it tries to learn features that
don't have consistent patterns. Rules don't overfit.
"""

import pandas as pd
import numpy as np
import re
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import pickle
import warnings
warnings.filterwarnings('ignore')

print("=" * 70)
print("🏥 RULE-FIRST TRIAGE SYSTEM")
print("=" * 70)

# =============================================================================
# COMPREHENSIVE MEDICAL RULES (Like a real triage protocol)
# =============================================================================

# EMERGENCY: Life-threatening, requires immediate attention
EMERGENCY_PATTERNS = [
    # Cardiac
    r"chest pain.*(radiat|arm|jaw|shoulder)",
    r"crushing.*(chest|pain)",
    r"heart attack",
    r"cardiac arrest",
    r"(severe|intense).*(chest|heart).*(pain|pressure|tightness)",
    
    # Respiratory
    r"(can'?t|cannot|unable to|difficulty|struggling to) breath",
    r"(lips?|fingers?|skin).*(turn|turning|blue)",
    r"cyanosis",
    r"(gasping|choking|suffocating)",
    r"(severe|extreme).*(short|difficult).*(breath|breathing)",
    r"throat.*(clos|swell|block)",
    
    # Neurological
    r"(seizure|convulsion|fitting)",
    r"(unconscious|passed out|fainted|collapse)",
    r"(sudden|severe).*(paralysis|weakness).*(one side|left|right)",
    r"stroke",
    r"(sudden|worst).*(headache).*(ever|life)",
    r"(face|arm|leg).*(droop|numb|weak).*(sudden|one side)",
    r"(slurred|cannot|can'?t).*(speech|speak|talk)",
    
    # Bleeding
    r"(severe|heavy|profuse|uncontrolled).*(bleed|blood)",
    r"(bleeding|blood).*(won'?t|not|doesn'?t).*(stop)",
    r"(vomiting|coughing).*(blood|bloody)",
    
    # Allergic
    r"anaphyla",
    r"(severe|serious).*(allergic|allergy)",
    r"(face|lips?|tongue|throat).*(swell)",
    
    # Overdose/Poisoning
    r"overdose",
    r"poison",
    r"(swallowed|ingested|drank).*(chemical|toxic|bleach|antifreeze)",
    
    # Trauma
    r"(major|severe|serious).*(trauma|injury|accident)",
    r"(head|skull).*(injury|trauma).*(confus|dizzy)",
]

# HIGH: Serious, needs attention within hours
HIGH_PATTERNS = [
    # Fever with concerning symptoms
    r"(fever|temperature).*(10[3-5]|high|won'?t break)",
    r"(high|severe).*(fever).*(confus|stiff neck|rash)",
    
    # Blood in body fluids
    r"blood.*(stool|urine|spit|sputum)",
    r"(bloody|blood).*(stool|urine|diarrhea)",
    
    # Severe pain
    r"(severe|intense|excruciating|unbearable|worst).*(pain)",
    r"pain.*(severe|intense|10/10|unbearable)",
    
    # Infection signs
    r"(spreading|red).*(infection|redness)",
    r"(wound|cut).*(infected|pus|spreading)",
    r"(red streak|red line).*(arm|leg|skin)",
    
    # Respiratory
    r"(cough|coughing).*(blood|bloody)",
    r"(persistent|continuous|severe).*(cough|wheezing)",
    r"(short|difficult).*(breath).*(rest|lying|night)",
    
    # Mental health crisis
    r"(suicid|self.?harm|hurt myself|end my life)",
    r"(want|going) to (die|harm|hurt|kill)",
    
    # Dehydration
    r"(severe|extreme).*(dehydration|dehydrated)",
    r"(haven'?t|not).*(urinated|peed).*(hours|day)",
    
    # Chest symptoms (not emergency level)
    r"(chest).*(tightness|pressure|discomfort)",
    r"(heart).*(palpitat|racing|irregular|skip)",
    
    # Abdominal
    r"(severe|intense).*(abdom|stomach|belly).*(pain)",
    r"(abdom|stomach).*(rigid|hard|distended)",
    
    # Head injury
    r"(hit|bump|injury).*(head).*(confus|vomit|dizzy)",
]

# LOW: Minor issues, routine care acceptable
LOW_PATTERNS = [
    # Minor injuries
    r"(minor|small|little|slight).*(cut|scrape|bruise|burn)",
    r"paper cut",
    r"(cut|scrape).*(finger|hand).*(cook|kitchen)",
    r"hangnail",
    
    # Common cold/mild symptoms
    r"(mild|slight|little bit of).*(cold|cough|headache|fever)",
    r"(runny|stuffy).*(nose)",
    r"(common).*(cold)",
    r"sneezing",
    r"(seasonal).*(allerg)",
    
    # Skin minor
    r"(dry|chapped).*(skin|lips)",
    r"(small|minor).*(rash|itch|bump)",
    r"(pimple|acne)",
    
    # Wellness/Questions
    r"(question|wondering|curious) about",
    r"(general|routine).*(checkup|question|wellness)",
    r"(advice|recommend).*(vitamin|supplement|diet|exercise)",
    r"prescription refill",
    r"(how|what|should).*(vitamin|supplement)",
    
    # Chronic stable
    r"(chronic|stable|usual|normal).*(condition|symptom)",
    r"follow.?up",
    r"routine",
    
    # Fatigue (non-specific)
    r"(just|little|bit).*(tired|fatigue)",
    r"(mild|slight|general).*(fatigue|tired)",
]

# MEDIUM is the default for unclear cases

def compile_patterns():
    """Compile regex patterns for efficiency."""
    return {
        'Emergency': [re.compile(p, re.IGNORECASE) for p in EMERGENCY_PATTERNS],
        'High': [re.compile(p, re.IGNORECASE) for p in HIGH_PATTERNS],
        'Low': [re.compile(p, re.IGNORECASE) for p in LOW_PATTERNS],
    }

COMPILED_PATTERNS = compile_patterns()


def rule_based_classify(text):
    """
    Rule-based classification using medical triage protocols.
    Returns (prediction, confidence, matched_rule)
    """
    text_lower = text.lower()
    
    # Priority 1: Check Emergency
    for pattern in COMPILED_PATTERNS['Emergency']:
        if pattern.search(text_lower):
            return 'Emergency', 1.0, pattern.pattern
    
    # Priority 2: Check High
    for pattern in COMPILED_PATTERNS['High']:
        if pattern.search(text_lower):
            return 'High', 0.9, pattern.pattern
    
    # Priority 3: Check Low
    for pattern in COMPILED_PATTERNS['Low']:
        if pattern.search(text_lower):
            return 'Low', 0.8, pattern.pattern
    
    # No rule matched - return None (will use ML)
    return None, 0.0, None


# =============================================================================
# SIMPLE ML FOR AMBIGUOUS CASES (TF-IDF + Logistic Regression)
# =============================================================================
class SimpleMLClassifier:
    """Simple ML classifier for cases where rules don't match."""
    
    def __init__(self):
        self.vectorizer = TfidfVectorizer(
            max_features=5000,
            ngram_range=(1, 2),
            min_df=2,
            max_df=0.95,
            stop_words='english'
        )
        self.classifier = LogisticRegression(
            max_iter=1000,
            C=1.0,
            class_weight='balanced',
            multi_class='multinomial',
            random_state=42
        )
        self.label_map = {'Emergency': 0, 'High': 1, 'Medium': 2, 'Low': 3}
        self.reverse_map = {v: k for k, v in self.label_map.items()}
        
    def train(self, texts, labels):
        """Train the classifier."""
        print("   Training TF-IDF + Logistic Regression...")
        X = self.vectorizer.fit_transform(texts)
        y = [self.label_map[l] for l in labels]
        self.classifier.fit(X, y)
        print(f"   Trained on {len(texts):,} samples")
        
    def predict(self, text):
        """Predict with probability."""
        X = self.vectorizer.transform([text])
        pred = self.classifier.predict(X)[0]
        proba = self.classifier.predict_proba(X)[0]
        return self.reverse_map[pred], proba[pred]


# =============================================================================
# HYBRID TRIAGE SYSTEM
# =============================================================================
class HybridTriageSystem:
    """
    Rule-first hybrid triage system.
    1. Apply rules (high confidence)
    2. Fall back to ML for ambiguous cases
    """
    
    def __init__(self):
        self.ml_classifier = SimpleMLClassifier()
        self.stats = {'rules': 0, 'ml': 0}
    
    def train(self, texts, labels):
        """Train the ML component."""
        # Train on ALL data (rules handle their own filtering)
        self.ml_classifier.train(texts, labels)
    
    def predict(self, text):
        """
        Predict using rule-first approach.
        Returns: (prediction, source, confidence, rule_matched)
        """
        # Try rules first
        rule_pred, rule_conf, matched_rule = rule_based_classify(text)
        
        if rule_pred is not None:
            self.stats['rules'] += 1
            return rule_pred, 'RULE', rule_conf, matched_rule
        
        # Fall back to ML
        ml_pred, ml_conf = self.ml_classifier.predict(text)
        self.stats['ml'] += 1
        return ml_pred, 'ML', ml_conf, None
    
    def evaluate(self, texts, true_labels):
        """Evaluate the hybrid system."""
        predictions = []
        sources = []
        
        for text in texts:
            pred, source, conf, rule = self.predict(text)
            predictions.append(pred)
            sources.append(source)
        
        # Calculate accuracy
        label_map = {'Emergency': 0, 'High': 1, 'Medium': 2, 'Low': 3}
        y_true = [label_map[l] for l in true_labels]
        y_pred = [label_map[p] for p in predictions]
        
        accuracy = accuracy_score(y_true, y_pred)
        
        return accuracy, predictions, sources


# =============================================================================
# MAIN TRAINING AND EVALUATION
# =============================================================================
def main():
    # Load data
    print("\n📊 Loading data...")
    df = pd.read_csv('Housepital_Triage/generated_symptom_texts_clean.csv')
    print(f"   Total samples: {len(df):,}")
    
    # Split data
    texts = df['text'].values
    labels = df['risk_level'].values
    
    X_train, X_test, y_train, y_test = train_test_split(
        texts, labels, test_size=0.2, stratify=labels, random_state=42
    )
    print(f"   Train: {len(X_train):,} | Test: {len(X_test):,}")
    
    # Create and train hybrid system
    print("\n🧠 Training Hybrid System...")
    system = HybridTriageSystem()
    system.train(X_train, y_train)
    
    # Evaluate
    print("\n" + "=" * 70)
    print("📊 EVALUATION")
    print("=" * 70)
    
    accuracy, predictions, sources = system.evaluate(X_test, y_test)
    
    # Count sources
    rule_count = sources.count('RULE')
    ml_count = sources.count('ML')
    
    print(f"\n🎯 OVERALL ACCURACY: {accuracy:.2%}")
    print(f"\n📊 Prediction Sources:")
    print(f"   Rules: {rule_count:,} ({rule_count/len(sources)*100:.1f}%)")
    print(f"   ML:    {ml_count:,} ({ml_count/len(sources)*100:.1f}%)")
    
    if accuracy >= 0.90:
        print("\n🎉 " + "=" * 60)
        print("🎉 TARGET ACHIEVED: 90%+ ACCURACY!")
        print("🎉 " + "=" * 60)
    
    # Classification report
    label_map = {'Emergency': 0, 'High': 1, 'Medium': 2, 'Low': 3}
    y_true = [label_map[l] for l in y_test]
    y_pred = [label_map[p] for p in predictions]
    
    print(f"\n📋 Classification Report:")
    print(classification_report(y_true, y_pred, 
                                target_names=['Emergency', 'High', 'Medium', 'Low'],
                                digits=4))
    
    print("🔢 Confusion Matrix:")
    print(confusion_matrix(y_true, y_pred))
    
    # Quick test with new sentences
    print("\n" + "=" * 70)
    print("🔬 QUICK TEST - NEW SENTENCES")
    print("=" * 70)
    
    test_cases = [
        ("I'm having severe chest pain radiating to my left arm and sweating profusely", "Emergency"),
        ("I can't breathe and my lips are turning blue", "Emergency"),
        ("My child has a high fever of 104 with confusion", "High"),
        ("Blood in my stool for the past few days", "High"),
        ("Severe headache that won't go away", "High"),
        ("I have a mild cold with runny nose", "Low"),
        ("Minor cut on my finger from cooking", "Low"),
        ("Question about vitamin supplements", "Low"),
        ("Persistent cough for a week", "Medium"),
        ("Stomach pain after eating", "Medium"),
    ]
    
    correct = 0
    for symptom, expected in test_cases:
        pred, source, conf, rule = system.predict(symptom)
        match = "✅" if pred == expected else "❌"
        if pred == expected:
            correct += 1
        
        source_info = f"[{source}]" if source == 'RULE' else "[ML]"
        print(f"{match} {expected:10} → {pred:10} {source_info}")
        print(f"   {symptom[:55]}...")
    
    print(f"\n📊 Quick Test: {correct}/{len(test_cases)} ({correct/len(test_cases)*100:.0f}%)")
    
    # Save model
    print("\n💾 Saving model...")
    with open('triage_hybrid_model.pkl', 'wb') as f:
        pickle.dump({
            'vectorizer': system.ml_classifier.vectorizer,
            'classifier': system.ml_classifier.classifier,
            'label_map': system.ml_classifier.label_map,
            'reverse_map': system.ml_classifier.reverse_map,
        }, f)
    print("   Saved to triage_hybrid_model.pkl")
    
    return accuracy, system


if __name__ == "__main__":
    accuracy, system = main()
