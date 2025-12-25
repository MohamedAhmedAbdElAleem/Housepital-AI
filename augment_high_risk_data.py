# High-Risk Symptom Data Augmentation
# This script adds balanced High-risk symptom data to the dataset

import csv
import random

# Original High-risk diseases from the dataset
HIGH_RISK_DISEASES = [
    "abscess of the lung",
    "adrenal adenoma",
    "amyloidosis",
    "anemia due to malignancy",
    "aspergillosis",
    "central atherosclerosis",
    "congenital heart defect",
    "congenital malformation syndrome",
    "conversion disorder",
    "frostbite",
    "glucocorticoid deficiency",
    "granuloma inguinale",
    "high blood pressure",
    "hyperlipidemia",
    "hypertrophic obstructive cardiomyopathy (hocm)",
    "hypothermia",
    "intracranial abscess",
    "kidney disease due to longstanding hypertension",
    "malaria",
    "myocarditis",
    "myoclonus",
    "open wound of the chest",
    "pneumoconiosis",
    "poisoning due to antipsychotics",
    "poisoning due to ethylene glycol",
    "pulmonic valve disease",
    "syringomyelia",
    "tuberculosis",
    "tuberous sclerosis",
    "valley fever",
    "vertebrobasilar insufficiency",
    "zenker diverticulum",
]

# Clinically-accurate symptom templates for High-risk conditions
# High risk = Serious but not immediately life-threatening, needs care within 2-4 hours

