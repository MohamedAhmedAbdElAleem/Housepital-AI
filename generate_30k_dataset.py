"""
Generate 30K High-Quality Medical Triage Dataset
================================================
Creates diverse, unique symptom descriptions for each risk level.
Target: 7,500 samples per class = 30,000 total
"""

import csv
import random
import hashlib

random.seed(42)

# =============================================================================
# SYMPTOM COMPONENTS - Building blocks for unique sentences
# =============================================================================

# Time expressions
TIMES = [
    "for the past hour", "since this morning", "for two days", "for a week",
    "since yesterday", "for several hours", "all day", "for the past few days",
    "suddenly", "out of nowhere", "gradually over time", "intermittently",
    "constantly", "on and off", "especially at night", "when I wake up",
    "after eating", "during activity", "at rest", "for months now"
]

# Severity modifiers
SEVERITY_EMERGENCY = ["extremely", "severely", "critically", "life-threateningly", "unbearably", "excruciatingly"]
SEVERITY_HIGH = ["very", "significantly", "seriously", "notably", "considerably", "quite"]
SEVERITY_MEDIUM = ["moderately", "somewhat", "fairly", "noticeably", "mildly to moderately"]
SEVERITY_LOW = ["slightly", "mildly", "a little", "somewhat", "minimally"]

# Emotional expressions
EMOTIONS = [
    "I'm really scared", "I'm worried", "I'm concerned", "This is frightening",
    "I don't know what to do", "I need help", "Please help me", "I'm panicking",
    "I'm anxious about this", "This is affecting my life", "I can't function normally",
    "I'm desperate", "I'm terrified", "This is frustrating", "I'm exhausted from this"
]

# Body parts
BODY_PARTS = [
    "chest", "head", "stomach", "back", "arm", "leg", "neck", "shoulder",
    "knee", "ankle", "wrist", "hip", "abdomen", "throat", "foot", "hand"
]

# =============================================================================
# EMERGENCY SYMPTOMS (Life-threatening, call 911)
# =============================================================================

EMERGENCY_TEMPLATES = [
    # Cardiac
    "I'm having {severity} chest pain that's radiating down my left arm and I'm sweating profusely {time}.",
    "My chest feels like it's being crushed and I can't catch my breath. {emotion}.",
    "I'm experiencing crushing chest pain with numbness in my jaw and left arm {time}.",
    "Sudden {severity} chest tightness with cold sweats and nausea. I think I'm having a heart attack.",
    "My heart is racing uncontrollably and I feel like I'm going to pass out {time}.",
    "Sharp stabbing chest pain that gets worse when I breathe. {emotion}.",
    "I woke up with {severity} chest pressure and my arm is numb. I'm scared.",
    
    # Respiratory
    "I can't breathe properly and my lips are turning blue. {emotion}.",
    "I'm gasping for air and feel like I'm suffocating {time}.",
    "{severity} difficulty breathing, I can barely get any air in.",
    "My throat is swelling shut and I can't swallow. I think it's anaphylaxis.",
    "Sudden {severity} shortness of breath, I feel like I'm drowning.",
    "I'm wheezing badly and my inhaler isn't helping. My lips look bluish.",
    "Can't catch my breath at all, chest is {severity} tight.",
    
    # Stroke
    "Half of my face is drooping and I can't lift my right arm {time}.",
    "Sudden {severity} confusion, I can't speak properly and my face feels numb.",
    "I lost vision in one eye suddenly and my speech is slurred.",
    "One side of my body went completely weak, I think I'm having a stroke.",
    "Sudden {severity} headache like a thunderclap with vision changes.",
    "I can't understand what people are saying and my left side is weak.",
    
    # Bleeding/Trauma
    "I'm bleeding heavily from a wound and can't stop it. Blood is everywhere.",
    "I was in an accident and I'm losing a lot of blood {time}.",
    "Deep cut that won't stop bleeding, I'm feeling dizzy from blood loss.",
    "{severity} bleeding from my head after a fall. Feeling very weak.",
    
    # Neurological
    "I'm having a seizure and can't stop shaking. {emotion}.",
    "Uncontrollable convulsions, this has never happened before.",
    "I lost consciousness and woke up confused with no memory of what happened.",
    "Sudden {severity} weakness on one side, I can't move my arm or leg.",
    
    # Allergic
    "My throat is closing up and I'm covered in hives. Can't breathe properly.",
    "Severe allergic reaction - face is swelling and I'm having trouble breathing.",
    "I think I'm going into anaphylactic shock. Lips and tongue are swelling.",
    
    # Other emergencies
    "I overdosed on medication and I'm feeling very drowsy, can barely stay awake.",
    "Drank something toxic by accident, my vision is blurry and I'm vomiting.",
    "Severe burns covering my arm, the pain is {severity} and skin is blistering badly.",
    "I was exposed to extreme cold, my fingers are white and I can't feel them.",
    "High fever with stiff neck and I can't tolerate light - possible meningitis.",
    "{severity} abdominal pain with vomiting blood. I need emergency help.",
    "Sudden {severity} headache, the worst of my life, with neck stiffness.",
    "I'm diabetic and my sugar is critically low, I'm shaking and confused.",
    "Chest trauma from an accident, I can hear air escaping when I breathe.",
    "Pregnant with severe abdominal pain and heavy bleeding.",
]

