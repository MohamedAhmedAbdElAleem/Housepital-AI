const express = require('express');
const router = express.Router();
const { register, login, getCurrentUser } = require('../controllers/authController');
const { updateUserValidator } = require('../middleware/validation');
const { 
    updateInfo, 
    getUserinfo, 
    updateProfile,
    getSingleDependent,
    addDependent,
    getAllDependents
} = require('../controllers/userController');
const { authenticateToken } = require('../middleware/authMiddleware');


router.patch('/updateInfo',updateUserValidator,updateInfo);
router.get('/getUserInfo',getUserinfo);
router.put('/update-profile', authenticateToken, updateProfile);
router.get('/getSingleDependent',getSingleDependent);
router.post("/addDependent", addDependent);
router.get('/getAllDependents',getAllDependents);

module.exports = router;
