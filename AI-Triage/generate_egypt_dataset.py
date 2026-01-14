"""
EGYPT-FOCUSED COMPREHENSIVE TRIAGE DATASET
============================================
Real-world scenarios for Egyptian users:
- Celsius temperatures
- Local contexts (Cairo, Alexandria, Suez, etc.)
- Common Egyptian situations (heat, traffic, construction, etc.)
- Cultural considerations (family-centric, elderly care)
- Arabic-English mixing patterns
- Emergency services context
"""

import pandas as pd
import numpy as np
import random
import hashlib

random.seed(42)
np.random.seed(42)

print("=" * 70)
print("🏥 EGYPT-FOCUSED TRIAGE DATASET GENERATOR")
print("=" * 70)

# =============================================================================
# TRIAGE CLASSIFICATION
# =============================================================================
EMERGENCY_KEYWORDS = [
    'heart attack', 'cardiac arrest', 'stroke', 'seizure', 'unconscious',
    'severe bleeding', 'not breathing', 'choking', 'anaphylaxis', 'overdose',
    'drowning', 'electrocution', 'severe burn', 'head trauma', 'spinal injury',
    'diabetic emergency', 'poisoning', 'suicide', 'chest pain radiating',
    'lips turning blue', 'not responsive', 'collapsed', 'convulsing',
]

HIGH_KEYWORDS = [
    'fracture', 'broken bone', 'deep cut', 'high fever', 'severe pain',
    'difficulty breathing', 'blood in', 'concussion', 'infection spreading',
    'appendicitis', 'kidney stone', 'severe allergic', 'dehydration',
    'diabetic', 'asthma attack', 'chest pain', 'severe headache',
    '39°', '40°', '41°', 'heat stroke', 'heat exhaustion',
]

LOW_KEYWORDS = [
    'minor cut', 'small bruise', 'mild cold', 'runny nose', 'mild headache',
    'muscle soreness', 'slight fever', 'paper cut', 'insect bite',
    'dry skin', 'acne', 'minor rash', 'tired', 'stressed', '37°',
]

def classify_scenario(text):
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
# EGYPT-SPECIFIC COMPONENTS
# =============================================================================

# People
PEOPLE = {
    'self': ['I', 'I\'ve', 'I\'m'],
    'child': ['My child', 'My son', 'My daughter', 'My baby', 'My 3-year-old', 'My 7-year-old', 'My toddler'],
    'elderly': ['My mother', 'My father', 'My grandmother', 'My grandfather', 'Teta', 'Gedo', 'My elderly parent'],
    'spouse': ['My husband', 'My wife'],
    'relative': ['My brother', 'My sister', 'My uncle', 'My aunt', 'My cousin'],
    'friend': ['My friend', 'My neighbor', 'My colleague'],
}

# Egyptian Locations/Contexts
LOCATIONS_EGYPT = [
    'at home', 'in the kitchen', 'in the bathroom', 'on the balcony',
    'at work', 'at school', 'in the street', 'at the market',
    'in the metro', 'on the microbus', 'in traffic', 'at the mosque',
    'at the club', 'at the beach', 'in Sahel', 'in the desert trip',
    'at a wedding', 'at a family gathering', 'in the building',
    'on the rooftop', 'in the elevator', 'at the construction site',
    'while crossing the street', 'at the gym', 'at the mall',
]

TIME_CONTEXTS = [
    'just now', 'a few minutes ago', 'about an hour ago', 'this morning',
    'after Fajr prayer', 'after lunch', 'during iftar', 'last night',
    'since yesterday', 'for two days', 'for about a week', 'suddenly',
    'after coming back from work', 'after the gym', 'while sleeping',
]

