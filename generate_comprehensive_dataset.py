"""
COMPREHENSIVE SCENARIO-BASED TRIAGE DATASET GENERATOR
======================================================
Creates realistic, diverse medical scenarios including:
1. Accident narratives (falls, burns, cuts)
2. Third-party reports (child, elderly, friend)
3. Progressive symptoms (started with X, now Y)
4. Contextual descriptions (where, when, how)
5. Emotional expressions
6. Chronic condition flare-ups
7. Medical history context

Target: 100K+ unique, realistic samples
"""

import pandas as pd
import numpy as np
import random
import hashlib
import re

random.seed(42)
np.random.seed(42)

print("=" * 70)
print("🏥 COMPREHENSIVE SCENARIO-BASED DATASET GENERATOR")
print("=" * 70)

# =============================================================================
# TRIAGE CLASSIFICATION
# =============================================================================
EMERGENCY_KEYWORDS = [
    'heart attack', 'cardiac arrest', 'stroke', 'seizure', 'unconscious',
    'severe bleeding', 'not breathing', 'choking', 'anaphylaxis', 'overdose',
    'drowning', 'electrocution', 'severe burn', 'head trauma', 'spinal injury',
    'diabetic emergency', 'poisoning', 'suicide attempt', 'chest pain radiating',
]

HIGH_KEYWORDS = [
    'fracture', 'broken bone', 'deep cut', 'high fever', 'severe pain',
    'difficulty breathing', 'blood in', 'concussion', 'infection spreading',
    'appendicitis', 'kidney stone', 'severe allergic', 'dehydration',
    'diabetic', 'asthma attack', 'chest pain', 'migraine severe',
]

LOW_KEYWORDS = [
    'minor cut', 'small bruise', 'mild cold', 'runny nose', 'mild headache',
    'muscle soreness', 'slight fever', 'paper cut', 'insect bite',
    'dry skin', 'acne', 'minor rash', 'tired', 'stressed',
]

def classify_scenario(text):
    """Classify scenario text into triage level."""
    text_lower = text.lower()
    
    for kw in EMERGENCY_KEYWORDS:
        if kw in text_lower:
            return 'Emergency'
    for kw in HIGH_KEYWORDS:
        if kw in text_lower:
            return 'High'
    for kw in LOW_KEYWORDS:
        if kw in text_lower:
            return 'Low'
    return 'Medium'

# =============================================================================
# SCENARIO COMPONENTS
# =============================================================================

# People (first/third person)
PEOPLE = {
    'self': ['I', 'I\'ve', 'I\'m', 'My'],
    'child': ['My child', 'My son', 'My daughter', 'My toddler', 'My baby', 'My 5-year-old', 'My teenager'],
    'elderly': ['My mother', 'My father', 'My grandmother', 'My grandfather', 'My elderly parent'],
    'spouse': ['My husband', 'My wife', 'My partner'],
    'friend': ['My friend', 'My roommate', 'My colleague'],
}

# Time contexts
TIME_CONTEXTS = [
    'just now', 'a few minutes ago', 'about an hour ago', 'this morning',
    'last night', 'for the past few hours', 'since yesterday', 'for two days',
    'for about a week', 'over the past month', 'suddenly', 'gradually',
]

# Locations/Activities
LOCATIONS = [
    'at home', 'in the kitchen', 'in the bathroom', 'at work', 'at school',
    'at the gym', 'outside', 'in the park', 'on the stairs', 'in the garage',
    'while cooking', 'while exercising', 'while sleeping', 'while driving',
    'while playing', 'while working', 'during dinner', 'in the middle of the night',
]

# Emotional expressions
EMOTIONS = {
    'Emergency': [
        "I'm terrified", "Please help immediately", "This is an emergency",
        "I'm panicking", "I don't know what to do", "It's really bad",
        "I'm scared he/she might die", "This looks serious", "I need help now",
    ],
    'High': [
        "I'm really worried", "This is concerning me", "It seems serious",
        "Should I go to the ER?", "I'm not sure what to do", "It's getting worse",
        "I'm scared", "This doesn't look right", "I think we need help",
    ],
    'Medium': [
        "I'm a bit concerned", "It's bothering me", "Should I see a doctor?",
        "I'm not sure if it's serious", "It's been going on for a while",
        "I want to get it checked", "Is this normal?", "I'm wondering if...",
    ],
    'Low': [
        "It's probably nothing but", "Just wanted to ask", "It's minor but annoying",
        "I'm just curious", "Not urgent but", "When I get a chance",
        "I figured I'd ask", "It's not a big deal but",
    ],
}

