
const { logEvents } = require('./logger');

const authenticateToken = async (req, res, next) => {
    try {
        next();
    } catch (error) {
        logEvents(
            `Authentication error: ${error.message}`,
            'authErrLog.log'
        );

        res.status(500).json({
            success: false,
            message: 'Authentication error'
        });
    }
};


const authorizeRole = (...allowedRoles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Not authenticated'
            });
        }

        if (!allowedRoles.includes(req.user.role)) {
            logEvents(
                `Unauthorized access attempt: ${req.user.email} trying to access ${req.path}`,
                'authLog.log'
            );

            return res.status(403).json({
                success: false,
                message: 'Access denied. Required role: ' + allowedRoles.join(', ')
            });
        }

        next();
    };
};


const verifyEmail = async (req, res, next) => {
    try {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Not authenticated'
            });
        }

        const User = require('../models/User');
        const user = await User.findById(req.user.id);

        if (!user.isVerified) {
            return res.status(403).json({
                success: false,
                message: 'Please verify your email first'
            });
        }

        next();
    } catch (error) {
        logEvents(
            `Email verification check error: ${error.message}`,
            'authErrLog.log'
        );

        res.status(500).json({
            success: false,
            message: 'Error checking email verification'
        });
    }
};
module.exports = {
    authenticateToken,
    authorizeRole,
    verifyEmail
};
