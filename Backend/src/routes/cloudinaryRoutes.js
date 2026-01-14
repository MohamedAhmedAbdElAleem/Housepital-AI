/**
 * Cloudinary Routes - Image Management API
 * 
 * Base path: /api/cloudinary
 */

const express = require('express');
const router = express.Router();
const cloudinaryController = require('../controllers/cloudinaryController');
const { authenticateToken } = require('../middleware/authMiddleware');

// Public routes (no auth required)
router.get('/status', cloudinaryController.checkStatus);

// Protected routes (require authentication)
// Upload routes
router.post('/upload', authenticateToken, cloudinaryController.upload.single('file'), cloudinaryController.uploadFile);
router.post('/upload-base64', authenticateToken, cloudinaryController.uploadBase64);
router.post('/upload-url', authenticateToken, cloudinaryController.uploadFromUrl);

// Delete routes
router.delete('/delete', authenticateToken, cloudinaryController.deleteImage);
router.delete('/delete-multiple', authenticateToken, cloudinaryController.deleteMultipleImages);

// Transform/URL routes
router.get('/transform', cloudinaryController.getTransformedUrl);
router.get('/thumbnail', cloudinaryController.getThumbnailUrl);

// Replace route
router.put('/replace', authenticateToken, cloudinaryController.replaceImage);

module.exports = router;
