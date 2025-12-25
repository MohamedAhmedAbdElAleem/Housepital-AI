/**
 * Unit tests for validator utility functions
 */

const {
    isValidEmail,
    isValidPassword,
    isValidPhoneNumber,
    sanitizeString,
} = require('../../utils/validators');

describe('Validators - Unit Tests', () => {
    describe('isValidEmail', () => {
        test('should return true for valid email addresses', () => {
            expect(isValidEmail('test@example.com')).toBe(true);
            expect(isValidEmail('user.name@domain.co.uk')).toBe(true);
            expect(isValidEmail('user+tag@example.org')).toBe(true);
        });

        test('should return false for invalid email addresses', () => {
            expect(isValidEmail('invalid')).toBe(false);
            expect(isValidEmail('invalid@')).toBe(false);
            expect(isValidEmail('@example.com')).toBe(false);
            expect(isValidEmail('test @example.com')).toBe(false);
            expect(isValidEmail('')).toBe(false);
            expect(isValidEmail(null)).toBe(false);
            expect(isValidEmail(undefined)).toBe(false);
        });

        test('should return false for non-string inputs', () => {
            expect(isValidEmail(123)).toBe(false);
            expect(isValidEmail({})).toBe(false);
            expect(isValidEmail([])).toBe(false);
        });
    });

    describe('isValidPassword', () => {
        test('should return true for valid passwords', () => {
            expect(isValidPassword('Password123')).toBe(true);
            expect(isValidPassword('Str0ngP@ss')).toBe(true);
            expect(isValidPassword('Valid1Pass')).toBe(true);
        });

        test('should return false for passwords without uppercase', () => {
            expect(isValidPassword('password123')).toBe(false);
        });

        test('should return false for passwords without lowercase', () => {
            expect(isValidPassword('PASSWORD123')).toBe(false);
        });

        test('should return false for passwords without numbers', () => {
            expect(isValidPassword('PasswordOnly')).toBe(false);
        });

        test('should return false for passwords shorter than 8 characters', () => {
            expect(isValidPassword('Pass12')).toBe(false);
            expect(isValidPassword('Abc123')).toBe(false);
        });

        test('should return false for invalid input types', () => {
            expect(isValidPassword(null)).toBe(false);
            expect(isValidPassword(undefined)).toBe(false);
            expect(isValidPassword(12345678)).toBe(false);
        });
    });

    describe('isValidPhoneNumber', () => {
        test('should return true for valid phone numbers', () => {
            expect(isValidPhoneNumber('+12345678901')).toBe(true);
            expect(isValidPhoneNumber('12345678901')).toBe(true);
            expect(isValidPhoneNumber('+447123456789')).toBe(true);
        });

        test('should return false for invalid phone numbers', () => {
            expect(isValidPhoneNumber('123')).toBe(false);
            expect(isValidPhoneNumber('abc123')).toBe(false);
            expect(isValidPhoneNumber('')).toBe(false);
            expect(isValidPhoneNumber(null)).toBe(false);
        });
    });

    describe('sanitizeString', () => {
        test('should trim whitespace', () => {
            expect(sanitizeString('  hello  ')).toBe('hello');
            expect(sanitizeString('test   ')).toBe('test');
        });

        test('should remove HTML tags', () => {
            expect(sanitizeString('<script>alert("xss")</script>')).toBe('scriptalert("xss")/script');
            expect(sanitizeString('Hello<>World')).toBe('HelloWorld');
        });

        test('should return empty string for invalid inputs', () => {
            expect(sanitizeString(null)).toBe('');
            expect(sanitizeString(undefined)).toBe('');
            expect(sanitizeString(123)).toBe('');
        });

        test('should handle normal strings', () => {
            expect(sanitizeString('Hello World')).toBe('Hello World');
        });
    });
});
