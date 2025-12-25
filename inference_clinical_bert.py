"""
Housepital AI Medical Triage - Inference Script
================================================
Use this script to make predictions with the trained Clinical BERT model.

Usage:
    python inference_clinical_bert.py "I have severe chest pain"
    
Or import and use in your application:
    from inference_clinical_bert import TriageClassifier
    classifier = TriageClassifier()
    result = classifier.predict("I have severe chest pain")
"""

import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import warnings
warnings.filterwarnings('ignore')


# Label mappings
ID2LABEL = {0: "Emergency", 1: "High", 2: "Medium", 3: "Low"}
LABEL2ID = {v: k for k, v in ID2LABEL.items()}

# Risk level details for app integration
RISK_DETAILS = {
    "Emergency": {
        "priority": 1,
        "color": "#FF0000",
        "action": "Seek immediate emergency care. Call 911 or go to nearest ER.",
        "response_time": "Immediate"
    },
    "High": {
        "priority": 2,
        "color": "#FF6600",
        "action": "Schedule urgent care within 2-4 hours.",
        "response_time": "2-4 hours"
    },
    "Medium": {
        "priority": 3,
        "color": "#FFCC00",
        "action": "Schedule appointment within 1-2 days.",
        "response_time": "1-2 days"
    },
    "Low": {
        "priority": 4,
        "color": "#00CC00",
        "action": "Routine care acceptable. Monitor symptoms.",
        "response_time": "As convenient"
    }
}

# Emergency keywords for safety post-processing
EMERGENCY_KEYWORDS = [
    "can't breathe", "cannot breathe", "difficulty breathing",
    "chest pain", "heart attack", "cardiac",
    "unconscious", "passed out", "fainted",
    "severe bleeding", "bleeding profusely", 
    "seizure", "convulsion",
    "stroke", "paralysis", "sudden weakness",
    "anaphylaxis", "severe allergic",
    "lips turning blue", "turning blue",
    "choking", "suffocating"
]

HIGH_KEYWORDS = [
    "high fever", "fever 103", "fever 104", "fever 105",
    "blood in stool", "vomiting blood",
    "severe pain", "excruciating pain",
    "confusion", "disoriented"
]


class TriageClassifier:
    """Medical Triage Classifier using Clinical BERT."""
    
    def __init__(self, model_path="./triage_model"):
        """
        Initialize the classifier.
        
        Args:
            model_path: Path to the saved model directory
        """
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        print(f"🏥 Loading Triage Model from {model_path}...")
        
        self.tokenizer = AutoTokenizer.from_pretrained(model_path)
        self.model = AutoModelForSequenceClassification.from_pretrained(model_path)
        self.model.to(self.device)
        self.model.eval()
        
        print(f"✅ Model loaded on {self.device}")
    
    def _apply_safety_rules(self, symptoms, prediction, confidence):
        """
        Apply safety rules to escalate obvious emergencies.
        Returns (final_prediction, was_escalated, escalation_reason)
        """
        symptoms_lower = symptoms.lower()
        
        # Check emergency keywords
        for keyword in EMERGENCY_KEYWORDS:
            if keyword in symptoms_lower:
                if prediction != "Emergency":
                    return "Emergency", True, f"Escalated due to: '{keyword}'"
        
        # Check high-risk keywords
        for keyword in HIGH_KEYWORDS:
            if keyword in symptoms_lower:
                if prediction in ["Low", "Medium"]:
                    return "High", True, f"Escalated due to: '{keyword}'"
        
        return prediction, False, None
    
    def predict(self, symptom_text, apply_safety=True):
        """
        Predict triage risk level for given symptoms.
        
        Args:
            symptom_text: Patient's symptom description
            apply_safety: Whether to apply safety rules (default True)
        
        Returns:
            dict with prediction details
        """
        # Tokenize
        inputs = self.tokenizer(
            symptom_text,
            truncation=True,
            padding=True,
            max_length=128,
            return_tensors='pt'
        ).to(self.device)
        
        # Predict
        with torch.no_grad():
            outputs = self.model(**inputs)
            probs = torch.softmax(outputs.logits, dim=1)
            pred_id = torch.argmax(probs, dim=1).item()
            confidence = probs[0][pred_id].item()
        
        prediction = ID2LABEL[pred_id]
        original_prediction = prediction
        escalated = False
        escalation_reason = None
        
        # Apply safety rules
        if apply_safety:
            prediction, escalated, escalation_reason = self._apply_safety_rules(
                symptom_text, prediction, confidence
            )
        
        # Get risk details
        details = RISK_DETAILS[prediction]
        
        return {
            "risk_level": prediction,
            "confidence": round(confidence, 4),
            "priority": details["priority"],
            "color": details["color"],
            "action": details["action"],
            "response_time": details["response_time"],
            "was_escalated": escalated,
            "escalation_reason": escalation_reason,
            "original_prediction": original_prediction if escalated else None,
            "all_probabilities": {
                ID2LABEL[i]: round(probs[0][i].item(), 4) 
                for i in range(4)
            }
        }
    
    def predict_batch(self, symptom_texts, apply_safety=True):
        """Predict for multiple symptoms."""
        return [self.predict(text, apply_safety) for text in symptom_texts]


def main():
    """Interactive testing."""
    import sys
    
    classifier = TriageClassifier()
    
    if len(sys.argv) > 1:
        # Command line mode
        symptom = " ".join(sys.argv[1:])
        result = classifier.predict(symptom)
        print_result(symptom, result)
    else:
        # Interactive mode
        print("\n" + "=" * 60)
        print("🏥 HOUSEPITAL AI TRIAGE SYSTEM")
        print("=" * 60)
        print("Enter symptoms (or 'quit' to exit):\n")
        
        while True:
            symptom = input("Symptoms: ").strip()
            if symptom.lower() in ['quit', 'exit', 'q']:
                break
            if not symptom:
                continue
            
            result = classifier.predict(symptom)
            print_result(symptom, result)
            print()


def print_result(symptom, result):
    """Pretty print the result."""
    print(f"\n📋 TRIAGE RESULT")
    print("─" * 40)
    print(f"Symptoms: {symptom[:60]}...")
    print(f"\n🎯 Risk Level: {result['risk_level']}")
    print(f"📊 Confidence: {result['confidence']:.1%}")
    print(f"⏰ Response Time: {result['response_time']}")
    print(f"📝 Action: {result['action']}")
    
    if result['was_escalated']:
        print(f"\n⚠️ ESCALATED: {result['escalation_reason']}")
        print(f"   Original: {result['original_prediction']}")
    
    print(f"\nAll Probabilities:")
    for level, prob in result['all_probabilities'].items():
        bar = "█" * int(prob * 20)
        print(f"   {level:12}: {prob:.1%} {bar}")


if __name__ == "__main__":
    main()
