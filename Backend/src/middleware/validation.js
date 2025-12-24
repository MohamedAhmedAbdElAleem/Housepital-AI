/**
 * Request validation middleware
 */

const { isValidEmail } = require('../utils/validators');

const validateUserRegistration = (req, res, next) => {
    const { email, password, name } = req.body;

    if (!name || name.trim().length === 0) {
        return res.status(400).json({
            success: false,
            error: 'Name is required',
        });
    }

    if (!isValidEmail(email)) {
        return res.status(400).json({
            success: false,
            error: 'Valid email is required',
        });
    }

    if (!password || password.length < 8) {
        return res.status(400).json({
            success: false,
            error: 'Password must be at least 8 characters',
        });
    }

    next();
};

const validateLogin = (req, res, next) => {
    const { email, password } = req.body;

    if (!isValidEmail(email)) {
        return res.status(400).json({
            success: false,
            error: 'Valid email is required',
        });
    }

    if (!password) {
        return res.status(400).json({
            success: false,
            error: 'Password is required',
        });
    }

    next();
};

module.exports = {
    validateUserRegistration,
    validateLogin,
};