# Celsius temperatures
TEMPS_HIGH = ['39°C', '39.5°C', '40°C', '40.5°C', '41°C']
TEMPS_MEDIUM = ['38°C', '38.5°C', '37.8°C']
TEMPS_MILD = ['37.2°C', '37.5°C', '37.8°C']
TEMPS_CHILD_HIGH = ['39°C', '39.5°C', '40°C']
TEMPS_CHILD_MILD = ['37.5°C', '38°C', '38.2°C']

# Egyptian summer heat issues
HEAT_CONTEXTS = [
    'was outside in the heat', 'was in the sun for too long',
    'was walking in the street during noon', 'no AC at home',
    'electricity went out during the heatwave', 'was at the beach all day',
]

# Emotions
EMOTIONS = {
    'Emergency': [
        "I'm terrified please help", "This is an emergency", "I don't know what to do",
        "Please send help immediately", "Ya rab please help", "I'm panicking",
        "We need an ambulance", "This is serious", "Please respond quickly",
    ],
    'High': [
        "I'm really worried", "This is concerning", "Should we go to the hospital?",
        "It seems serious", "I'm scared", "It's getting worse",
        "Please advise me what to do", "We're worried about this",
    ],
    'Medium': [
        "I'm a bit concerned", "Is this normal?", "Should I see a doctor?",
        "It's been bothering me", "I want to get it checked",
        "I'm not sure what to do", "Any advice would help",
    ],
    'Low': [
        "It's probably nothing but", "Just wanted to ask", "Not urgent but",
        "I'm just curious", "When I get a chance", "It's minor but",
        "Just for my knowledge", "Nothing serious I think",
    ],
}

# =============================================================================
# COMPREHENSIVE SCENARIO TEMPLATES
# =============================================================================

ACCIDENT_SCENARIOS = {
    'Emergency': [
        "{person} fell from {height} and hit {his_her} head hard. {person_short} {is_are} bleeding a lot and not responding. {emotion}",
        "{person} was in a car accident {location}. There's severe bleeding and {person_short_lower} {is_are} unconscious. {emotion}",
        "{person} got severely burned {location}. The skin is completely charred and blistering. {emotion}",
        "{person} was choking on food and now {is_are} not breathing. {his_her} face is turning blue. {emotion}",
        "{person} fell down the stairs and {his_her} neck is in an awkward position. {person_short} can't move. {emotion}",
        "{person} got electrocuted from a faulty wire {location}. {person_short} {is_are} shaking uncontrollably. {emotion}",
        "{person} was in a construction accident. A heavy object fell on {his_her} head. {emotion}",
        "{person} was hit by a car while crossing the street {time}. {person_short} {is_are} lying on the ground not moving. {emotion}",
        "{person} fell from the rooftop while hanging laundry. {person_short} {is_are} not responding. {emotion}",
        "{person}'s microbus crashed {location}. Multiple people injured, {person_lower} has a head wound. {emotion}",
    ],
    'High': [
        "{person} fell {location} and {his_her} arm looks broken. It's bent at a wrong angle. {emotion}",
        "{person} got a deep cut from broken glass {time}. The bleeding won't stop completely. {emotion}",
        "{person} hit {his_her} head on the elevator door. Now {person_short_lower} {is_are} dizzy and confused. {emotion}",
        "{person} burned {his_her} hand on the stove badly. There are big blisters forming. {emotion}",
        "{person} fell off a motorbike. {his_her} leg is swollen and can't walk on it. {emotion}",
        "{person} got into a fight and was hit in the head. There's a big bump and {person_short_lower} seems confused. {emotion}",
        "{person} cut {his_her} foot on broken glass at the beach. It's deep and bleeding. {emotion}",
        "{person} fell in the bathroom and hit {his_her} back hard. Can barely move now. {emotion}",
        "{person} was stung by a scorpion in Sahara trip. The area is swelling and very painful. {emotion}",
        "{person} got bitten by a stray dog {location}. The wound is deep. {emotion}",
    ],
    'Medium': [
        "{person} twisted {his_her} ankle while walking in the street {time}. It's swollen now. {emotion}",
        "{person} got a cut that might need stitches. It's not too deep but looks bad. {emotion}",
        "{person} bumped {his_her} head on the car door. There's a small bump but seems okay. {emotion}",
        "{person} pulled a muscle at the gym {time}. It hurts to move {his_her} arm. {emotion}",
        "{person} got a burn while ironing. The skin is red but no blisters. {emotion}",
        "{person} fell off the bicycle but caught {himself_herself}. Just scraped up. {emotion}",
        "{person} got hit by a ball during football. {his_her} finger is swollen. {emotion}",
        "{person} slipped in the bathroom and has a bruise on {his_her} hip. {emotion}",
    ],
    'Low': [
        "{person} got a small paper cut at work. It stings but it's tiny. {emotion}",
        "{person} has a small bruise from bumping into the door. {emotion}",
        "{person} scraped {his_her} knee but it's just a light scratch. {emotion}",
        "{person} got a splinter in {his_her} finger. Just need to know how to remove it safely. {emotion}",
        "{person} has a minor sunburn from the beach. Just a bit red. {emotion}",
    ],
}

