"""
TRIAGE SERVICE - FastAPI wrapper for LLM Triage
================================================
This service exposes the LLM-based triage system via REST API.
"""

import os
import sys
from pathlib import Path

# Add the AI-Triage directory to path
ai_triage_path = Path(__file__).parent.parent.parent / "AI-Triage"
sys.path.insert(0, str(ai_triage_path))

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List, Dict
import uvicorn

# Import the triage system
from option_b_llm_triage import TriageChatbot, SERVICES

app = FastAPI(
    title="Housepital AI Triage API",
    description="LLM-powered medical triage chatbot for home healthcare services",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize chatbot (use environment variable for API key)
API_KEY = os.environ.get("GEMINI_API_KEY") or os.environ.get("OPENAI_API_KEY")
PROVIDER = "gemini" if os.environ.get("GEMINI_API_KEY") else "openai"

# Session storage for chatbots (in production, use Redis)
chatbot_sessions: Dict[str, TriageChatbot] = {}


class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = "default"


class ChatResponse(BaseModel):
    response: str
    urgency: Optional[str] = None
    show_sos: bool = False
    services: List[str] = []
    service_routes: List[dict] = []
    full_classification: Optional[dict] = None


class ServiceInfo(BaseModel):
    id: str
    name: str
    description: str
    keywords: List[str]


# Service mapping for navigation
SERVICE_ROUTES = {
    "Wound Care": {
        "route": "wound_care",
        "title": "Wound Care",
        "price": "150 EGP",
        "duration": "30-45 min",
        "icon": "healing",
        "color": "0xFFEF4444"
    },
    "Injections": {
        "route": "injections",
        "title": "Injections",
        "price": "50 EGP",
        "duration": "15-20 min",
        "icon": "medication_liquid",
        "color": "0xFF3B82F6"
    },
    "Elderly Care": {
        "route": "elderly_care",
        "title": "Elderly Care",
        "price": "200 EGP/hr",
        "duration": "1-4 hours",
        "icon": "elderly",
        "color": "0xFF8B5CF6"
    },
    "Post-Op Care": {
        "route": "post_op_care",
        "title": "Post-Op Care",
        "price": "300 EGP",
        "duration": "45-60 min",
        "icon": "monitor_heart",
        "color": "0xFF10B981"
    },
    "Baby Care": {
        "route": "baby_care",
        "title": "Baby Care",
        "price": "250 EGP",
        "duration": "1-2 hours",
        "icon": "child_care",
        "color": "0xFFEC4899"
    },
    "IV Therapy": {
        "route": "iv_therapy",
        "title": "IV Therapy",
        "price": "200 EGP",
        "duration": "30-60 min",
        "icon": "water_drop",
        "color": "0xFF06B6D4"
    },
    "Catheter Care": {
        "route": "catheter_care",
        "title": "Catheter Care",
        "price": "180 EGP",
        "duration": "20-30 min",
        "icon": "medical_services",
        "color": "0xFFF97316"
    },
    "Vital Signs": {
        "route": "vital_signs",
        "title": "Vital Signs",
        "price": "80 EGP",
        "duration": "15-20 min",
        "icon": "favorite",
        "color": "0xFFDC2626"
    },
    "Blood Draw": {
        "route": "blood_draw",
        "title": "Blood Draw",
        "price": "100 EGP",
        "duration": "10-15 min",
        "icon": "bloodtype",
        "color": "0xFFB91C1C"
    },
    "Physiotherapy": {
        "route": "physiotherapy",
        "title": "Physiotherapy",
        "price": "350 EGP",
        "duration": "45-60 min",
        "icon": "accessibility_new",
        "color": "0xFF059669"
    }
}


def get_or_create_chatbot(session_id: str) -> TriageChatbot:
    """Get or create a chatbot for the session."""
    if session_id not in chatbot_sessions:
        chatbot_sessions[session_id] = TriageChatbot(
            api_key=API_KEY,
            provider=PROVIDER
        )
    return chatbot_sessions[session_id]


@app.get("/")
async def root():
    return {"message": "Housepital AI Triage API", "status": "running"}


@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "api_key_configured": bool(API_KEY),
        "provider": PROVIDER
    }


@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Process a chat message and return triage response.
    """
    try:
        chatbot = get_or_create_chatbot(request.session_id)
        result = chatbot.chat(request.message)
        
        # Map recommended services to routes
        service_routes = []
        for service_name in result.get("services", []):
            if service_name in SERVICE_ROUTES:
                service_routes.append(SERVICE_ROUTES[service_name])
        
        return ChatResponse(
            response=result.get("response", ""),
            urgency=result.get("urgency"),
            show_sos=result.get("show_sos", False),
            services=result.get("services", []),
            service_routes=service_routes,
            full_classification=result.get("full_classification")
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/reset/{session_id}")
async def reset_session(session_id: str):
    """Reset a chat session."""
    if session_id in chatbot_sessions:
        del chatbot_sessions[session_id]
    return {"message": "Session reset", "session_id": session_id}


@app.get("/services", response_model=List[ServiceInfo])
async def get_services():
    """Get list of available services."""
    return [
        ServiceInfo(
            id=key,
            name=value["name"],
            description=value["description"],
            keywords=value["keywords"]
        )
        for key, value in SERVICES.items()
    ]


if __name__ == "__main__":
    print("Starting Housepital AI Triage Service...")
    print(f"API Key configured: {bool(API_KEY)}")
    print(f"Provider: {PROVIDER}")
    uvicorn.run(app, host="0.0.0.0", port=8000)
