# Housepital AI Pipeline V2

This directory contains the re-engineered "Clean Slate" AI system for wound triage, classification, and staging.

## Structure
-   **`data/`**: Dataset management.
    -   `raw/`: Original downloaded images.
    -   `processed/`: Cleaned, resized, and normalized tensors ready for training.
    -   `loaders/`: Scripts and CSVs defining train/val splits.
-   **`models/`**: Code for specific model stages.
    -   `stage1_binary/`: "Wound vs Normal" Triage model.
    -   `stage2_type/`: 7-Class Wound Type Classifier.
    -   `stage3_severity/`: Burn Staging and Severity models.
-   **`src/`**: Shared utilities (augmentation, training loops, metrics).
-   **`notebooks/`**: Experiments and visualization.

## Usage
(To be updated as scripts are developed)
