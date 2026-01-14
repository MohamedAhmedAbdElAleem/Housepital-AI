
const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/authMiddleware');
const {
    createProfile,
    getProfile,
    updateProfile
} = require('../controllers/doctorController');

// All routes require authentication
router.use(authenticateToken);

router.post('/profile', createProfile);
router.get('/profile', getProfile);
router.put('/profile', updateProfile);

module.exports = router;