# =============================================================================
# SCENARIO TEMPLATES BY TYPE
# =============================================================================

ACCIDENT_SCENARIOS = {
    'Emergency': [
        "{person} fell from {height} and hit {body_part}. {person_short} {is_are} not responding and there's blood everywhere. {emotion}",
        "{person} was in a car accident {time}. {person_short} {is_are} bleeding heavily from {body_part} and {additional}. {emotion}",
        "{person} got severely burned {location}. The skin is {burn_desc}. {emotion}",
        "{person} was choking on food and now {is_are} unconscious. {person_short} stopped breathing. {emotion}",
        "{person} fell down the stairs and can't move. {person_short} hit {his_her} head on the corner and there's a deep gash. {emotion}",
        "{person} was electrocuted {location}. {person_short} {is_are} shaking uncontrollably. {emotion}",
        "{person} nearly drowned {time}. {person_short} {is_are} barely conscious and coughing up water. {emotion}",
    ],
    'High': [
        "{person} fell {location} and {his_her} {body_part} looks bent wrong. {person_short} can't put weight on it. {emotion}",
        "{person} got a deep cut {location} and it won't stop bleeding. We've been applying pressure for {time}. {emotion}",
        "{person} hit {his_her} head {location} {time}. Now {person_short_lower} {is_are} confused and dizzy. {emotion}",
        "{person} burned {his_her} {body_part} on {burn_source}. There are blisters forming and it's very painful. {emotion}",
        "{person} fell off a bike and scraped up badly. {person_short} {is_are} in a lot of pain and can't move {his_her} arm. {emotion}",
        "{person} got something stuck in {his_her} eye {location}. It's red, swollen and {person_short_lower} can barely see. {emotion}",
    ],
    'Medium': [
        "{person} twisted {his_her} ankle {location} {time}. It's swollen but can still walk on it a little. {emotion}",
        "{person} got a cut {location} that might need stitches. It's not bleeding too much now. {emotion}",
        "{person} bumped {his_her} head {location}. There's a bump but {person_short_lower} seems okay. {emotion}",
        "{person} pulled a muscle {location} while {activity}. It hurts to move. {emotion}",
        "{person} got a mild burn on {his_her} {body_part} while cooking. The skin is red. {emotion}",
    ],
    'Low': [
        "{person} got a small cut {location} from {cut_source}. It's minor but I wanted to ask about care. {emotion}",
        "{person} has a small bruise from bumping into {furniture}. It's not a big deal but {emotion}",
        "{person} got a paper cut at work. It stings a bit. {emotion}",
        "{person} scraped {his_her} knee {location}. It's just a scrape but wanted to make sure it's clean. {emotion}",
    ],
}

ILLNESS_SCENARIOS = {
    'Emergency': [
        "{person} is having severe chest pain that's radiating to {his_her} left arm. {person_short} {is_are} sweating and can barely breathe. {emotion}",
        "{person} suddenly collapsed and {is_are} not responsive. This happened {time}. {emotion}",
        "{person} is having a seizure right now. {person_short} {is_are} shaking uncontrollably. {emotion}",
        "{person} took too many pills {time}. {person_short} {is_are} barely conscious and slurring words. {emotion}",
        "{person}'s face is drooping on one side and {person_short_lower} can't lift {his_her} arm. {emotion}",
        "{person} has been vomiting blood {time}. There's a lot of it. {emotion}",
        "{person} is struggling to breathe. {his_her} lips are turning blue. {emotion}",
    ],
    'High': [
        "{person} has had a high fever of {temp} for {time}. Nothing is bringing it down and {person_short_lower} seems confused. {emotion}",
        "{person} has been coughing up blood {time}. It started with a bad cough but now this. {emotion}",
        "{person} has severe abdominal pain in the lower right side. It hurts to move. {emotion}",
        "{person} is experiencing chest tightness and difficulty breathing, especially when lying down. {emotion}",
        "{person} has blood in {his_her} {stool_urine} {time}. {emotion}",
        "{person} has a severe headache unlike anything before. It came on suddenly. {emotion}",
        "{person} is showing signs of a severe allergic reaction - {his_her} face is swelling. {emotion}",
        "{person} has been having heart palpitations and feels like passing out. {emotion}",
    ],
    'Medium': [
        "{person} has had a cough for {time} that isn't getting better. Sometimes there's phlegm. {emotion}",
        "{person} has been experiencing stomach pain after eating {time}. {emotion}",
        "{person} has a fever of {mild_temp} {time} with body aches. {emotion}",
        "{person} has been dizzy when standing up {time}. {emotion}",
        "{person} has a rash that appeared {time}. It's itchy and spreading slowly. {emotion}",
        "{person} has been having headaches {time}. They're manageable but persistent. {emotion}",
        "{person} has ear pain {time}. It feels like pressure inside. {emotion}",
        "{person} has been experiencing fatigue and low energy {time}. {emotion}",
        "{person} has a sore throat and slight fever {time}. {emotion}",
    ],
    'Low': [
        "{person} has a runny nose and mild cough. Seems like a common cold. {emotion}",
        "{person} has been feeling a bit tired lately. Nothing specific, just low energy. {emotion}",
        "{person} has a slight headache {time}. It's not too bad. {emotion}",
        "{person} has some seasonal allergies acting up. Sneezing and itchy eyes. {emotion}",
        "{person} has mild indigestion after eating too much. {emotion}",
        "{person} has trouble sleeping {time}. Wondering about sleep hygiene tips. {emotion}",
        "{person} has a small rash on {his_her} arm. It's not itchy or spreading. {emotion}",
        "{person} has dry skin that's a bit flaky. Looking for recommendations. {emotion}",
    ],
}

