/**
 * User routes
 */

const express = require('express');
const {
    registerUser,
    loginUser,
    getAllUsers,
    getUserById,
} = require('../controllers/userController');
const {
    validateUserRegistration,
    validateLogin,
} = require('../middleware/validation');

const router = express.Router();

// Public routes
router.post('/register', validateUserRegistration, registerUser);
router.post('/login', validateLogin, loginUser);

// User routes
router.get('/', getAllUsers);
router.get('/:id', getUserById);

module.exports = router;
