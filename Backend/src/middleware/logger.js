/**
 * Request logging middleware
 */

const logger = (req, res, next) => {
    const timestamp = new Date().toISOString();
    const { method, url } = req;

    console.log(`[${timestamp}] ${method} ${url}`);

    next();
};

module.exports = logger;
