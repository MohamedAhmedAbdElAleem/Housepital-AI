"""
Convert Symptom Matrix to 100K+ Unique Text Scenarios
======================================================
Takes the original_dataset.csv (symptom-presence matrix) and converts it
to natural, unique text descriptions.

Strategy:
1. For each row, get the symptoms where value = 1
2. Generate unique natural language descriptions
3. Assign proper medical triage labels based on disease
4. Create 100K+ unique samples
"""

import pandas as pd
import numpy as np
import random
import hashlib
from collections import defaultdict

random.seed(42)
np.random.seed(42)

print("=" * 70)
print("🏥 GENERATING 100K UNIQUE TRIAGE SCENARIOS")
print("=" * 70)

# =============================================================================
# DISEASE TO TRIAGE LEVEL MAPPING (Medical Knowledge)
# =============================================================================
EMERGENCY_CONDITIONS = [
    'heart attack', 'myocardial infarction', 'cardiac arrest', 'stroke',
    'pulmonary embolism', 'anaphylaxis', 'sepsis', 'meningitis',
    'diabetic ketoacidosis', 'respiratory failure', 'hemorrhage',
    'pneumothorax', 'aortic dissection', 'status epilepticus',
    'acute abdomen', 'ruptured', 'peritonitis', 'shock',
    'overdose', 'poisoning', 'suffocation', 'choking',
    'severe asthma', 'anaphylactic', 'hypertensive crisis',
    'acute coronary', 'subarachnoid', 'intracranial',
]

HIGH_CONDITIONS = [
    'cancer', 'tumor', 'malignant', 'metasta',
    'pneumonia', 'appendicitis', 'pancreatitis', 'cholecystitis',
    'deep vein thrombosis', 'dvt', 'cellulitis', 'abscess',
    'kidney failure', 'renal failure', 'liver failure',
    'diabetic', 'hypoglycemia', 'hyperglycemia',
    'fracture', 'dislocation', 'concussion',
    'severe infection', 'osteomyelitis', 'encephalitis',
    'bowel obstruction', 'ileus', 'ischemia',
    'hypertension', 'atrial fibrillation', 'arrhythmia',
    'hepatitis', 'cirrhosis', 'ulcer', 'gastrointestinal bleed',
]

LOW_CONDITIONS = [
    'common cold', 'seasonal allergy', 'allergic rhinitis',
    'minor cut', 'minor wound', 'bruise', 'contusion',
    'mild headache', 'tension headache',
    'acne', 'eczema', 'dermatitis', 'dry skin',
    'minor sprain', 'strain', 'muscle soreness',
    'heartburn', 'indigestion', 'constipation', 'hemorrhoid',
    'insomnia', 'anxiety', 'stress',
    'dandruff', 'athlete foot', 'ingrown',
]

def classify_disease(disease):
    """Classify disease into triage level based on medical knowledge."""
    disease_lower = disease.lower()
    
    for keyword in EMERGENCY_CONDITIONS:
        if keyword in disease_lower:
            return 'Emergency'
    
    for keyword in HIGH_CONDITIONS:
        if keyword in disease_lower:
            return 'High'
    
    for keyword in LOW_CONDITIONS:
        if keyword in disease_lower:
            return 'Low'
    
    return 'Medium'  # Default

# =============================================================================
# NATURAL LANGUAGE TEMPLATES
# =============================================================================
SENTENCE_STARTERS = [
    "I've been experiencing",
    "I have",
    "I'm suffering from",
    "I've noticed",
    "For the past few days, I've had",
    "Recently, I started having",
    "I'm dealing with",
    "I can't shake",
    "I've developed",
    "I'm worried because I have",
    "Something's wrong, I have",
    "I need help with",
]

CONNECTORS = [
    " and ", " along with ", " as well as ", " combined with ",
    ". I also have ", ". Additionally, ", ". Plus, ",
    ", and I'm also experiencing ", ", accompanied by ",
]

TIME_PHRASES = [
    " for a few days now",
    " since yesterday",
    " for about a week",
    " that started recently",
    " that won't go away",
    " that's getting worse",
    "",  # No time phrase
    " that comes and goes",
    " especially at night",
    " throughout the day",
]

SEVERITY_PHRASES = {
    'Emergency': [
        " It's extremely severe.", " I'm really scared.",
        " This is unbearable.", " I need immediate help.",
        " It's getting worse rapidly.", "",
    ],
    'High': [
        " It's quite concerning.", " This is really bothering me.",
        " I'm worried about this.", " It's significantly affecting me.",
        "", " I think I need to see a doctor soon.",
    ],
    'Medium': [
        " It's moderately bothersome.", " I'm not sure what to do.",
        " It's affecting my daily life.", " I'd like some advice.",
        "", " Should I be concerned?",
    ],
    'Low': [
        " It's not too bad but annoying.", " I just want to check if it's normal.",
        " It's minor but I'm curious.", " Nothing too serious I think.",
        "", " Just wanted to ask about it.",
    ],
}

