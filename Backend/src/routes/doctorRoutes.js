
const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/authMiddleware');
const {
    createProfile,
    getProfile,
    updateProfile,
    getAllDoctors,
    getDoctorDetails
} = require('../controllers/doctorController');

// 1. Specific Protected Routes (Must come before /:id)
router.post('/profile', authenticateToken, createProfile);
router.get('/profile', authenticateToken, getProfile);
router.put('/profile', authenticateToken, updateProfile);

// 2. Specific Public Routes
router.get("/", getAllDoctors);

// 3. Dynamic Public Routes (Must be last)
// This matches /:id, so it would catch 'profile' if placed above
router.get("/:id", getDoctorDetails);

module.exports = router;