# =============================================================================
# HIGH RISK SYMPTOMS (Serious, needs urgent care within 2-4 hours)
# =============================================================================

HIGH_TEMPLATES = [
    # Cardiac concerns
    "I've been having chest pain that comes and goes with exertion {time}.",
    "Sharp chest pain that's been persistent {time}. Gets worse when I move.",
    "Heart palpitations that won't stop {time}. Feeling anxious and weak.",
    "Chest tightness and shortness of breath during any physical activity.",
    "{severity} chest discomfort with irregular heartbeat {time}.",
    
    # High fever with concerning symptoms
    "High fever of 104°F with confusion and severe headache {time}.",
    "Fever that won't come down with medication, now having chills and sweating.",
    "High temperature with stiff neck, light sensitivity bothers me a lot.",
    "Fever of 103 with {severity} body aches and difficulty breathing.",
    "Persistent high fever {time} with a rash that's spreading.",
    
    # Severe pain
    "{severity} abdominal pain in the lower right side, worse when I move.",
    "The pain in my abdomen is {severity} and hasn't improved in hours.",
    "Intense headache with vision changes and nausea {time}.",
    "{severity} back pain radiating down my leg, can barely walk.",
    "Pain in my chest when I take deep breaths {time}.",
    
    # Infection signs
    "Wound is red, swollen, and warm with red streaks spreading up my arm.",
    "Infected cut that's getting worse, now have fever and chills.",
    "Signs of infection spreading - redness expanding, feeling feverish.",
    "Abscess that's growing larger and more painful {time}.",
    
    # Respiratory
    "Difficulty breathing when lying down, have to sit up to catch my breath.",
    "Coughing up blood {time}, very worried about what this means.",
    "Persistent cough with blood-tinged mucus and chest pain.",
    "Severe asthma attack, medications only providing temporary relief.",
    
    # Vascular
    "Leg is swollen, warm, and painful - possible blood clot.",
    "Sudden swelling in one calf with tenderness {time}.",
    "One leg is much more swollen than the other with pain when walking.",
    
    # Psychiatric crisis
    "Having thoughts of harming myself, I don't feel safe.",
    "Severe anxiety attack that won't stop, heart racing for hours.",
    "Feeling very depressed and hopeless, need to talk to someone urgently.",
    
    # Other high-risk
    "Severe dehydration - very dizzy, haven't urinated in hours.",
    "Uncontrolled vomiting {time}, can't keep anything down.",
    "Blood in my urine with severe flank pain {time}.",
    "{severity} pain after an injury, possible fracture.",
    "Diabetic with blood sugar reading of 350, feeling very unwell.",
    "Severe headache after hitting my head, now feeling confused.",
    "Testicular pain and swelling that started suddenly.",
    "Eye injury with pain, blurred vision, and sensitivity to light.",
    "Sudden hearing loss in one ear with dizziness.",
]

# =============================================================================
# MEDIUM RISK SYMPTOMS (Moderate, should see doctor in 1-2 days)
# =============================================================================