ILLNESS_SCENARIOS = {
    'Emergency': [
        "{person} is having severe chest pain that goes to {his_her} left arm. {person_short} {is_are} sweating heavily and can't breathe properly. {emotion}",
        "{person} suddenly collapsed and {is_are} not responding to anything. {emotion}",
        "{person} is having a seizure. {his_her} whole body is shaking uncontrollably. {emotion}",
        "{person} took too many pills. {person_short} {is_are} barely conscious and mumbling. {emotion}",
        "{person}'s face is drooping on one side and {person_short_lower} can't speak properly. {emotion}",
        "{person} has been vomiting blood. There's a lot of it. {emotion}",
        "{person} is gasping for air and lips are turning blue. {emotion}",
        "{person} has diabetes and became unresponsive after skipping meals. Sugar might be very low. {emotion}",
        "{person} had an allergic reaction to seafood. Face and throat are swelling up fast. {emotion}",
        "{person} is breathing very fast and shallow, and {his_her} heart is racing dangerously. {emotion}",
    ],
    'High': [
        "{person} has had a fever of {temp} for {time}. Nothing is bringing it down and {person_short_lower} seems confused. {emotion}",
        "{person} has severe chest tightness and difficulty breathing. It's worse when lying down. {emotion}",
        "{person} has blood in {his_her} urine {time}. There's also severe back pain. {emotion}",
        "{person} has the worst headache of {his_her} life. It came on suddenly and is unbearable. {emotion}",
        "{person} has been vomiting everything for {time}. Can't keep any water down. Lips are dry. {emotion}",
        "{person} was out in the heat and now {is_are} confused, not sweating, and very hot. Possible heat stroke. {emotion}",
        "{person} has severe abdominal pain on the right side. It hurts when pressing and releasing. {emotion}",
        "{person}'s asthma attack is not responding to the inhaler. Still struggling to breathe. {emotion}",
        "{person} has kidney stones and the pain is unbearable. Can't sit still. {emotion}",
        "{person} has heart palpitations and feels like might pass out. {emotion}",
        "{person} has blood in stool and has lost a lot of weight recently. {emotion}",
        "{person} has severe infection in the wound. It's red, swollen, and spreading with red lines. {emotion}",
    ],
    'Medium': [
        "{person} has had a cough for {time}. Sometimes there's phlegm. Chest feels heavy. {emotion}",
        "{person} has stomach pain that comes and goes {time}. Worse after eating. {emotion}",
        "{person} has a fever of {mild_temp} with body aches and fatigue. {emotion}",
        "{person} feels dizzy when standing up {time}. Almost fainted once. {emotion}",
        "{person} has a rash that appeared {time}. It's itchy but not spreading fast. {emotion}",
        "{person} has recurring headaches {time}. They're not severe but annoying. {emotion}",
        "{person} has ear pain {time}. Feels like pressure building up inside. {emotion}",
        "{person} has been extremely tired {time}. Even after sleeping well. {emotion}",
        "{person} has a sore throat and can barely swallow. No high fever though. {emotion}",
        "{person} has back pain from sitting at the computer all day. It's getting worse. {emotion}",
        "{person} has had diarrhea for {time}. No blood but very frequent. {emotion}",
        "{person} has heartburn that won't go away even with medication. {emotion}",
        "{person} has shortness of breath when climbing stairs but feels okay at rest. {emotion}",
        "{person} has frequent urination and burning sensation. {emotion}",
    ],
    'Low': [
        "{person} has a runny nose and sneezing. Probably just a cold. {emotion}",
        "{person} has been feeling a bit tired lately. Nothing major. {emotion}",
        "{person} has a slight headache {time}. Took painkillers but asking anyway. {emotion}",
        "{person} has seasonal allergies. Itchy eyes and runny nose. {emotion}",
        "{person} has indigestion after eating too much at the family gathering. {emotion}",
        "{person} has trouble sleeping {time}. Looking for some tips. {emotion}",
        "{person} has dry skin especially in winter. Looking for recommendations. {emotion}",
        "{person} has muscle soreness after exercising. Is this normal? {emotion}",
        "{person} has mild constipation {time}. What should I do? {emotion}",
        "{person} feels stressed from work lately. Any advice? {emotion}",
    ],
}

