"""
OPTION B: LLM-BASED TRIAGE SYSTEM
=================================
Production-ready triage using Gemini/OpenAI API.
Handles natural language, slang, typos, and Arabic.

This is the ACTUAL working system for production.
"""

import os
import json
import re
from typing import Optional, Dict, List, Tuple

# =============================================================================
# CONFIGURATION
# =============================================================================

# Your services
SERVICES = {
    "wound_care": {
        "name": "Wound Care",
        "description": "Professional wound care and dressing services",
        "urgency_match": ["High", "Medium"],
        "keywords": ["wound", "cut", "laceration", "bleeding", "injury", "stitches", "dressing"]
    },
    "injections": {
        "name": "Injections", 
        "description": "Safe and painless injection services at your home",
        "urgency_match": ["Medium", "Low"],
        "keywords": ["injection", "vaccine", "shot", "medication", "insulin"]
    },
    "elderly_care": {
        "name": "Elderly Care",
        "description": "Comprehensive care for elderly patients including assistance with daily activities",
        "urgency_match": ["Medium", "Low", "High"],
        "keywords": ["elderly", "old", "grandmother", "grandfather", "senior", "aged"]
    },
    "post_op_care": {
        "name": "Post-Op Care",
        "description": "Post-operative care services to ensure smooth recovery after surgery",
        "urgency_match": ["High", "Medium"],
        "keywords": ["surgery", "operation", "post-op", "recovery", "surgical", "procedure"]
    },
    "baby_care": {
        "name": "Baby Care",
        "description": "Professional newborn and infant care services",
        "urgency_match": ["High", "Medium", "Low"],
        "keywords": ["baby", "infant", "newborn", "child", "toddler", "pediatric"]
    },
    "iv_therapy": {
        "name": "IV Therapy",
        "description": "Intravenous fluid and medication therapy administered safely at home",
        "urgency_match": ["High", "Medium"],
        "keywords": ["iv", "intravenous", "fluids", "dehydration", "drip", "infusion"]
    },
    "catheter_care": {
        "name": "Catheter Care",
        "description": "Professional catheter insertion, maintenance and care services",
        "urgency_match": ["High", "Medium"],
        "keywords": ["catheter", "urinary", "bladder", "urine", "drainage"]
    },
    "vital_signs": {
        "name": "Vital Signs",
        "description": "Complete vital signs monitoring with detailed reporting",
        "urgency_match": ["Medium", "Low"],
        "keywords": ["blood pressure", "pulse", "temperature", "vitals", "monitoring", "checkup"]
    },
    "blood_draw": {
        "name": "Blood Draw",
        "description": "Professional blood sample collection at your home",
        "urgency_match": ["Medium", "Low"],
        "keywords": ["blood test", "blood draw", "sample", "lab", "analysis"]
    },
    "physiotherapy": {
        "name": "Physiotherapy",
        "description": "Home physiotherapy sessions for rehabilitation and mobility",
        "urgency_match": ["Medium", "Low"],
        "keywords": ["physiotherapy", "physical therapy", "rehabilitation", "mobility", "exercise", "pain", "muscle"]
    }
}

# System prompt for triage
TRIAGE_SYSTEM_PROMPT = """You are a medical triage assistant for Housepital, a home healthcare service in Egypt. 
Your job is to analyze patient symptoms and classify their urgency level.

## Urgency Levels:
- **Emergency**: Life-threatening, requires immediate emergency response (ambulance, ER)
  Examples: Can't breathe, chest pain radiating to arm, unconscious, severe bleeding, seizures, stroke symptoms, poisoning
  
- **High**: Serious condition needing medical attention within hours
  Examples: High fever (39°C+), deep cuts needing stitches, difficulty breathing, blood in urine/stool, fractures
  
- **Medium**: Should see a healthcare provider within 1-2 days
  Examples: Persistent cough, mild fever, stomach pain, back pain, headaches, minor infections
  
- **Low**: Can be managed at home with self-care, monitor symptoms
  Examples: Common cold, minor cuts, mild tiredness, runny nose, seasonal allergies

## Available Home Services:
{services_list}

## Your Response:
You MUST respond in this exact JSON format:
{{
    "urgency": "Emergency|High|Medium|Low",
    "confidence": 0.0-1.0,
    "reasoning": "Brief explanation of why this urgency level",
    "key_symptoms": ["symptom1", "symptom2"],
    "recommended_services": ["Service Name 1", "Service Name 2"],
    "immediate_advice": "What the patient should do right now",
    "follow_up": "Any additional recommendations"
}}

## Important Rules:
1. When in doubt between two levels, ALWAYS choose the MORE urgent one
2. Emergency cases should NEVER recommend home services - tell them to call emergency
3. Consider age (babies, elderly) as risk factors
4. Consider duration and severity of symptoms
5. If symptoms are vague, ask clarifying questions instead of classifying
6. You can respond in Arabic if the patient writes in Arabic

## Current conversation:
"""