MEDIUM_TEMPLATES = [
    # Persistent symptoms
    "I've had a cough that won't go away {time}. It's getting annoying.",
    "Cold symptoms that have lasted more than a week without improvement.",
    "Persistent sore throat with mild fever {time}.",
    "Nasal congestion and headache that's been bothering me {time}.",
    
    # Moderate pain
    "Headache that comes and goes {time}. Over-the-counter meds help a little.",
    "Back pain from sitting at my desk, it's {severity} uncomfortable.",
    "Knee pain when I walk, especially going up stairs {time}.",
    "Shoulder pain that makes it hard to raise my arm above my head.",
    "Stomach cramps after eating certain foods {time}.",
    
    # Skin issues
    "Rash on my arm that appeared a few days ago, slightly itchy.",
    "Skin infection that's not spreading but isn't healing either.",
    "Eczema flare-up that's {severity} itchy and bothering me.",
    "Bumps on my skin that have been there {time}.",
    
    # Gastrointestinal
    "Upset stomach and mild nausea {time}. Not vomiting though.",
    "Diarrhea {time} but no fever or blood.",
    "Constipation that's been uncomfortable {time}.",
    "Heartburn that's more frequent than usual lately.",
    "Bloating and gas after meals {time}.",
    
    # Urinary
    "Burning sensation when urinating {time}. Need to go frequently.",
    "Frequent urination with mild discomfort. Worried about UTI.",
    "Urinary urgency that's been bothersome {time}.",
    
    # Respiratory (mild)
    "Mild wheezing when I exercise, goes away after rest.",
    "Shortness of breath when climbing stairs, gets better when I rest.",
    "Chest feels a bit tight in the mornings {time}.",
    
    # Ear/Eye/Throat
    "Ear pain that started yesterday. Feels like pressure inside.",
    "Pink eye - eye is red and watery with some discharge.",
    "Sore throat that makes swallowing uncomfortable {time}.",
    "Hoarse voice that's been going on {time}.",
    
    # Musculoskeletal
    "Muscle pain from exercising, quite sore {time}.",
    "Joint stiffness in the morning that improves throughout the day.",
    "Twisted my ankle a few days ago, still {severity} swollen.",
    "Neck stiffness from sleeping wrong, hard to turn my head.",
    
    # General
    "Feeling more tired than usual {time}. Low energy throughout the day.",
    "Mild dizziness when I stand up too fast.",
    "Loss of appetite {time} but no other symptoms.",
    "Low-grade fever that comes and goes {time}.",
    "Feeling run down and not quite right {time}.",
]

# =============================================================================
# LOW RISK SYMPTOMS (Minor, routine care acceptable)
# =============================================================================

LOW_TEMPLATES = [
    # Common cold
    "I have a mild cold with runny nose and slight congestion.",
    "Sneezing and stuffy nose {time}. Typical cold symptoms.",
    "Slight sore throat and mild cough, probably just a cold.",
    "Feeling under the weather with mild cold symptoms.",
    
    # Minor pain
    "Slight headache that comes and goes. Not too bothersome.",
    "Minor muscle ache from working out yesterday.",
    "Small tension headache, probably from staring at screens too long.",
    "Mild back stiffness in the morning, goes away after moving.",
    "Little bit of soreness in my shoulder from sleeping on it wrong.",
    
    # Skin (minor)
    "Small cut on my finger from cooking. Cleaned it up.",
    "Minor scrape on my knee from a fall. Already stopped bleeding.",
    "Dry skin patch on my elbow that's a bit itchy.",
    "Small pimple that's slightly irritated.",
    "Minor sunburn on my shoulders from being outside.",
    
    # General wellness
    "Just feeling a little tired today. Probably need more sleep.",
    "Slight fatigue, nothing too concerning.",
    "Feeling a bit off but nothing specific.",
    "Minor seasonal allergies acting up.",
    "Eyes feel a bit dry and tired from reading.",
    
    # Digestion (minor)
    "Slight stomach discomfort after eating too much.",
    "A bit of indigestion after a heavy meal.",
    "Minor bloating after eating beans.",
    "Slight nausea that came and went quickly.",
    
    # Questions and checkups
    "Want to know if I should be concerned about a mole.",
    "Wondering about vitamins and supplements.",
    "Question about my medication dosage.",
    "Need a routine health checkup.",
    "Curious about healthy eating habits.",
    "Looking for advice on better sleep.",
    "Want to discuss exercise recommendations.",
    "General wellness question about my health.",
    
    # Chronic stable
    "My chronic condition is stable, just monitoring.",
    "Regular check on my blood pressure medication.",
    "Following up on previous minor concern.",
    "Prescription refill needed.",
    
    # Very minor
    "Paper cut on my finger. Already applied bandaid.",
    "Hangnail that's slightly annoying.",
    "Chapped lips from the cold weather.",
    "Slight bruise from bumping into furniture.",
    "Minor insect bite that's a bit itchy.",
    "Feeling a bit stressed but managing.",
    "Mild seasonal sniffles.",
    "Just a general wellness inquiry.",
]

# =============================================================================
# VARIATION FUNCTIONS
# =============================================================================