CHILD_SCENARIOS = {
    'Emergency': [
        "{person} swallowed some cleaning chemicals under the sink. {his_her} mouth is burning. {emotion}",
        "{person} fell from the balcony onto the street. Not moving at all. {emotion}",
        "{person} was found with medicine bottles open. Don't know how many pills taken. {person_short} {is_are} drowsy. {emotion}",
        "{person} is having a seizure for the first time. Whole body shaking. {emotion}",
        "{person} choked on a toy and turned blue before coughing it out. Still not breathing right. {emotion}",
        "{person} has very high fever {temp} and is having strange movements. {emotion}",
    ],
    'High': [
        "{person} has had a fever of {child_temp} for {time}. Very sleepy and not eating. {emotion}",
        "{person} fell at school and the arm looks bent wrong. Crying a lot. {emotion}",
        "{person} has been vomiting and has diarrhea for {time}. Very weak now and crying without tears. {emotion}",
        "{person} has difficulty breathing and a barking cough. Gets worse at night. {emotion}",
        "{person} got stung by a bee and now has a rash spreading on the body. {emotion}",
        "{person} put something in {his_her} nose and can't breathe from that side. {emotion}",
        "{person} has ear pain and fever. Keeps pulling at {his_her} ear and crying. {emotion}",
        "{person}'s lips and fingernails look bluish. Breathing seems fast. {emotion}",
    ],
    'Medium': [
        "{person} has a cough and runny nose {time}. Fever is around {child_mild_temp}. {emotion}",
        "{person} has been complaining of stomach pain {time}. No vomiting. {emotion}",
        "{person} has a rash on the body. Doesn't seem to bother them much. {emotion}",
        "{person} has been cranky and not eating well {time}. {emotion}",
        "{person} fell and has a bump on the forehead but seems fine otherwise. {emotion}",
        "{person} has pink eye and it's spreading to the other eye. {emotion}",
        "{person} has been scratching a lot. Found some spots that might be insect bites. {emotion}",
    ],
    'Low': [
        "{person} has a runny nose but is playing and eating normally. {emotion}",
        "{person} got a tiny scrape at the playground. Just want to know best wound care. {emotion}",
        "{person} has been hiccupping a lot. Is that normal for babies? {emotion}",
        "{person} has a small rash on the cheeks. Could it be from the heat? {emotion}",
        "{person} is teething and a bit fussy. Any tips to help? {emotion}",
    ],
}

