
const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/authMiddleware');
const {
    createProfile,
    getProfile,
    updateProfile,
    toggleActive,
    getPendingDoctors,
    verifyDoctor
} = require('../controllers/doctorController');

// All routes require authentication
router.use(authenticateToken);

// Doctor profile routes
router.post('/profile', createProfile);
router.get('/profile', getProfile);
router.put('/profile', updateProfile);

// Active toggle (wallet-gated)
router.put('/toggle-active', toggleActive);

// Admin routes
router.get('/pending', getPendingDoctors);
router.put('/:doctorId/verify', verifyDoctor);

module.exports = router;