# =============================================================================
# LLM CLIENT
# =============================================================================

class TriageLLM:
    def __init__(self, api_key: str = None, provider: str = "gemini"):
        """
        Initialize the LLM-based triage system.
        
        Args:
            api_key: API key for the LLM provider
            provider: "gemini" or "openai"
        """
        self.provider = provider
        self.api_key = api_key or os.environ.get("OPENAI_API_KEY") or os.environ.get("GEMINI_API_KEY")
        self.conversation_history = []
        self.current_symptoms = []
        
        if not self.api_key:
            pass # Use fallback mode quietly
        
        # Build services list for prompt
        services_list = "\n".join([
            f"- {s['name']}: {s['description']}" 
            for s in SERVICES.values()
        ])
        self.system_prompt = TRIAGE_SYSTEM_PROMPT.format(services_list=services_list)
        
        # Initialize client
        self._init_client()
    
    def _init_client(self):
        """Initialize the LLM client based on provider."""
        if self.provider == "gemini":
            try:
                import google.generativeai as genai
                genai.configure(api_key=self.api_key)
                self.model = genai.GenerativeModel('gemini-1.5-flash-8b')
                self.client_available = True
                print("Gemini client initialized successfully!")
            except ImportError:
                print("Install google-generativeai: pip install google-generativeai")
                self.client_available = False
            except Exception as e:
                print(f"Gemini init error: {e}")
                self.client_available = False
                
        elif self.provider == "openai":
            try:
                from openai import OpenAI
                self.client = OpenAI(api_key=self.api_key)
                self.client_available = True
                print("OpenAI client initialized successfully!")
            except ImportError:
                print("Install openai: pip install openai")
                self.client_available = False
            except Exception as e:
                print(f"OpenAI init error: {e}")
                self.client_available = False
    
    def classify(self, user_message: str) -> Dict:
        """
        Classify the user's symptoms and return triage result.
        
        Args:
            user_message: The patient's symptom description
            
        Returns:
            Dictionary with urgency, confidence, reasoning, services, etc.
        """
        if not self.client_available:
            print("[USING FALLBACK - No API client]")
            return self._fallback_classify(user_message)
        
        # Add to conversation history
        self.conversation_history.append({"role": "user", "content": user_message})
        
        # Build full prompt
        full_prompt = self.system_prompt + "\n\nPatient says: " + user_message
        
        try:
            if self.provider == "gemini":
                response = self.model.generate_content(full_prompt)
                response_text = response.text
            else:  # openai
                response = self.client.chat.completions.create(
                    model="gpt-4o-mini",  # Cheap and fast
                    messages=[
                        {"role": "system", "content": self.system_prompt},
                        {"role": "user", "content": user_message}
                    ]
                )
                response_text = response.choices[0].message.content
            
            # Parse JSON response
            result = self._parse_response(response_text)
            result['source'] = 'LLM'  # Mark as LLM response
            print("[USING LLM - API responded successfully]")
            
            # Add to history
            self.conversation_history.append({"role": "assistant", "content": json.dumps(result)})
            
            return result
            
        except Exception as e:
            print(f"LLM Error: {e}")
            print("[USING FALLBACK - API failed]")
            return self._fallback_classify(user_message)
    
    def _parse_response(self, response_text: str) -> Dict:
        """Parse the LLM response into structured format."""
        # Try to extract JSON from response
        try:
            # Find JSON in response
            json_match = re.search(r'\{[\s\S]*\}', response_text)
            if json_match:
                return json.loads(json_match.group())
        except json.JSONDecodeError:
            pass
        
        # If parsing fails, return a default structure
        return {
            "urgency": "Medium",
            "confidence": 0.5,
            "reasoning": response_text[:200],
            "key_symptoms": [],
            "recommended_services": [],
            "immediate_advice": "Please consult with a healthcare provider.",
            "follow_up": "Monitor your symptoms.",
            "raw_response": response_text
        }
    
    def _fallback_classify(self, text: str) -> Dict:
        """
        Fallback classification using keyword rules when LLM is unavailable.
        """
        text_lower = text.lower()
        
        # Emergency keywords
        emergency_keywords = [
            "can't breathe", "cannot breathe", "not breathing", "chest pain", 
            "heart attack", "unconscious", "collapsed", "seizure", "stroke",
            "severe bleeding", "poisoning", "overdose", "suicidal"
        ]
        
        # High keywords
        high_keywords = [
            "high fever", "39", "40", "deep cut", "broken", "fracture",
            "blood in", "difficulty breathing", "severe pain"
        ]
        
        # Low keywords
        low_keywords = [
            "cold", "runny nose", "tired", "minor", "small cut", "sneez"
        ]
        
        # Check keywords
        for kw in emergency_keywords:
            if kw in text_lower:
                return {
                    "urgency": "Emergency",
                    "confidence": 0.9,
                    "reasoning": f"Detected emergency keyword: {kw}",
                    "key_symptoms": [kw],
                    "recommended_services": [],
                    "immediate_advice": "Call emergency services immediately! Dial your local emergency number.",
                    "follow_up": "Do not wait - this requires immediate medical attention."
                }
        
        for kw in high_keywords:
            if kw in text_lower:
                return {
                    "urgency": "High",
                    "confidence": 0.8,
                    "reasoning": f"Detected high-urgency keyword: {kw}",
                    "key_symptoms": [kw],
                    "recommended_services": ["IV Therapy", "Wound Care"],
                    "immediate_advice": "Seek medical attention within the next few hours.",
                    "follow_up": "Consider our home healthcare services."
                }
        
        for kw in low_keywords:
            if kw in text_lower:
                return {
                    "urgency": "Low",
                    "confidence": 0.7,
                    "reasoning": f"Detected low-urgency keyword: {kw}",
                    "key_symptoms": [kw],
                    "recommended_services": ["Vital Signs", "Blood Draw"],
                    "immediate_advice": "Rest and monitor symptoms at home.",
                    "follow_up": "Consult a doctor if symptoms persist or worsen."
                }
        
        # Default to Medium
        return {
            "urgency": "Medium",
            "confidence": 0.6,
            "reasoning": "No specific urgency indicators detected",
            "key_symptoms": [],
            "recommended_services": ["Vital Signs"],
            "immediate_advice": "Monitor your symptoms and rest.",
            "follow_up": "Consider scheduling a consultation."
        }
    
    def reset_conversation(self):
        """Reset conversation history."""
        self.conversation_history = []
        self.current_symptoms = []


