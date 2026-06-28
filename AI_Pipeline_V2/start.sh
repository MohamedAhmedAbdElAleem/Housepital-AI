#!/bin/bash

# Install dependencies
pip install -r requirements.txt
pip uninstall -y opencv-python
pip install opencv-python-headless

# Run the application
PYTHONPATH=src uvicorn src.api:app --host 0.0.0.0 --port $PORT