SYMPTOM_TEMPLATES = {
    "abscess of the lung": [
        "I've had a persistent fever for days now, and my cough brings up thick yellow mucus that smells awful.",
        "The sharp pain in my chest when I breathe is getting worse, and I'm sweating through my clothes at night.",
        "I can't stop coughing up this disgusting sputum, and my fever won't break even with medication.",
        "My breathing has become labored, and I feel exhausted from fighting this lung infection.",
        "The chest pain is unbearable when I cough, and I've lost my appetite completely.",
        "I've been having night sweats for a week, and now I'm coughing up blood-tinged mucus.",
        "Every breath feels like a struggle, and the fever keeps coming back despite antibiotics.",
        "My cough has gotten much worse, and the pain in my side is sharp and constant.",
    ],
    "adrenal adenoma": [
        "I can't control my anxiety anymore; my heart races and I sweat constantly without reason.",
        "My blood pressure readings have been dangerously high, and I feel on edge all the time.",
        "I've gained weight rapidly around my midsection, and my face looks puffy and swollen.",
        "The muscle weakness is getting worse, and I feel exhausted despite sleeping enough.",
        "I'm experiencing severe mood swings and my blood pressure is out of control.",
        "My skin bruises easily now, and I've noticed purple stretch marks appearing.",
        "I feel jittery and my heart pounds even when I'm resting; something feels very wrong.",
        "The anxiety attacks come out of nowhere, and my blood pressure spikes dangerously.",
    ],
    "amyloidosis": [
        "My legs are swollen and I'm struggling to breathe when I lie down at night.",
        "I've noticed my tongue feels enlarged, and swallowing has become difficult.",
        "The fatigue is overwhelming, and I've lost a lot of weight without trying.",
        "My heart feels like it's racing irregularly, and I get dizzy when I stand up.",
        "The numbness and tingling in my hands and feet is getting worse every day.",
        "I'm constantly short of breath, and my ankles are swollen by the end of the day.",
        "My skin has strange waxy patches, and I feel exhausted all the time.",
        "I've been having foamy urine and my legs swell up badly throughout the day.",
    ],
    "anemia due to malignancy": [
        "I'm so exhausted I can barely get through the day, and I look pale as a ghost.",
        "The fatigue has gotten so bad that I need to rest after walking just a few steps.",
        "I'm constantly out of breath, and my heart pounds even when I'm sitting still.",
        "I've been experiencing dizziness and weakness that won't go away no matter how much I rest.",
        "My skin is pale and I feel cold all the time; even small tasks exhaust me completely.",
        "The headaches and dizziness are constant, and I can't concentrate on anything.",
        "I feel like I'm going to faint every time I stand up; the weakness is overwhelming.",
        "My energy is completely gone, and I've noticed I'm bruising much more easily than before.",
    ],
    "aspergillosis": [
        "I've been wheezing for weeks, and my asthma medications aren't helping anymore.",
        "The coughing fits are severe, and I'm bringing up thick brown mucus.",
        "My chest feels tight constantly, and I'm running a low-grade fever that won't quit.",
        "I can feel something is wrong in my lungs; the pain and breathlessness are getting worse.",
        "The blood in my sputum is terrifying, and I can't take a deep breath without pain.",
        "My breathing has become labored, and I feel feverish and weak all the time.",
        "The persistent cough and chest pain are affecting my sleep and daily activities.",
        "I'm losing weight and feel constantly exhausted; my respiratory symptoms are worsening.",
    ],
    "central atherosclerosis": [
        "I get severe chest tightness when I walk uphill, and it takes forever to catch my breath.",
        "My legs cramp painfully after walking just a short distance.",
        "The shortness of breath when I exercise is getting much worse than before.",
        "I feel pressure in my chest during physical activity that goes away when I rest.",
        "My calves ache terribly after walking, and my feet feel cold and numb.",
        "The fatigue and breathlessness during normal activities is really alarming me.",
        "I notice my pulse seems weak in my legs, and wounds on my feet heal very slowly.",
        "Climbing stairs has become nearly impossible; I'm gasping for air after just a few steps.",
    ],
    "congenital heart defect": [
        "I've been getting increasingly short of breath during activities that never bothered me before.",
        "My lips and fingernails turn bluish when I exert myself, and I feel faint.",
        "The heart palpitations are getting more frequent and intense; I can feel my heart skipping beats.",
        "I'm constantly fatigued and can't keep up with my friends during normal activities.",
        "The swelling in my ankles won't go away, and I'm struggling to breathe when lying flat.",
        "I've been experiencing chest pain and irregular heartbeats that worry me constantly.",
        "My exercise tolerance has dropped dramatically, and I feel dizzy after minimal effort.",
        "The bluish tint to my skin is more noticeable now, and I tire very easily.",
    ],
    "congenital malformation syndrome": [
        "My child is having difficulty breathing and seems to tire very easily during feeding.",
        "The developmental delays are concerning, and now there are new symptoms appearing.",
        "I'm worried about my child's persistent symptoms that seem to be getting worse.",
        "The pain and discomfort my child experiences daily is heartbreaking to witness.",
        "Multiple health issues keep arising, and it's exhausting trying to manage them all.",
        "My child's breathing problems are getting worse, and feeds take forever to complete.",
        "The muscle weakness is progressing, and daily activities are becoming harder.",
        "I can see my child struggling more and more with basic functions that should be easy.",
    ],
    "conversion disorder": [
        "I've suddenly lost the ability to move my legs, and the doctors can't find a cause.",
        "My vision went blurry out of nowhere, and now I'm having trouble seeing clearly.",
        "The numbness in my arms came on suddenly, and it's not going away.",
        "I keep having episodes where I can't speak, and it's terrifying.",
        "My body feels paralyzed at times, but tests show nothing physically wrong.",
        "The sudden weakness makes me fall unexpectedly, and I'm scared to go out alone.",
        "I'm experiencing tremors that I can't control, and they started suddenly.",
        "My limbs feel heavy and unresponsive, and the symptoms come and go unpredictably.",
    ],
    "frostbite": [
        "My fingers are white and waxy, and I can't feel them at all anymore.",
        "The skin on my toes has turned hard and dark, and the pain is excruciating.",
        "I was exposed to the cold for too long, and now my skin is blistering badly.",
        "My ears are swollen and have turned purple; the burning sensation is intense.",
        "The numbness has turned to severe pain as my fingers start to thaw.",
        "Large blisters have formed on my hands, and the skin looks grayish-white.",
        "I can't move my fingers properly after being in the cold; they're stiff and discolored.",
        "The affected areas are turning black at the edges, and the pain is unbearable.",
    ],
    "glucocorticoid deficiency": [
        "I feel weak and dizzy constantly, and I've lost my appetite completely.",
        "The fatigue is so severe I can barely function, and I've lost weight rapidly.",
        "I feel nauseated all the time and my skin seems darker than usual.",
        "The muscle weakness and joint pain make every movement a struggle.",
        "I crave salt constantly, and I feel like I'm going to faint when I stand.",
        "My blood pressure drops dangerously when I stand up, making me dizzy.",
        "The exhaustion is overwhelming, and even simple tasks feel impossible.",
        "I've been having severe abdominal pain and my energy levels are critically low.",
    ],
    "granuloma inguinale": [
        "The sores in my groin area are spreading and bleeding when I walk.",
        "The painless ulcers have grown larger, and the tissue looks raw and red.",
        "I'm noticing the infection spreading to other areas, and it's very concerning.",
        "The granulated tissue keeps bleeding, and the sores won't heal on their own.",
        "The lesions have become quite extensive and are affecting my daily comfort.",
        "I've had these spreading sores for weeks, and they're getting worse, not better.",
        "The beefy red appearance of the ulcers is alarming, and they keep growing.",
        "The affected area is quite large now, and the tissue destruction is worrying.",
    ],
    "high blood pressure": [
        "My blood pressure readings have been dangerously high, and I'm having severe headaches.",
        "I'm experiencing chest tightness and my vision is getting blurry from my blood pressure.",
        "The pounding headache and neck pain won't go away; my blood pressure is through the roof.",
        "I feel like my heart is racing, and my blood pressure medication isn't controlling it anymore.",
        "The nosebleeds are happening frequently, and my blood pressure is spiking dangerously.",
        "I'm having difficulty breathing and my blood pressure is extremely elevated.",
        "The headaches are severe and persistent, and I'm seeing spots in my vision.",
        "My heart is pounding and I feel flushed; my blood pressure readings are alarming.",
    ],
    "hyperlipidemia": [
        "I'm having chest discomfort when I exert myself, and my cholesterol is very high.",
        "The chest tightness during exercise is concerning, and my lipid panel is very abnormal.",
        "I'm noticing yellowish deposits around my eyes, and my cholesterol levels are dangerous.",
        "The pain in my legs when walking has gotten worse; circulation seems very poor.",
        "My family history combined with my high cholesterol has me very worried about my heart.",
        "I'm experiencing shortness of breath, and my cholesterol levels are extremely elevated.",
        "The fatty deposits on my skin are new, and my blood tests show high lipid levels.",
        "Chest pressure during activity and extremely high cholesterol have me concerned about a heart attack.",
    ],
    "hypertrophic obstructive cardiomyopathy (hocm)": [
        "My heart races suddenly and I feel like I might pass out; the palpitations are terrifying.",
        "I get severe chest pain during exercise, and I've nearly fainted several times.",
        "The shortness of breath is getting worse, and my heart feels like it's pounding out of my chest.",
        "I can feel my heart beating irregularly, and I get dizzy with any exertion.",
        "The chest pressure during activity is intense, and I'm afraid to exercise anymore.",
        "My family has a history of sudden cardiac death, and now I'm having these scary symptoms.",
        "I've been having episodes where my heart races uncontrollably and I nearly black out.",
        "The fatigue and breathlessness during normal activities is significantly limiting my life.",
    ],
    "hypothermia": [
        "My body temperature is dangerously low, and I can't stop shivering violently.",
        "I'm confused and having trouble thinking clearly; everything feels slow and cold.",
        "The shivering has stopped but I still feel extremely cold and drowsy.",
        "My movements are slow and clumsy, and I can't seem to warm up no matter what I do.",
        "I'm feeling very sleepy and my speech is slurred after being in the cold too long.",
        "The cold exposure has left me feeling weak and disoriented; I need help warming up.",
        "My hands are blue and I'm having trouble coordinating my movements.",
        "I feel extremely drowsy and my heart rate seems slow after being exposed to the cold.",
    ],
    "intracranial abscess": [
        "The headache is the worst I've ever had, and now I'm running a high fever.",
        "I'm experiencing confusion and my headache won't respond to any medication.",
        "The neck stiffness and severe headache are making it impossible to function.",
        "I've been having seizures and the headache is unbearable; something is very wrong.",
        "My vision has become blurry and the headache and fever are getting worse.",
        "The persistent fever and worsening headache have me extremely worried.",
        "I'm feeling confused and nauseous, and the pain in my head is excruciating.",
        "The headache came on suddenly and I've been having trouble with my balance.",
    ],
    "kidney disease due to longstanding hypertension": [
        "My blood pressure is still high despite medication, and my legs are swollen.",
        "I'm urinating much less than usual, and I feel exhausted and weak constantly.",
        "The swelling in my ankles and face is getting worse, and I feel nauseated.",
        "My blood pressure has been uncontrolled for years, and now my kidneys are suffering.",
        "I'm experiencing severe fatigue and my urine looks foamy and discolored.",
        "The persistent nausea and loss of appetite are new symptoms that worry me.",
        "I can barely produce urine, and the swelling throughout my body is alarming.",
        "My kidney function tests are concerning, and I feel weak and dizzy often.",
    ],
    "malaria": [
        "The fever comes in waves with violent shaking chills, and I feel terrible.",
        "I'm having severe sweating episodes after the chills pass, and I feel utterly drained.",
        "The headache and body aches from malaria are making every moment miserable.",
        "I've been vomiting and the high fever keeps cycling back every few hours.",
        "The fatigue is overwhelming, and my muscles ache like I've run a marathon.",
        "I can barely keep water down, and the fever and chills are relentless.",
        "The cycles of fever, chills, and sweating are exhausting me completely.",
        "My body aches all over and the high fever makes me delirious at times.",
    ],
    "myocarditis": [
        "My chest hurts constantly and my heart feels like it's racing out of control.",
        "I'm having difficulty breathing and my heart rhythm seems very irregular.",
        "The fatigue is extreme and my heart pounds even when I'm resting quietly.",
        "My ankle swelling and shortness of breath are getting worse by the day.",
        "I feel like my heart is skipping beats, and the chest discomfort is alarming.",
        "The flu-like symptoms have passed but my heart still races and aches.",
        "I'm struggling to breathe lying down, and my heart rhythm is very concerning.",
        "The chest pain and palpitations started after a viral infection and won't stop.",
    ],
    "myoclonus": [
        "The sudden jerking movements are unpredictable and happening more frequently now.",
        "I can't control these muscle spasms, and they're interfering with everything I do.",
        "The jerks happen even when I'm trying to sleep; I can't get proper rest.",
        "My limbs jerk suddenly without warning, and it's affecting my ability to work.",
        "The muscle twitches are getting stronger and more frequent as time goes on.",
        "I've dropped things multiple times because of these sudden involuntary movements.",
        "The spasms affect my whole body sometimes, and they're getting harder to manage.",
        "These uncontrollable jerks make daily tasks dangerous and unpredictable.",
    ],
    "open wound of the chest": [
        "The bleeding from my chest wound won't stop, and I'm having trouble breathing.",
        "I can feel air bubbling from the wound when I try to breathe; it's terrifying.",
        "The chest wound is deep and painful, and my breathing has become labored.",
        "Blood is still coming from the wound, and I feel weak and lightheaded.",
        "The pain from the chest wound is severe, and I'm struggling to take deep breaths.",
        "I'm worried about infection; the wound looks angry and the area is very painful.",
        "The chest wound is making it hard to move, and the bleeding concerns me.",
        "I can't catch my breath properly since the chest injury occurred.",
    ],
    "pneumoconiosis": [
        "Years of dust exposure have left me struggling to breathe during any activity.",
        "My chronic cough is getting worse, and I'm always short of breath now.",
        "The chest tightness never goes away, and I can hear myself wheezing constantly.",
        "I worked in mining for years, and now even walking up stairs leaves me gasping.",
        "The persistent cough and breathlessness are severely limiting what I can do.",
        "My lungs feel heavy, and I'm producing more mucus than ever before.",
        "The occupational exposure has caught up with me; my breathing is seriously compromised.",
        "I can't complete basic tasks without stopping to catch my breath multiple times.",
    ],
    "poisoning due to antipsychotics": [
        "I've taken too much medication and my muscles are becoming extremely rigid.",
        "I can't control my movements properly, and my temperature is rising dangerously.",
        "The muscle stiffness is severe, and I feel extremely confused and agitated.",
        "My heart is racing and my body temperature is very high after taking extra pills.",
        "I'm experiencing severe drowsiness and confusion after a medication error.",
        "The involuntary muscle movements are frightening, and I feel very unwell.",
        "I feel extremely sedated and my blood pressure seems very low.",
        "The rigidity in my body and altered mental state have me very worried.",
    ],
    "poisoning due to ethylene glycol": [
        "I accidentally ingested antifreeze and now I'm feeling very drunk and nauseated.",
        "The confusion and dizziness came on suddenly after the accidental exposure.",
        "I'm experiencing severe nausea and my vision seems blurry since the ingestion.",
        "The abdominal pain is intense, and I feel very disoriented and confused.",
        "I think I swallowed antifreeze by mistake, and now I'm feeling very sick.",
        "The headache is severe and I feel extremely drowsy after the accidental ingestion.",
        "I'm having difficulty concentrating and my coordination is very poor.",
        "My breathing has become labored since ingesting the substance accidentally.",
    ],
    "pulmonic valve disease": [
        "I get extremely tired with any physical activity, and my heart races abnormally.",
        "The swelling in my legs and feet has gotten much worse recently.",
        "I'm short of breath even at rest now, and I can feel my heart struggling.",
        "The fatigue and exercise intolerance are significantly impacting my quality of life.",
        "My ankles swell throughout the day, and I'm constantly exhausted.",
        "The palpitations and breathlessness are getting progressively worse.",
        "I can feel my heart beating irregularly, and the fatigue is overwhelming.",
        "The chest discomfort and difficulty breathing during activity are very concerning.",
    ],
    "syringomyelia": [
        "I've lost sensation in my hands and can't feel temperature properly anymore.",
        "The chronic pain in my neck and shoulders is debilitating and constant.",
        "My arm muscles are getting weaker, and I'm dropping things frequently.",
        "The numbness is spreading, and I'm having difficulty with fine motor tasks.",
        "I've burned myself multiple times because I can't feel heat in my hands.",
        "The stiffness in my legs is making walking increasingly difficult.",
        "My coordination has deteriorated, and the chronic pain is exhausting.",
        "The muscle weakness is progressing, and I'm struggling with daily activities.",
    ],
    "tuberculosis": [
        "I've had a persistent cough for weeks, and now I'm coughing up blood.",
        "The night sweats soak my sheets, and I've lost significant weight recently.",
        "The fever won't break, and my cough is producing blood-streaked sputum.",
        "I'm extremely fatigued and have no appetite; the cough is getting worse.",
        "The chest pain when I cough is severe, and I feel very weak.",
        "I've been exposed to TB and now I'm showing worrying symptoms.",
        "The persistent low-grade fever and weight loss are very concerning.",
        "My cough has lasted months, and the fatigue is making it hard to function.",
    ],
    "tuberous sclerosis": [
        "I'm having seizures that are becoming more frequent and harder to control.",
        "The skin lesions are spreading, and I'm having cognitive difficulties.",
        "My child is having developmental issues and frequent seizure episodes.",
        "The seizures are affecting my daily life, and medications aren't helping enough.",
        "I'm noticing new symptoms appearing, and the existing ones are getting worse.",
        "The behavioral changes and seizures are making management very difficult.",
        "Multiple organs seem to be affected, and new problems keep arising.",
        "The seizure frequency has increased, and I'm very concerned about progression.",
    ],
    "valley fever": [
        "The cough and fever started weeks ago and just won't go away.",
        "I'm having severe fatigue and joint pain after traveling to the Southwest.",
        "The chest pain and persistent cough are affecting my ability to work.",
        "I've developed a rash and the respiratory symptoms keep getting worse.",
        "The night sweats and weight loss are new and very worrying.",
        "My cough produces sputum, and I feel like I'm getting sicker, not better.",
        "The headaches and muscle aches are severe, and the fever persists.",
        "I've been sick for weeks after exposure to desert dust; something is really wrong.",
    ],
    "vertebrobasilar insufficiency": [
        "I'm having episodes of severe dizziness and double vision that terrify me.",
        "My balance is completely off, and I feel like I might fall at any moment.",
        "The vertigo attacks come suddenly with nausea and difficulty speaking.",
        "I'm experiencing numbness and weakness on one side during these episodes.",
        "The dizziness makes it unsafe for me to drive or even walk alone.",
        "My vision goes blurry and I feel faint when I turn my head certain ways.",
        "The slurred speech and coordination problems come and go unpredictably.",
        "I'm having trouble swallowing and my balance is severely compromised.",
    ],
    "zenker diverticulum": [
        "Food gets stuck in my throat, and I keep regurgitating undigested food.",
        "The difficulty swallowing is getting worse, and my breath smells terrible.",
        "I'm aspirating food into my lungs, and it's causing coughing fits.",
        "The neck swelling is noticeable, and I feel like food is always stuck.",
        "I can feel a lump in my throat, and eating has become a dreaded experience.",
        "I've lost weight because swallowing is so painful and food gets trapped.",
        "The gurgling sounds in my throat are embarrassing, and I choke frequently.",
        "Regurgitation of food hours after eating is happening more and more often.",
    ],
}