# =============================================================================
# CHATBOT INTERFACE
# =============================================================================

class TriageChatbot:
    """
    Full chatbot interface that handles conversation flow,
    casual messages, and triage classification.
    """
    
    def __init__(self, api_key: str = None, provider: str = "gemini"):
        self.triage = TriageLLM(api_key=api_key, provider=provider)
        self.state = "greeting"  # greeting, collecting_symptoms, classified
        self.last_classification = None
    
    def chat(self, user_message: str) -> Dict:
        """
        Process a user message and return appropriate response.
        
        Returns:
            {
                "response": "Bot's text response",
                "urgency": None | "Emergency" | "High" | "Medium" | "Low",
                "show_sos": True/False,
                "services": [],
                "full_classification": {...}
            }
        """
        message_lower = user_message.lower().strip()
        
        # Check for casual greetings
        greetings = [
            "hello", "hi", "hey", "hii", "hiii", "yo", "sup", "what's up", "whats up", 
            "good morning", "good evening", "good afternoon", "good night",
            "marhaba", "ahlan", "salam", "salaam", "assalam", "hola", "bonjour",
            "how are you", "how r u", "how you doing", "what up", "wazzup", "wassup"
        ]
        if any(g in message_lower for g in greetings) or len(message_lower) < 5:
            return {
                "response": "Hello! I'm the Housepital health assistant. How can I help you today? Please describe any symptoms or health concerns you have.",
                "urgency": None,
                "show_sos": False,
                "services": [],
                "full_classification": None
            }
        
        # Check for casual/non-medical messages
        casual_patterns = [
            "thank", "thanks", "bye", "goodbye", "ok", "okay", "got it", "i see",
            "cool", "nice", "great", "awesome", "alright", "sure", "yes", "no",
            "what can you do", "who are you", "what are you", "help me", "test",
            "lol", "haha", "hehe", "lmao", "bruh", "bro", "dude", "man",
            "my friend", "friend", "buddy", "mate"
        ]
        
        # Positive feelings - not medical
        positive_feelings = [
            "happy", "good", "fine", "great", "awesome", "wonderful", "amazing",
            "better", "well", "excited", "glad", "pleased", "content", "joyful"
        ]
        
        # Check if message expresses positive feelings
        if any(f"feel {p}" in message_lower or f"feeling {p}" in message_lower or f"i am {p}" in message_lower or f"i'm {p}" in message_lower for p in positive_feelings):
            return {
                "response": "That's great to hear! I'm here if you ever need help with any health concerns. Is there anything else I can assist you with?",
                "urgency": None,
                "show_sos": False,
                "services": [],
                "full_classification": None
            }
        
        # Check if message is purely casual (no medical words)
        medical_indicators = [
            "pain", "hurt", "ache", "sick", "ill", "fever", "blood", "vomit", 
            "cough", "breath", "chest", "head", "stomach", "tired", "weak",
            "dizzy", "nausea", "symptom", "doctor", "hospital", "emergency",
            "baby", "child", "wound", "cut", "burn", "injection", "medicine"
        ]
        
        has_medical = any(m in message_lower for m in medical_indicators)
        is_casual = any(p in message_lower for p in casual_patterns)
        
        # If it's casual and has no medical indicators
        if is_casual and not has_medical and len(message_lower) < 50:
            return {
                "response": "I'm here to help with health concerns! Do you have any symptoms or health issues you'd like to discuss?",
                "urgency": None,
                "show_sos": False,
                "services": [],
                "full_classification": None
            }
        
        # Check for gibberish or very short non-medical messages
        if len(message_lower) < 10 and not has_medical:
            return {
                "response": "I didn't quite understand that. Could you please describe your symptoms or health concerns in more detail?",
                "urgency": None,
                "show_sos": False,
                "services": [],
                "full_classification": None
            }
        
        # This looks like a symptom description - classify it
        classification = self.triage.classify(user_message)
        self.last_classification = classification
        
        urgency = classification.get("urgency", "Medium")
        
        # Build response based on urgency
        if urgency == "Emergency":
            response = (
                "*** EMERGENCY DETECTED ***\n\n"
                f"{classification.get('reasoning', '')}\n\n"
                "**CALL EMERGENCY SERVICES IMMEDIATELY!**\n"
                f"{classification.get('immediate_advice', 'Call your local emergency number now.')}"
            )
            show_sos = True
            services = []
            
        elif urgency == "High":
            services = classification.get("recommended_services", [])
            response = (
                f"[!] **High Priority**\n\n"
                f"{classification.get('reasoning', '')}\n\n"
                f"**Recommended Action:** {classification.get('immediate_advice', 'Seek medical attention soon.')}\n\n"
            )
            if services:
                response += f"**Our services that can help:** {', '.join(services)}"
            show_sos = False
            
        elif urgency == "Medium":
            services = classification.get("recommended_services", [])
            response = (
                f"[i] **Moderate Concern**\n\n"
                f"{classification.get('reasoning', '')}\n\n"
                f"**Advice:** {classification.get('immediate_advice', 'Monitor symptoms.')}\n\n"
            )
            if services:
                response += f"**Suggested services:** {', '.join(services)}"
            show_sos = False
            
        else:  # Low
            services = classification.get("recommended_services", [])
            response = (
                f"[OK] **Low Urgency**\n\n"
                f"{classification.get('reasoning', '')}\n\n"
                f"**Advice:** {classification.get('immediate_advice', 'Rest and self-care at home.')}\n\n"
                f"**Follow-up:** {classification.get('follow_up', 'Consult a doctor if symptoms persist.')}"
            )
            if services:
                response += f"\n\n**Optional services:** {', '.join(services)}"
            show_sos = False
        
        return {
            "response": response,
            "urgency": urgency,
            "show_sos": show_sos,
            "services": services,
            "full_classification": classification
        }


