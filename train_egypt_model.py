"""
COMPLETE TRAINING PIPELINE
==========================
1. Load Egypt-focused dataset
2. Train RandomForest model
3. Add keyword rules
4. Evaluate on test set
5. Interactive testing
"""

import pandas as pd
import numpy as np
import re
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix
import pickle

print("=" * 70)
print("🏥 TRAINING EGYPT-FOCUSED TRIAGE MODEL")
print("=" * 70)

# =============================================================================
# KEYWORD RULES
# =============================================================================
EMERGENCY_PATTERNS = [
    r"(can'?t|cannot|unable to)\s*(breathe|breath)",
    r"(lips?|face|fingers?)\s*(turn|turning)\s*(blue)",
    r"chest\s*pain.*(radiat|spread|arm|jaw|left)",
    r"heart\s*attack",
    r"(severe|heavy|profuse|won'?t stop)\s*(bleed|blood)",
    r"(unconscious|not responding|unresponsive|passed out|collapsed)",
    r"(seizure|convulsion|shaking uncontrollably)",
    r"(stroke|face droop|can'?t speak)",
    r"(poison|overdose|swallowed.*(pill|chemical|cleaning))",
    r"(not breathing|stopped breathing|gasping)",
    r"(suicide|end.*(life|myself)|hurt.*(myself|themselves))",
    r"(40°|41°|40\.5°)",  # Very high fever
]

HIGH_PATTERNS = [
    r"(fracture|broken bone|bent.*(wrong|awkward))",
    r"(deep cut|won'?t stop bleeding|needs? stitches)",
    r"(39°|39\.5°|high fever)",
    r"(difficulty|trouble|struggling)\s*(breath|breathing)",
    r"blood\s*in\s*(stool|urine|vomit)",
    r"(severe|unbearable|excruciating|worst)\s*(pain|headache)",
    r"(heat stroke|not sweating|confused.*(hot|heat))",
    r"(allergic|anaphyla|swelling.*(face|throat))",
    r"(dehydrated|no tears|dry.*(lips|mouth)|dark urine)",
    r"(infection.*(spread|spreading)|red.*(lines?|streaks?))",
    r"(chest tight|palpitation|heart racing)",
    r"(concussion|hit.*(head).*confus)",
]

LOW_PATTERNS = [
    r"(minor|small|slight|tiny)\s*(cut|bruise|scrape|scratch)",
    r"(mild|slight|bit of)\s*(cold|cough|headache|fever)",
    r"(runny|stuffy)\s*nose",
    r"(37\.[0-5]°|37°)",  # Low grade fever
    r"(seasonal|allerg).*(sneez|itch|eye)",
    r"(tired|stress|sleep|insomnia)",
    r"(dry skin|acne|minor rash)",
    r"(muscle sore|after gym|after exercise)",
    r"(indigestion|heartburn|ate too much)",
    r"(paper cut|splinter|sunburn.*(mild|minor|bit))",
    r"(vitamin|supplement|general advice|tips)",
]

def apply_rules(text):
    """Apply keyword rules."""
    text_lower = text.lower()
    
    for pattern in EMERGENCY_PATTERNS:
        if re.search(pattern, text_lower):
            return 'Emergency', pattern
    for pattern in HIGH_PATTERNS:
        if re.search(pattern, text_lower):
            return 'High', pattern
    for pattern in LOW_PATTERNS:
        if re.search(pattern, text_lower):
            return 'Low', pattern
    return None, None

# =============================================================================
# LOAD DATA
# =============================================================================
print("\n📊 Loading dataset...")
df = pd.read_csv('triage_dataset_egypt.csv')
print(f"   Samples: {len(df):,}")
print(f"   Distribution: {df['risk_level'].value_counts().to_dict()}")

texts = df['text'].values
labels = df['risk_level'].values

label_map = {'Emergency': 0, 'High': 1, 'Medium': 2, 'Low': 3}
reverse_map = {v: k for k, v in label_map.items()}
y = np.array([label_map[l] for l in labels])

# Split
X_train, X_test, y_train, y_test = train_test_split(
    texts, y, test_size=0.2, stratify=y, random_state=42
)
print(f"   Train: {len(X_train):,} | Test: {len(X_test):,}")

# =============================================================================
# TRAIN
# =============================================================================
print("\n🧠 Training model...")

# TF-IDF
vectorizer = TfidfVectorizer(
    max_features=15000,
    ngram_range=(1, 3),
    min_df=2,
    max_df=0.9,
    stop_words='english'
)
X_train_tfidf = vectorizer.fit_transform(X_train)
X_test_tfidf = vectorizer.transform(X_test)
print(f"   Features: {X_train_tfidf.shape[1]:,}")

# RandomForest
model = RandomForestClassifier(
    n_estimators=300,
    max_depth=50,
    class_weight='balanced',
    random_state=42,
    n_jobs=-1
)
model.fit(X_train_tfidf, y_train)
print("   ✅ Model trained")

