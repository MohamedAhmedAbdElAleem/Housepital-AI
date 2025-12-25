/**
 * Validation utility functions
 */

const isValidEmail = (email) => {
    if (!email || typeof email !== 'string') return false;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
};

const isValidPassword = (password) => {
    if (!password || typeof password !== 'string') return false;
    // At least 8 characters, one uppercase, one lowercase, one number
    return password.length >= 8
        && /[A-Z]/.test(password)
        && /[a-z]/.test(password)
        && /[0-9]/.test(password);
};

const isValidPhoneNumber = (phone) => {
    if (!phone || typeof phone !== 'string') return false;
    // Basic phone number validation (10-15 digits)
    const phoneRegex = /^\+?[1-9]\d{9,14}$/;
    return phoneRegex.test(phone);
};

const sanitizeString = (str) => {
    if (!str || typeof str !== 'string') return '';
    return str.trim().replace(/[<>]/g, '');
};

module.exports = {
    isValidEmail,
    isValidPassword,
    isValidPhoneNumber,
    sanitizeString,
};
