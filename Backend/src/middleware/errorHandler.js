/**
 * Error handling middleware - Enhanced version with file logging
 */

const { logEvents } = require('./logger');

const errorHandler = (err, req, res, next) => {
    // Log the error to file
    logEvents(`${err.name}: ${err.message}`, 'errLog.txt');

    // Log to console
    console.error('Error:', err.message);
    console.error(err.stack);

    // Determine status code
    const statusCode = err.statusCode || res.statusCode || 500;

    // Send error response
    res.status(statusCode).json({
        success: false,
        message: err.message || 'Internal Server Error',
        error: err.message,
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    });
};

module.exports = errorHandler;
