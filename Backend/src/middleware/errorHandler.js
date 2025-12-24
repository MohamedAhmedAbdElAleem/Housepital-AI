/**
 * Error handling middleware
 */

const errorHandler = (err, req, res, next) => {
    // Log the error
    console.error('Error:', err.message);

    // Determine status code
    const statusCode = err.statusCode || 500;

    // Send error response
    res.status(statusCode).json({
        success: false,
        error: err.message || 'Internal Server Error',
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    });
};

module.exports = errorHandler;
