const express = require('express');
const router = express.Router();
const {
    updateMedicalInfo,
    getMedicalInfo,
    uploadIdDocument,
    getVerificationStatus,
    completeProfileSetup
} = require('../controllers/profileController');
const { authenticateToken } = require('../middleware/authMiddleware');
const { body } = require('express-validator');
const { handleValidationErrors } = require('../middleware/validation');

// Validation for medical info
const validateMedicalInfo = [
    body('bloodType')
        .optional()
        .isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', null])
        .withMessage('Invalid blood type'),
    
    body('chronicDiseases')
        .optional()
        .isArray()
        .withMessage('Chronic diseases must be an array'),
    
    body('allergies')
        .optional()
        .isArray()
        .withMessage('Allergies must be an array'),
    
    body('otherConditions')
        .optional()
        .isString()
        .withMessage('Other conditions must be a string'),
    
    body('currentMedications')
        .optional()
        .isString()
        .withMessage('Current medications must be a string'),
    
    body('hasNoChronicDiseases')
        .optional()
        .isBoolean()
        .withMessage('hasNoChronicDiseases must be a boolean'),
    
    body('hasNoAllergies')
        .optional()
        .isBoolean()
        .withMessage('hasNoAllergies must be a boolean'),
    
    handleValidationErrors
];

// Validation for ID upload - accepts either imageUrl (Cloudinary) or imageBase64
const validateIdUpload = [
    body('side')
        .notEmpty()
        .isIn(['front', 'back'])
        .withMessage('Side must be "front" or "back"'),
    
    // Custom validation: require either imageUrl OR imageBase64
    body().custom((value, { req }) => {
        if (!req.body.imageUrl && !req.body.imageBase64) {
            throw new Error('Image data is required (imageUrl or imageBase64)');
        }
        return true;
    }),
    
    body('imageUrl')
        .optional()
        .isURL()
        .withMessage('imageUrl must be a valid URL'),
    
    body('publicId')
        .optional()
        .isString()
        .withMessage('publicId must be a string'),
    
    handleValidationErrors
];

/**
 * @route   PUT /api/profile/medical-info
 * @desc    Update user's medical information
 * @access  Private
 */
router.put('/medical-info', authenticateToken, validateMedicalInfo, updateMedicalInfo);

/**
 * @route   GET /api/profile/medical-info
 * @desc    Get user's medical information
 * @access  Private
 */
router.get('/medical-info', authenticateToken, getMedicalInfo);

/**
 * @route   POST /api/profile/upload-id
 * @desc    Upload ID document (front or back)
 * @access  Private
 */
router.post('/upload-id', authenticateToken, validateIdUpload, uploadIdDocument);

/**
 * @route   GET /api/profile/verification-status
 * @desc    Get user's verification status
 * @access  Private
 */
router.get('/verification-status', authenticateToken, getVerificationStatus);

/**
 * @route   POST /api/profile/complete-setup
 * @desc    Complete profile setup (medical info + ID verification)
 * @access  Private
 */
router.post('/complete-setup', authenticateToken, completeProfileSetup);

module.exports = router;
