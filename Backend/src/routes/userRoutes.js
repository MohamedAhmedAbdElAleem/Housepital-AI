const express = require('express');
const router = express.Router();
const { register, login, getCurrentUser } = require('../controllers/authController');
const { updateUserValidator } = require('../middleware/validation');
const { updateInfo , getUserinfo, updateProfile} = require('../controllers/userController');
const { authenticateToken } = require('../middleware/authMiddleware');


router.patch('/updateInfo',updateUserValidator,updateInfo);
router.get('/getUserInfo',getUserinfo);
router.put('/update-profile', authenticateToken, updateProfile);

module.exports = router;