CHILD_SPECIFIC_SCENARIOS = {
    'Emergency': [
        "{person} isn't breathing properly. {his_her} lips are turning blue. This started {time}. {emotion}",
        "{person} found and swallowed some of daddy's pills. {person_short} {is_are} drowsy and not responding well. {emotion}",
        "{person} fell from the changing table and hit {his_her} head hard. Now there's a big bump and {person_short_lower} won't stop crying. {emotion}",
        "{person} is having what looks like a seizure. {his_her} whole body is shaking and eyes rolled back. {emotion}",
    ],
    'High': [
        "{person} has had a fever of {child_temp} for {time}. {person_short} {is_are} refusing to eat and very lethargic. {emotion}",
        "{person} has been vomiting everything for {time}. Can't keep anything down. {emotion}",
        "{person} has a rash that appeared {time} along with fever. It's spreading. {emotion}",
        "{person} fell at the playground and {his_her} arm looks wrong. {person_short} {is_are} in a lot of pain. {emotion}",
        "{person} has been pulling at {his_her} ear and crying all night with a fever. {emotion}",
    ],
    'Medium': [
        "{person} has a cough and runny nose {time}. Fever is around {mild_child_temp}. {emotion}",
        "{person} has been complaining of a tummy ache {time}. No vomiting though. {emotion}",
        "{person} has a diaper rash that isn't getting better with cream. {emotion}",
        "{person} has been cranky and not eating well {time}. {emotion}",
    ],
    'Low': [
        "{person} has a bit of a runny nose. No fever, eating fine. {emotion}",
        "{person} got a small scrape at the playground. Just want to know best way to clean it. {emotion}",
        "{person} has had hiccups for a while. Is that normal? {emotion}",
    ],
}

CHRONIC_FLAREUP_SCENARIOS = {
    'High': [
        "My {chronic_condition} is flaring up badly. {person} is having much worse symptoms than usual - {symptom}. {emotion}",
        "{person}'s {chronic_condition} medication doesn't seem to be working anymore. {symptom} is severe. {emotion}",
        "{person} was diagnosed with {chronic_condition} and now showing new symptoms: {symptom}. {emotion}",
    ],
    'Medium': [
        "{person}'s {chronic_condition} seems to be getting worse {time}. {symptom} is more frequent. {emotion}",
        "{person} has {chronic_condition} and today {symptom} is worse than usual. {emotion}",
        "Looking for advice about managing {person_possessive} {chronic_condition}. The {symptom} is bothersome. {emotion}",
    ],
}

# =============================================================================
# FILLER VALUES
# =============================================================================

