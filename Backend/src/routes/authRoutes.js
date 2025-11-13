const express = require('express');
const router = express.Router();
const { register, login, getCurrentUser } = require('../controllers/authController');
const { validateRegister, validateLogin } = require('../middleware/validation');

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post('/register', validateRegister, register);

/**
 * @route   POST /api/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post('/login', validateLogin, login);

/**
 * @route   GET /api/auth/me
 * @desc    Get current logged in user
 * @access  Private (requires authentication middleware)
 */
router.get('/me', getCurrentUser);

module.exports = router;
