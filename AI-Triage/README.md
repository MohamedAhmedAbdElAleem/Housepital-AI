# AI-Triage Module

This folder contains the AI-powered medical triage system for Housepital.

## Files

### Main Scripts
- **option_a_transformer.py** - Transformer-based triage model with matplotlib visualizations (for reports/demo)
- **option_b_llm_triage.py** - LLM-based chatbot triage (production-ready with OpenAI/Gemini)
- **generate_egypt_dataset.py** - Dataset generation script for training

### Visualizations
The visualizations folder contains performance charts for reports.

## Usage

### Option B (LLM Chatbot - Recommended)
Set OPENAI_API_KEY environment variable, then run: python option_b_llm_triage.py

### Option A (Transformer - For Reports)
Run: python option_a_transformer.py to generate visualizations