ELDERLY_SCENARIOS = {
    'Emergency': [
        "{person} suddenly can't speak and one side of the face is drooping. This started {time}. {emotion}",
        "{person} fell and is not responding. There's blood from the head. {emotion}",
        "{person} has severe chest pain and is very pale and sweating. {emotion}",
        "{person} took double dose of medication by mistake and is very drowsy. {emotion}",
        "{person} is diabetic and became unresponsive. Can't wake them up. {emotion}",
    ],
    'High': [
        "{person} has pneumonia symptoms - high fever {temp}, coughing, and difficulty breathing. {emotion}",
        "{person} fell and can't put weight on {his_her} hip. Very painful to move. {emotion}",
        "{person}'s blood pressure medication isn't working. Reading is {bp}. {emotion}",
        "{person} has confusion and fever {time}. This is not normal for them. {emotion}",
        "{person} has been having chest pain on and off. Also very tired. {emotion}",
        "{person} hasn't urinated in over 24 hours despite drinking fluids. {emotion}",
        "{person} has a wound that's not healing and looks infected. Red and swelling. {emotion}",
    ],
    'Medium': [
        "{person} has been more forgetful than usual {time}. {emotion}",
        "{person} has joint pain that's getting worse. Hard to walk now. {emotion}",
        "{person} has shortness of breath when doing small activities. {emotion}",
        "{person} has swelling in {his_her} legs that doesn't go down. {emotion}",
        "{person} has lost appetite and has been losing weight. {emotion}",
        "{person} is having trouble sleeping and is irritable during the day. {emotion}",
        "{person} has constipation {time} despite eating fiber. {emotion}",
    ],
    'Low': [
        "{person} has dry skin that's very itchy especially at night. {emotion}",
        "{person} wants advice on managing blood pressure naturally. {emotion}",
        "{person} has minor back pain from sitting too much. {emotion}",
        "{person} needs tips for staying active at their age. {emotion}",
    ],
}

PREGNANCY_SCENARIOS = {
    'Emergency': [
        "I'm {weeks} weeks pregnant and having severe bleeding. Soaking through pads. {emotion}",
        "I'm {weeks} weeks pregnant and the baby hasn't moved in over 24 hours. {emotion}",
        "I'm {weeks} weeks pregnant and having severe headache with vision changes and swelling. {emotion}",
        "I'm pregnant and having severe abdominal pain on one side. It's unbearable. {emotion}",
    ],
    'High': [
        "I'm {weeks} weeks pregnant and having regular contractions but it's too early. {emotion}",
        "I'm pregnant and have had light bleeding {time}. Baby is still moving. {emotion}",
        "I'm {weeks} weeks pregnant and my blood pressure is high. Feeling dizzy. {emotion}",
        "I'm pregnant and have had severe vomiting for days. Can't keep anything down. {emotion}",
    ],
    'Medium': [
        "I'm {weeks} weeks pregnant and having Braxton Hicks contractions. Is this normal? {emotion}",
        "I'm pregnant and have back pain and swollen feet. Getting uncomfortable. {emotion}",
        "I'm pregnant and feeling very nauseous {time}. Any tips? {emotion}",
        "I'm {weeks} weeks pregnant and haven't felt movement today but did yesterday. {emotion}",
    ],
    'Low': [
        "I'm pregnant and wondering about safe exercises. {emotion}",
        "I'm pregnant and have heartburn after eating. What can I take? {emotion}",
        "I'm pregnant and need advice about vitamins. {emotion}",
    ],
}