BODY_PARTS = ['head', 'arm', 'leg', 'back', 'hand', 'foot', 'knee', 'elbow', 'wrist', 'ankle', 'shoulder', 'hip', 'chest', 'forehead', 'neck']
HEIGHTS = ['a ladder', 'the stairs', 'a chair', 'the roof', 'a tree', 'the bed', 'a table']
BURN_SOURCES = ['the stove', 'hot water', 'a hot pan', 'an iron', 'the oven', 'boiling oil', 'a curling iron']
BURN_DESCS = ['blistering badly', 'white and leathery', 'charred', 'peeling', 'very red and raw']
FURNITURE = ['a table', 'the door', 'a chair', 'the bed frame', 'the counter', 'the railing']
CUT_SOURCES = ['a knife while cooking', 'broken glass', 'a sharp edge', 'metal', 'a box cutter']
ACTIVITIES = ['exercising', 'lifting something heavy', 'stretching', 'playing sports', 'working out']
TEMPS = ['103°F', '104°F', '104.5°F', '105°F']
MILD_TEMPS = ['100°F', '100.5°F', '101°F', '101.5°F']
CHILD_TEMPS = ['103°F', '104°F', '103.5°F', '102°F']
MILD_CHILD_TEMPS = ['100°F', '101°F', '100.5°F']
STOOL_URINE = ['stool', 'urine']
CHRONIC_CONDITIONS = ['diabetes', 'asthma', 'arthritis', 'high blood pressure', 'COPD', 'heart condition', 'kidney disease', 'chronic pain']
CHRONIC_SYMPTOMS = ['pain is unbearable', 'breathing is very difficult', 'blood sugar is very high', 'blood pressure is spiking', 'swelling has gotten severe', 'can barely move']
ADDITIONAL = ['can\'t move', 'seems confused', 'in severe pain', 'losing consciousness', 'breathing heavily']

def fill_template(template, person_type, level):
    """Fill a template with random values."""
    person_data = PEOPLE[person_type]
    person = random.choice(person_data)
    
    # Handle pronoun variations
    if person_type == 'self':
        person_short = 'I'
        person_short_lower = 'I'
        is_are = 'am'
        his_her = 'my'
        person_possessive = 'my'
    else:
        person_short = person.split()[-1] if len(person.split()) > 1 else 'They'
        if person_short in ['child', 'son', 'daughter', 'toddler', 'baby', '5-year-old', 'teenager']:
            person_short = 'they'
        person_short_lower = person_short.lower()
        is_are = 'is' if 'my' in person.lower() else 'are'
        his_her = 'their' if person_short_lower in ['they', 'friend', 'roommate'] else ('his' if 'son' in person.lower() or 'father' in person.lower() or 'husband' in person.lower() or 'grandfather' in person.lower() else 'her')
        person_possessive = person.lower().replace('my ', '') + "'s"
    
    text = template
    text = text.replace('{person}', person)
    text = text.replace('{person_short}', person_short)
    text = text.replace('{person_short_lower}', person_short_lower)
    text = text.replace('{is_are}', is_are)
    text = text.replace('{his_her}', his_her)
    text = text.replace('{person_possessive}', person_possessive)
    text = text.replace('{time}', random.choice(TIME_CONTEXTS))
    text = text.replace('{location}', random.choice(LOCATIONS))
    text = text.replace('{body_part}', random.choice(BODY_PARTS))
    text = text.replace('{height}', random.choice(HEIGHTS))
    text = text.replace('{burn_source}', random.choice(BURN_SOURCES))
    text = text.replace('{burn_desc}', random.choice(BURN_DESCS))
    text = text.replace('{furniture}', random.choice(FURNITURE))
    text = text.replace('{cut_source}', random.choice(CUT_SOURCES))
    text = text.replace('{activity}', random.choice(ACTIVITIES))
    text = text.replace('{temp}', random.choice(TEMPS))
    text = text.replace('{mild_temp}', random.choice(MILD_TEMPS))
    text = text.replace('{child_temp}', random.choice(CHILD_TEMPS))
    text = text.replace('{mild_child_temp}', random.choice(MILD_CHILD_TEMPS))
    text = text.replace('{stool_urine}', random.choice(STOOL_URINE))
    text = text.replace('{chronic_condition}', random.choice(CHRONIC_CONDITIONS))
    text = text.replace('{symptom}', random.choice(CHRONIC_SYMPTOMS))
    text = text.replace('{additional}', random.choice(ADDITIONAL))
    text = text.replace('{emotion}', random.choice(EMOTIONS.get(level, EMOTIONS['Medium'])))
    
    return text