# Generate augmented data
def generate_augmented_data(target_total=1600):
    """Generate High-risk symptom data to balance the dataset."""
    new_samples = []
    samples_per_disease = target_total // len(HIGH_RISK_DISEASES)
    
    for disease in HIGH_RISK_DISEASES:
        templates = SYMPTOM_TEMPLATES.get(disease, [])
        
        if not templates:
            # For diseases without templates, create variations
            templates = [
                f"I'm experiencing serious symptoms related to {disease}, and I'm very concerned.",
                f"The symptoms from my {disease} are getting worse and need urgent attention.",
                f"My {disease} is causing significant distress and affecting my daily life.",
                f"I've been suffering with {disease} symptoms that won't improve.",
                f"The {disease} has me worried; the symptoms are quite severe.",
                f"I need help managing my {disease}; the symptoms are overwhelming.",
                f"My condition with {disease} is deteriorating and I'm scared.",
                f"The symptoms from {disease} are much worse than before.",
            ]
        
        # Add each template
        for template in templates:
            new_samples.append({
                'disease': disease,
                'text': template,
                'risk_level': 'High'
            })
        
        # If we need more, create variations
        while len([s for s in new_samples if s['disease'] == disease]) < samples_per_disease:
            base = random.choice(templates)
            # Simple variations
            variations = [
                base.replace("I'm", "I am").replace("I've", "I have"),
                base.replace("can't", "cannot").replace("won't", "will not"),
                base + " I really need help.",
                "Lately, " + base[0].lower() + base[1:] if base[0].isupper() else base,
                base.replace(";", ",").replace(".", "; it's really concerning."),
            ]
            variant = random.choice(variations)
            if variant != base:
                new_samples.append({
                    'disease': disease,
                    'text': variant,
                    'risk_level': 'High'
                })
    
    return new_samples

# Main execution
if __name__ == "__main__":
    print("Generating High-risk symptom data for dataset balancing...")
    
    # Generate new samples (need ~1600 to get from 490 to ~2000)
    new_samples = generate_augmented_data(target_total=1600)
    
    print(f"Generated {len(new_samples)} new High-risk samples")
    
    # Append to CSV
    csv_file = 'generated_symptom_texts_clean.csv'
    
    with open(csv_file, 'a', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['disease', 'text', 'risk_level'])
        for sample in new_samples:
            writer.writerow(sample)
    
    print(f"Appended {len(new_samples)} samples to {csv_file}")
    
    # Count final distribution
    import pandas as pd
    df = pd.read_csv(csv_file)
    print("\nFinal Risk Distribution:")
    for risk, count in df['risk_level'].value_counts().sort_index().items():
        pct = count / len(df) * 100
        print(f"   {risk:12}: {count:5,} ({pct:5.1f}%)")
    
    print(f"\nTotal samples: {len(df):,}")