# =============================================================================
# HYBRID PREDICTION
# =============================================================================
def hybrid_predict(text, vectorizer, model):
    """Rules first, then model."""
    rule_pred, pattern = apply_rules(text)
    if rule_pred:
        return rule_pred, 'RULE', pattern
    
    X = vectorizer.transform([text])
    pred_id = model.predict(X)[0]
    proba = model.predict_proba(X)[0]
    return reverse_map[pred_id], 'MODEL', proba[pred_id]

# =============================================================================
# EVALUATE
# =============================================================================
print("\n" + "=" * 70)
print("📊 EVALUATION")
print("=" * 70)

predictions = []
sources = {'RULE': 0, 'MODEL': 0}

for text in X_test:
    pred, source, _ = hybrid_predict(text, vectorizer, model)
    predictions.append(label_map[pred])
    sources[source] += 1

predictions = np.array(predictions)
accuracy = accuracy_score(y_test, predictions)

# Model-only accuracy for comparison
model_only_pred = model.predict(X_test_tfidf)
model_acc = accuracy_score(y_test, model_only_pred)

print(f"\n🤖 Model-only Accuracy: {model_acc:.2%}")
print(f"🎯 HYBRID Accuracy:     {accuracy:.2%}")
print(f"📊 Sources: RULE={sources['RULE']:,}, MODEL={sources['MODEL']:,}")

print(f"\n📋 Classification Report:")
print(classification_report(y_test, predictions,
                            target_names=['Emergency', 'High', 'Medium', 'Low'],
                            digits=4))

print("🔢 Confusion Matrix:")
cm = confusion_matrix(y_test, predictions)
print(cm)

# Per-class accuracy
print("\n📊 Per-class accuracy:")
for i, name in enumerate(['Emergency', 'High', 'Medium', 'Low']):
    class_acc = (predictions[y_test == i] == i).mean()
    print(f"   {name:12}: {class_acc:.2%}")

# Emergency recall (CRITICAL)
emergency_recall = (predictions[y_test == 0] == 0).mean()
print(f"\n⚠️ EMERGENCY RECALL: {emergency_recall:.2%}")

if accuracy >= 0.90:
    print("\n🎉 " + "=" * 60)
    print("🎉 TARGET ACHIEVED: 90%+ ACCURACY!")
    print("🎉 " + "=" * 60)

# =============================================================================
# REAL-WORLD TESTS
# =============================================================================
print("\n" + "=" * 70)
print("🔬 REAL-WORLD TEST SCENARIOS")
print("=" * 70)

real_tests = [
    # Emergency
    ("My friend fell down and bumped his head in the corner of the table which then gets a big cut in his forehead and he's not responding", "Emergency"),
    ("I can't breathe properly my chest is very tight and pain going to my left arm", "Emergency"),
    ("My grandmother collapsed and we can't wake her up", "Emergency"),
    ("My baby swallowed some cleaning liquid and is crying a lot", "Emergency"),
    
    # High
    ("I have a deep cut on my hand that won't stop bleeding, been pressing for 20 minutes", "High"),
    ("My son has fever 39.5°C for two days and he's very weak", "High"),
    ("There's blood in my urine and severe back pain", "High"),
    ("I was in the sun too long and now I'm confused and not sweating", "High"),
    
    # Medium
    ("I have stomach pain that comes and goes after eating", "Medium"),
    ("My daughter has a cough and mild fever 38°C since yesterday", "Medium"),
    ("I've had a headache for the past few days, it's not severe but annoying", "Medium"),
    ("My back hurts from sitting at the computer all day", "Medium"),
    
    # Low
    ("I got a small paper cut at work, it's tiny but stings", "Low"),
    ("I have a runny nose and sneezing, probably just a cold", "Low"),
    ("I'm a bit tired lately, nothing specific", "Low"),
    ("I need some tips for sleeping better", "Low"),
]

correct = 0
for symptom, expected in real_tests:
    pred, source, _ = hybrid_predict(symptom, vectorizer, model)
    match = "✅" if pred == expected else "❌"
    if pred == expected:
        correct += 1
    print(f"{match} {expected:10} → {pred:10} [{source}]")
    print(f"   {symptom[:70]}...")

print(f"\n📊 Real-world Test: {correct}/{len(real_tests)} ({correct/len(real_tests)*100:.0f}%)")

# =============================================================================
# SAVE
# =============================================================================
print("\n💾 Saving model...")
with open('triage_egypt_model.pkl', 'wb') as f:
    pickle.dump({
        'vectorizer': vectorizer,
        'model': model,
        'label_map': label_map,
        'reverse_map': reverse_map,
    }, f)
print("   Saved to triage_egypt_model.pkl")

print("\n✅ Training complete!")