def get_variation_starters():
    """Different ways to start sentences for variety."""
    return [
        "", "I'm experiencing ", "I've been having ", "I noticed ", 
        "For a while now, ", "Recently, ", "Today, ", "Last night, ",
        "This morning, ", "I woke up with ", "I've developed ",
        "I'm suffering from ", "I'm dealing with ", "I can't shake ",
        "I've noticed that ", "It started when ", "Ever since yesterday, ",
        "A few hours ago, ", "Suddenly, ", "Gradually, "
    ]

def get_variation_enders():
    """Different ways to end sentences for variety."""
    return [
        "", " What should I do?", " Is this serious?", " Should I be worried?",
        " I need advice.", " Please help.", " This is concerning me.",
        " Any suggestions?", " What does this mean?", " I'm not sure what to do.",
        " It's really bothering me.", " I hope it's nothing serious.",
        " Can you help?", " I'm looking for guidance.", " Is this normal?",
    ]

def create_unique_variant(template, severity_list, used_hashes):
    """Create a unique variation of a template."""
    max_attempts = 50
    
    for _ in range(max_attempts):
        text = template
        
        # Replace placeholders
        if "{severity}" in text:
            text = text.replace("{severity}", random.choice(severity_list))
        if "{time}" in text:
            text = text.replace("{time}", random.choice(TIMES))
        if "{emotion}" in text:
            text = text.replace("{emotion}", random.choice(EMOTIONS))
        if "{body_part}" in text:
            text = text.replace("{body_part}", random.choice(BODY_PARTS))
        
        # Add variation
        if random.random() > 0.5:
            starter = random.choice(get_variation_starters())
            if starter and not text[0].isupper():
                text = starter + text
            elif starter:
                text = starter + text[0].lower() + text[1:]
        
        if random.random() > 0.6:
            text = text.rstrip('.') + random.choice(get_variation_enders())
        
        # Check uniqueness
        text_hash = hashlib.md5(text.lower().encode()).hexdigest()
        if text_hash not in used_hashes:
            used_hashes.add(text_hash)
            return text
    
    return None

def generate_dataset(target_per_class=7500):
    """Generate balanced dataset with unique samples."""
    
    print("=" * 60)
    print("🏥 GENERATING 30K HIGH-QUALITY MEDICAL TRIAGE DATASET")
    print("=" * 60)
    print(f"Target: {target_per_class} samples per class = {target_per_class * 4:,} total")
    
    all_samples = []
    used_hashes = set()
    
    configs = [
        ("Emergency", EMERGENCY_TEMPLATES, SEVERITY_EMERGENCY),
        ("High", HIGH_TEMPLATES, SEVERITY_HIGH),
        ("Medium", MEDIUM_TEMPLATES, SEVERITY_MEDIUM),
        ("Low", LOW_TEMPLATES, SEVERITY_LOW),
    ]
    
    for risk_level, templates, severity_list in configs:
        print(f"\n📝 Generating {risk_level} samples...")
        count = 0
        attempts = 0
        max_attempts = target_per_class * 10
        
        while count < target_per_class and attempts < max_attempts:
            template = random.choice(templates)
            text = create_unique_variant(template, severity_list, used_hashes)
            
            if text:
                all_samples.append({
                    'disease': f"{risk_level.lower()}_condition",
                    'text': text,
                    'risk_level': risk_level
                })
                count += 1
                
                if count % 1000 == 0:
                    print(f"   Generated {count:,}/{target_per_class:,}")
            
            attempts += 1
        
        print(f"   ✅ {risk_level}: {count:,} unique samples generated")
    
    # Shuffle
    random.shuffle(all_samples)
    
    return all_samples

def save_dataset(samples, filename):
    """Save to CSV."""
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['disease', 'text', 'risk_level'])
        writer.writeheader()
        writer.writerows(samples)
    print(f"\n💾 Saved {len(samples):,} samples to {filename}")

# =============================================================================
# MAIN
# =============================================================================
if __name__ == "__main__":
    # Generate dataset
    samples = generate_dataset(target_per_class=7500)
    
    # Save
    save_dataset(samples, 'triage_dataset_30k.csv')
    
    # Stats
    print("\n📊 Final Distribution:")
    from collections import Counter
    dist = Counter(s['risk_level'] for s in samples)
    for risk in ['Emergency', 'High', 'Medium', 'Low']:
        count = dist[risk]
        pct = count / len(samples) * 100
        print(f"   {risk:12}: {count:5,} ({pct:5.1f}%)")
    
    print(f"\n✅ Total: {len(samples):,} unique samples")
    print("=" * 60)