MENTAL_HEALTH_SCENARIOS = {
    'Emergency': [
        "{person} is talking about wanting to end {his_her} life. I found a note. {emotion}",
        "{person} took pills to hurt {himself_herself}. {person_short} {is_are} still conscious but drowsy. {emotion}",
        "{person} is in a psychotic episode. Seeing things and very agitated. {emotion}",
    ],
    'High': [
        "{person} hasn't eaten or slept in days. Very withdrawn and not speaking. {emotion}",
        "{person} is having severe panic attacks multiple times a day. Can't function. {emotion}",
        "{person} is talking about self-harm. Very worried about safety. {emotion}",
    ],
    'Medium': [
        "{person} has been very anxious {time}. Affecting work and sleep. {emotion}",
        "{person} has been feeling very down and hopeless {time}. {emotion}",
        "{person} has trouble sleeping due to racing thoughts. {emotion}",
        "{person} has been having panic attacks occasionally. {emotion}",
    ],
    'Low': [
        "{person} has been feeling stressed from work. Looking for coping tips. {emotion}",
        "{person} has mild anxiety about upcoming events. {emotion}",
        "Looking for general mental health advice for {person_lower}. {emotion}",
    ],
}

HEAT_RELATED_SCENARIOS = {
    'Emergency': [
        "{person} was outside in the sun for hours and now {is_are} not sweating, confused, and skin is hot and red. {emotion}",
        "{person} collapsed while working outside in the heat. {person_short} {is_are} barely conscious. {emotion}",
    ],
    'High': [
        "{person} has heat exhaustion - sweating heavily, dizzy, nauseous, and weak after being in the sun. {emotion}",
        "{person} has severe sunburn with blisters covering {his_her} back and shoulders. {emotion}",
        "{person} is dehydrated from the heat - very thirsty, dark urine, and dizzy. {emotion}",
    ],
    'Medium': [
        "{person} has heat rash and feels uncomfortable in this weather. {emotion}",
        "{person} has a mild sunburn and feels a bit nauseous. {emotion}",
        "{person} has been feeling fatigued from the hot weather. {emotion}",
    ],
}

# =============================================================================
# TEMPLATE FILLING
# =============================================================================

def get_pronoun_data(person_type):
    """Get pronoun data for a person type."""
    data = PEOPLE[person_type]
    person = random.choice(data)
    
    if person_type == 'self':
        return {
            'person': person, 'person_short': 'I', 'person_short_lower': 'I',
            'person_lower': 'I', 'is_are': 'am', 'his_her': 'my',
            'himself_herself': 'myself', 'person_possessive': 'my'
        }
    else:
        p_short = person.split()[-1] if len(person.split()) > 1 else 'they'
        is_male = any(w in person.lower() for w in ['son', 'boy', 'father', 'grandfather', 'gedo', 'husband', 'uncle', 'brother'])
        is_female = any(w in person.lower() for w in ['daughter', 'girl', 'mother', 'grandmother', 'teta', 'wife', 'aunt', 'sister'])
        
        return {
            'person': person, 'person_short': p_short if p_short not in ['old', 'year'] else 'they',
            'person_short_lower': (p_short if p_short not in ['old', 'year'] else 'they').lower(),
            'person_lower': person.lower(),
            'is_are': 'is', 
            'his_her': 'his' if is_male else ('her' if is_female else 'their'),
            'himself_herself': 'himself' if is_male else ('herself' if is_female else 'themselves'),
            'person_possessive': person.lower() + "'s"
        }

def fill_template(template, person_type, level):
    """Fill a template with random values."""
    p = get_pronoun_data(person_type)
    
    text = template
    for key, val in p.items():
        text = text.replace('{' + key + '}', val)
    
    text = text.replace('{time}', random.choice(TIME_CONTEXTS))
    text = text.replace('{location}', random.choice(LOCATIONS_EGYPT))
    text = text.replace('{height}', random.choice(['the stairs', 'a ladder', 'the balcony', 'a chair', 'the bunk bed']))
    text = text.replace('{temp}', random.choice(TEMPS_HIGH))
    text = text.replace('{mild_temp}', random.choice(TEMPS_MEDIUM))
    text = text.replace('{child_temp}', random.choice(TEMPS_CHILD_HIGH))
    text = text.replace('{child_mild_temp}', random.choice(TEMPS_CHILD_MILD))
    text = text.replace('{weeks}', random.choice(['8', '12', '20', '28', '32', '36', '38']))
    text = text.replace('{bp}', random.choice(['180/110', '190/120', '170/105']))
    text = text.replace('{emotion}', random.choice(EMOTIONS.get(level, EMOTIONS['Medium'])))
    
    return text