def symptoms_to_text(symptoms, disease, triage_level):
    """Convert list of symptoms to natural language text."""
    if not symptoms:
        return None
    
    # Clean symptom names
    symptoms = [s.replace('_', ' ').strip() for s in symptoms]
    
    # Select random subset if too many symptoms (2-5 symptoms is natural)
    if len(symptoms) > 5:
        symptoms = random.sample(symptoms, random.randint(3, 5))
    elif len(symptoms) > 3:
        symptoms = random.sample(symptoms, random.randint(2, min(4, len(symptoms))))
    
    # Build sentence
    starter = random.choice(SENTENCE_STARTERS)
    
    if len(symptoms) == 1:
        symptom_text = symptoms[0]
    elif len(symptoms) == 2:
        symptom_text = symptoms[0] + random.choice(CONNECTORS) + symptoms[1]
    else:
        connector = random.choice(CONNECTORS)
        symptom_text = ", ".join(symptoms[:-1]) + connector + symptoms[-1]
    
    time_phrase = random.choice(TIME_PHRASES)
    severity_phrase = random.choice(SEVERITY_PHRASES.get(triage_level, SEVERITY_PHRASES['Medium']))
    
    text = f"{starter} {symptom_text}{time_phrase}.{severity_phrase}"
    
    return text.strip()

# =============================================================================
# MAIN CONVERSION
# =============================================================================
def convert_dataset(target_samples=100000):
    """Convert symptom matrix to text scenarios."""
    
    print("\n📊 Loading original dataset...")
    df = pd.read_csv('original_dataset.csv')
    print(f"   Rows: {len(df):,}")
    print(f"   Diseases: {df['diseases'].nunique()}")
    
    # Get symptom columns (all except 'diseases')
    symptom_columns = [c for c in df.columns if c != 'diseases']
    print(f"   Symptoms: {len(symptom_columns)}")
    
    # Generate samples
    print(f"\n🔄 Generating {target_samples:,} unique samples...")
    
    samples = []
    used_hashes = set()
    
    # Shuffle dataframe
    df_shuffled = df.sample(frac=1, random_state=42).reset_index(drop=True)
    
    attempts = 0
    max_attempts = target_samples * 5
    idx = 0
    
    while len(samples) < target_samples and attempts < max_attempts:
        # Get row (cycle through)
        row = df_shuffled.iloc[idx % len(df_shuffled)]
        idx += 1
        attempts += 1
        
        disease = row['diseases']
        triage_level = classify_disease(disease)
        
        # Get symptoms where value = 1
        symptoms = [col for col in symptom_columns if row[col] == 1]
        
        if len(symptoms) < 2:
            continue
        
        # Generate text
        text = symptoms_to_text(symptoms, disease, triage_level)
        
        if not text or len(text) < 20:
            continue
        
        # Check uniqueness
        text_hash = hashlib.md5(text.lower().encode()).hexdigest()
        if text_hash in used_hashes:
            continue
        
        used_hashes.add(text_hash)
        samples.append({
            'text': text,
            'disease': disease,
            'risk_level': triage_level,
        })
        
        if len(samples) % 10000 == 0:
            print(f"   Generated: {len(samples):,}/{target_samples:,}")
    
    print(f"   ✅ Generated: {len(samples):,} unique samples")
    
    # Convert to dataframe
    result_df = pd.DataFrame(samples)
    
    # Show distribution
    print("\n📊 Distribution:")
    for level, count in result_df['risk_level'].value_counts().sort_index().items():
        pct = count / len(result_df) * 100
        print(f"   {level:12}: {count:6,} ({pct:.1f}%)")
    
    return result_df

def balance_dataset(df, target_per_class=25000):
    """Balance the dataset."""
    print(f"\n📊 Balancing to {target_per_class:,} per class...")
    
    balanced_dfs = []
    
    for level in ['Emergency', 'High', 'Medium', 'Low']:
        subset = df[df['risk_level'] == level]
        current = len(subset)
        
        if current >= target_per_class:
            balanced_dfs.append(subset.sample(n=target_per_class, random_state=42))
            print(f"   {level:12}: {current:,} → {target_per_class:,} (sampled)")
        else:
            # Oversample
            multiplier = (target_per_class // current) + 1
            oversampled = pd.concat([subset] * multiplier, ignore_index=True)
            oversampled = oversampled.sample(n=target_per_class, random_state=42)
            balanced_dfs.append(oversampled)
            print(f"   {level:12}: {current:,} → {target_per_class:,} (oversampled)")
    
    result = pd.concat(balanced_dfs, ignore_index=True)
    result = result.sample(frac=1, random_state=42).reset_index(drop=True)
    
    return result

# =============================================================================
# MAIN
# =============================================================================
if __name__ == "__main__":
    # Generate 120K samples (to have buffer for uniqueness)
    df = convert_dataset(target_samples=120000)
    
    # Balance to 25K per class = 100K total
    df_balanced = balance_dataset(df, target_per_class=25000)
    
    # Save
    output_file = 'triage_dataset_100k.csv'
    df_balanced.to_csv(output_file, index=False)
    
    print(f"\n💾 Saved to {output_file}")
    print(f"   Total: {len(df_balanced):,} samples")
    
    # Show examples
    print("\n📋 Sample examples:")
    for level in ['Emergency', 'High', 'Medium', 'Low']:
        sample = df_balanced[df_balanced['risk_level'] == level].iloc[0]
        print(f"\n   [{level}] {sample['disease']}")
        print(f"   {sample['text'][:100]}...")
    
    print("\n✅ Done!")