# =============================================================================
# INTERACTIVE TEST
# =============================================================================

def run_interactive():
    """Run interactive chatbot test."""
    print("=" * 70)
    print("HOUSEPITAL - LLM TRIAGE CHATBOT")
    print("=" * 70)
    
    # Check for API key
    api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("OPENAI_API_KEY")
    
    if not api_key:
        print("\nNo API key found!")
        print("Set your API key:")
        print("  Windows: set GEMINI_API_KEY=your-key-here")
        print("  Linux/Mac: export GEMINI_API_KEY=your-key-here")
        print("\nOr enter it now:")
        api_key = input("API Key (or press Enter to use fallback mode): ").strip()
    
    provider = "openai"  # Using OpenAI gpt-4o-mini (cheap and fast)
    
    chatbot = TriageChatbot(api_key=api_key or None, provider=provider)
    
    print("\nChatbot ready! Type your symptoms or 'quit' to exit.\n")
    print("-" * 70)
    
    while True:
        user_input = input("\nYou: ").strip()
        
        if not user_input:
            continue
        
        if user_input.lower() in ['quit', 'exit', 'q']:
            print("\nGoodbye! Stay healthy!")
            break
        
        result = chatbot.chat(user_input)
        
        print("\n" + "-" * 40)
        print(f"Bot: {result['response']}")
        print("-" * 40)
        
        if result['urgency']:
            print(f"\n[Urgency: {result['urgency']}]")
        
        if result['show_sos']:
            print("\n" + "!" * 50)
            print("!!! SOS BUTTON SHOULD BE DISPLAYED !!!")
            print("!" * 50)


if __name__ == "__main__":
    run_interactive()
