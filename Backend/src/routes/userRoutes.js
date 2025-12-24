/**
 * User routes - Combined version
 */

const express = require('express');
const router = express.Router();

// Import controllers
const {
    registerUser,
    loginUser,
    getAllUsers,
    getUserById,
    updateInfo,
    getUserinfo,
    getSingleDependent,
    addDependent,
    getAllDependents,
} = require('../controllers/userController');

// Import validation middleware
const {
    validateUserRegistration,
    validateLogin,
    updateUserValidator,
} = require('../middleware/validation');

// Test routes (simple authentication for testing)
router.post('/register', validateUserRegistration, registerUser);
router.post('/login', validateLogin, loginUser);
router.get('/', getAllUsers);
router.get('/:id', getUserById);

// Production routes (MongoDB-based)
router.patch('/updateInfo', updateUserValidator, updateInfo);
router.get('/getUserInfo', getUserinfo);
router.get('/getSingleDependent', getSingleDependent);
router.post("/addDependent", addDependent);
router.get('/getAllDependents', getAllDependents);

module.exports = router;