def generate_scenario_dataset(target=100000):
    """Generate diverse scenario-based dataset."""
    
    samples = []
    used_hashes = set()
    
    # Define scenario sources with weights
    scenario_sources = [
        (ACCIDENT_SCENARIOS, ['self', 'child', 'elderly', 'spouse', 'friend'], 0.25),
        (ILLNESS_SCENARIOS, ['self', 'child', 'elderly', 'spouse', 'friend'], 0.45),
        (CHILD_SPECIFIC_SCENARIOS, ['child'], 0.15),
        (CHRONIC_FLAREUP_SCENARIOS, ['self', 'elderly'], 0.15),
    ]
    
    attempts = 0
    max_attempts = target * 5
    
    while len(samples) < target and attempts < max_attempts:
        attempts += 1
        
        # Pick random scenario source based on weights
        r = random.random()
        cumsum = 0
        for scenarios, person_types, weight in scenario_sources:
            cumsum += weight
            if r <= cumsum:
                break
        
        # Pick random level (weighted for more medium)
        level_weights = {'Emergency': 0.15, 'High': 0.25, 'Medium': 0.35, 'Low': 0.25}
        level = random.choices(list(level_weights.keys()), weights=list(level_weights.values()))[0]
        
        if level not in scenarios:
            continue
        
        template = random.choice(scenarios[level])
        person_type = random.choice(person_types)
        
        text = fill_template(template, person_type, level)
        
        # Verify triage level matches
        actual_level = classify_scenario(text)
        # Allow some flexibility but prefer matching
        if actual_level != level and random.random() > 0.3:
            level = actual_level
        
        # Check uniqueness
        text_hash = hashlib.md5(text.lower().encode()).hexdigest()
        if text_hash in used_hashes:
            continue
        
        used_hashes.add(text_hash)
        samples.append({
            'text': text,
            'risk_level': level,
        })
        
        if len(samples) % 10000 == 0:
            print(f"   Generated: {len(samples):,}/{target:,}")
    
    return pd.DataFrame(samples)

def augment_with_symptom_data(scenario_df, symptom_df_path, target_total=100000):
    """Combine scenario data with symptom-based data."""
    
    print(f"\n📊 Augmenting with symptom-based data...")
    
    # Load symptom data if exists
    try:
        symptom_df = pd.read_csv(symptom_df_path)
        print(f"   Loaded {len(symptom_df):,} symptom-based samples")
    except:
        print("   No symptom data found, using only scenarios")
        return scenario_df
    
    # Take a subset of symptom data
    symptom_samples = symptom_df.sample(n=min(30000, len(symptom_df)), random_state=42)
    
    # Combine
    combined = pd.concat([scenario_df, symptom_samples[['text', 'risk_level']]], ignore_index=True)
    
    # Remove duplicates
    combined = combined.drop_duplicates(subset=['text'])
    
    return combined

def balance_dataset(df, target_per_class):
    """Balance to target per class."""
    print(f"\n📊 Balancing to {target_per_class:,} per class...")
    
    balanced = []
    for level in ['Emergency', 'High', 'Medium', 'Low']:
        subset = df[df['risk_level'] == level]
        if len(subset) >= target_per_class:
            balanced.append(subset.sample(n=target_per_class, random_state=42))
        else:
            # Oversample
            mult = (target_per_class // len(subset)) + 1
            over = pd.concat([subset] * mult).head(target_per_class)
            balanced.append(over)
        print(f"   {level}: {len(subset):,} → {target_per_class:,}")
    
    result = pd.concat(balanced, ignore_index=True)
    return result.sample(frac=1, random_state=42).reset_index(drop=True)

# =============================================================================
# MAIN
# =============================================================================
if __name__ == "__main__":
    
    # Generate scenario-based samples
    print("\n🔄 Generating scenario-based samples...")
    scenario_df = generate_scenario_dataset(target=80000)
    print(f"   Generated: {len(scenario_df):,} samples")
    print(f"   Distribution: {scenario_df['risk_level'].value_counts().to_dict()}")
    
    # Augment with symptom-based data
    combined_df = augment_with_symptom_data(scenario_df, 'triage_dataset_100k.csv', target_total=120000)
    print(f"\n   Combined: {len(combined_df):,} samples")
    
    # Balance
    final_df = balance_dataset(combined_df, target_per_class=25000)
    
    # Save
    output_file = 'triage_dataset_comprehensive.csv'
    final_df.to_csv(output_file, index=False)
    
    print(f"\n💾 Saved to {output_file}")
    print(f"   Total: {len(final_df):,} samples")
    
    # Show examples
    print("\n📋 Sample scenarios from each level:")
    for level in ['Emergency', 'High', 'Medium', 'Low']:
        sample = final_df[final_df['risk_level'] == level].sample(2, random_state=42)
        print(f"\n   [{level}]")
        for _, row in sample.iterrows():
            print(f"   → {row['text'][:100]}...")
    
    print("\n✅ Done!")