def generate_datasets(target=100000):
    """Generate comprehensive dataset."""
    
    all_scenarios = [
        (ACCIDENT_SCENARIOS, ['self', 'child', 'elderly', 'spouse', 'relative', 'friend'], 0.20),
        (ILLNESS_SCENARIOS, ['self', 'child', 'elderly', 'spouse', 'relative', 'friend'], 0.35),
        (CHILD_SCENARIOS, ['child'], 0.15),
        (ELDERLY_SCENARIOS, ['elderly'], 0.10),
        (PREGNANCY_SCENARIOS, ['self'], 0.08),
        (MENTAL_HEALTH_SCENARIOS, ['self', 'relative', 'friend'], 0.07),
        (HEAT_RELATED_SCENARIOS, ['self', 'child', 'elderly', 'friend'], 0.05),
    ]
    
    samples = []
    used_hashes = set()
    attempts = 0
    max_attempts = target * 5
    
    print(f"\n🔄 Generating {target:,} unique samples...")
    
    while len(samples) < target and attempts < max_attempts:
        attempts += 1
        
        # Pick scenario type based on weights
        r = random.random()
        cumsum = 0
        for scenarios, person_types, weight in all_scenarios:
            cumsum += weight
            if r <= cumsum:
                break
        
        # Pick level
        level = random.choices(
            ['Emergency', 'High', 'Medium', 'Low'],
            weights=[0.15, 0.25, 0.35, 0.25]
        )[0]
        
        if level not in scenarios:
            continue
        
        template = random.choice(scenarios[level])
        person_type = random.choice(person_types)
        
        text = fill_template(template, person_type, level)
        
        # Verify and potentially adjust level
        actual_level = classify_scenario(text)
        if actual_level != level and random.random() > 0.3:
            level = actual_level
        
        # Uniqueness check
        text_hash = hashlib.md5(text.lower().encode()).hexdigest()
        if text_hash in used_hashes:
            continue
        
        used_hashes.add(text_hash)
        samples.append({'text': text, 'risk_level': level})
        
        if len(samples) % 20000 == 0:
            print(f"   Generated: {len(samples):,}/{target:,}")
    
    return pd.DataFrame(samples)

def balance_dataset(df, target_per_class=25000):
    """Balance dataset."""
    print(f"\n📊 Balancing to {target_per_class:,} per class...")
    
    balanced = []
    for level in ['Emergency', 'High', 'Medium', 'Low']:
        subset = df[df['risk_level'] == level]
        if len(subset) >= target_per_class:
            balanced.append(subset.sample(n=target_per_class, random_state=42))
        else:
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
    
    # Generate scenarios
    df = generate_datasets(target=150000)
    print(f"\n   Generated: {len(df):,} samples")
    print(f"   Distribution: {df['risk_level'].value_counts().to_dict()}")
    
    # Balance
    final_df = balance_dataset(df, target_per_class=25000)
    
    # Save
    output_file = 'triage_dataset_egypt.csv'
    final_df.to_csv(output_file, index=False)
    
    print(f"\n💾 Saved to {output_file}")
    print(f"   Total: {len(final_df):,} samples")
    
    # Show examples
    print("\n📋 Sample scenarios:")
    for level in ['Emergency', 'High', 'Medium', 'Low']:
        print(f"\n   [{level}]")
        for text in final_df[final_df['risk_level'] == level].sample(2, random_state=42)['text']:
            print(f"   → {text[:120]}...")
    
    print("\n✅ Done!")
