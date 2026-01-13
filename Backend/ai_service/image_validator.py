"""
Image Validator for Wound Classification
=========================================
Validates images before they are sent to the AI model.

Checks:
1. File format (JPEG, PNG, WEBP)
2. Image dimensions (min/max)
3. Image quality (blur detection, brightness)
4. Basic sanity checks
"""

import io
from dataclasses import dataclass
from enum import Enum
from typing import Tuple, Optional

import numpy as np
from PIL import Image


class ValidationError(Enum):
    """Validation error types with Arabic messages."""
    INVALID_FORMAT = "صيغة الملف غير مدعومة. يرجى استخدام JPG أو PNG"
    TOO_SMALL = "الصورة صغيرة جداً. الحد الأدنى 100x100 بكسل"
    TOO_LARGE = "الصورة كبيرة جداً. الحد الأقصى 4096x4096 بكسل"
    TOO_BLURRY = "الصورة ضبابية جداً. يرجى التقاط صورة أوضح"
    TOO_DARK = "الصورة مظلمة جداً. يرجى تحسين الإضاءة"
    TOO_BRIGHT = "الصورة ساطعة جداً. يرجى تقليل الإضاءة"
    CORRUPTED = "الملف تالف أو لا يمكن قراءته"


@dataclass
class ValidationResult:
    """Result of image validation."""
    is_valid: bool
    error: Optional[ValidationError] = None
    error_message_ar: Optional[str] = None
    error_message_en: Optional[str] = None
    image: Optional[Image.Image] = None
    
    @classmethod
    def success(cls, image: Image.Image) -> "ValidationResult":
        return cls(is_valid=True, image=image)
    
    @classmethod
    def failure(cls, error: ValidationError) -> "ValidationResult":
        return cls(
            is_valid=False, 
            error=error,
            error_message_ar=error.value,
            error_message_en=error.name.replace("_", " ").title()
        )


class ImageValidator:
    """
    Validates images for wound classification.
    
    Usage:
        validator = ImageValidator()
        result = validator.validate(file_bytes)
        if result.is_valid:
            # Process result.image
        else:
            # Handle result.error_message_ar
    """
    
    # Configuration
    ALLOWED_FORMATS = {"JPEG", "PNG", "WEBP", "MPO"}  # MPO is a variant of JPEG
    MIN_DIMENSION = 100  # pixels
    MAX_DIMENSION = 4096  # pixels
    BLUR_THRESHOLD = 100  # Laplacian variance threshold
    MIN_BRIGHTNESS = 30  # 0-255
    MAX_BRIGHTNESS = 225  # 0-255
    
    def validate(self, file_bytes: bytes) -> ValidationResult:
        """
        Validate an image from bytes.
        
        Args:
            file_bytes: Raw image bytes
            
        Returns:
            ValidationResult with success/failure info
        """
        # Step 1: Try to open the image
        try:
            image = Image.open(io.BytesIO(file_bytes))
            image.load()  # Force load to catch corrupted images
        except Exception:
            return ValidationResult.failure(ValidationError.CORRUPTED)
        
        # Step 2: Check format
        if image.format not in self.ALLOWED_FORMATS:
            return ValidationResult.failure(ValidationError.INVALID_FORMAT)
        
        # Step 3: Check dimensions
        width, height = image.size
        if width < self.MIN_DIMENSION or height < self.MIN_DIMENSION:
            return ValidationResult.failure(ValidationError.TOO_SMALL)
        if width > self.MAX_DIMENSION or height > self.MAX_DIMENSION:
            return ValidationResult.failure(ValidationError.TOO_LARGE)
        
        # Step 4: Convert to RGB for further checks
        if image.mode != "RGB":
            image = image.convert("RGB")
        
        # Step 5: Check brightness
        brightness_result = self._check_brightness(image)
        if brightness_result is not None:
            return brightness_result
        
        # Step 6: Check blur (optional - can be slow)
        blur_result = self._check_blur(image)
        if blur_result is not None:
            return blur_result
        
        # All checks passed!
        return ValidationResult.success(image)
    
    def _check_brightness(self, image: Image.Image) -> Optional[ValidationResult]:
        """Check if image is too dark or too bright."""
        # Convert to grayscale and calculate mean brightness
        grayscale = image.convert("L")
        np_image = np.array(grayscale)
        mean_brightness = np.mean(np_image)
        
        if mean_brightness < self.MIN_BRIGHTNESS:
            return ValidationResult.failure(ValidationError.TOO_DARK)
        if mean_brightness > self.MAX_BRIGHTNESS:
            return ValidationResult.failure(ValidationError.TOO_BRIGHT)
        
        return None
    
    def _check_blur(self, image: Image.Image) -> Optional[ValidationResult]:
        """
        Check if image is too blurry using Laplacian variance.
        Lower variance = more blur.
        """
        # Resize for faster processing
        small = image.copy()
        small.thumbnail((500, 500))
        
        # Convert to grayscale numpy array
        grayscale = small.convert("L")
        np_image = np.array(grayscale, dtype=np.float64)
        
        # Calculate Laplacian (simple edge detection)
        # Using a simple kernel: [[0,1,0],[1,-4,1],[0,1,0]]
        laplacian_var = self._laplacian_variance(np_image)
        
        if laplacian_var < self.BLUR_THRESHOLD:
            return ValidationResult.failure(ValidationError.TOO_BLURRY)
        
        return None
    
    def _laplacian_variance(self, image: np.ndarray) -> float:
        """Calculate Laplacian variance for blur detection."""
        # Simple Laplacian using numpy (no OpenCV needed)
        # Kernel: [[0,1,0],[1,-4,1],[0,1,0]]
        
        h, w = image.shape
        if h < 3 or w < 3:
            return float('inf')  # Too small to check
        
        # Pad image for convolution
        padded = np.pad(image, 1, mode='edge')
        
        # Apply Laplacian kernel
        laplacian = (
            padded[0:-2, 1:-1] +  # top
            padded[2:, 1:-1] +    # bottom
            padded[1:-1, 0:-2] +  # left
            padded[1:-1, 2:] -    # right
            4 * padded[1:-1, 1:-1]  # center
        )
        
        return float(np.var(laplacian))


# Quick test function
def validate_image_bytes(file_bytes: bytes) -> Tuple[bool, Optional[str], Optional[str]]:
    """
    Simple wrapper for validation.
    
    Returns:
        Tuple of (is_valid, error_message_ar, error_message_en)
    """
    validator = ImageValidator()
    result = validator.validate(file_bytes)
    return result.is_valid, result.error_message_ar, result.error_message_en
