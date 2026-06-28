#!/bin/bash

# Install dependencies
pip install -r requirements.txt

# Run the application
uvicorn src.api:app --host 0.0.0.0 --port $PORT
