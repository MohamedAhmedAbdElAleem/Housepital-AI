/**
 * Unit tests for middleware functions
 */

const errorHandler = require('../../middleware/errorHandler');
const logger = require('../../middleware/logger');

describe('Middleware - Unit Tests', () => {
    describe('errorHandler', () => {
        let mockReq;
        let mockRes;
        let mockNext;

        beforeEach(() => {
            mockReq = {};
            mockRes = {
                status: jest.fn().mockReturnThis(),
                json: jest.fn().mockReturnThis(),
            };
            mockNext = jest.fn();
            // Mock console.error to avoid cluttering test output
            jest.spyOn(console, 'error').mockImplementation(() => { });
        });

        afterEach(() => {
            console.error.mockRestore();
        });

        test('should handle errors with status code', () => {
            const error = new Error('Test error');
            error.statusCode = 400;

            errorHandler(error, mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith({
                success: false,
                error: 'Test error',
                stack: undefined,
            });
        });

        test('should default to 500 status code', () => {
            const error = new Error('Server error');

            errorHandler(error, mockReq, mockRes, mockNext);

            expect(mockRes.status).toHaveBeenCalledWith(500);
        });

        test('should include stack trace in development mode', () => {
            process.env.NODE_ENV = 'development';
            const error = new Error('Dev error');

            errorHandler(error, mockReq, mockRes, mockNext);

            expect(mockRes.json).toHaveBeenCalledWith({
                success: false,
                error: 'Dev error',
                stack: error.stack,
            });

            delete process.env.NODE_ENV;
        });

        test('should log error message', () => {
            const error = new Error('Test error');

            errorHandler(error, mockReq, mockRes, mockNext);

            expect(console.error).toHaveBeenCalledWith('Error:', 'Test error');
        });
    });

    describe('logger', () => {
        let mockReq;
        let mockRes;
        let mockNext;

        beforeEach(() => {
            mockReq = {
                method: 'GET',
                url: '/api/test',
            };
            mockRes = {};
            mockNext = jest.fn();
            jest.spyOn(console, 'log').mockImplementation(() => { });
        });

        afterEach(() => {
            console.log.mockRestore();
        });

        test('should log request method and URL', () => {
            logger(mockReq, mockRes, mockNext);

            expect(console.log).toHaveBeenCalled();
            const logCall = console.log.mock.calls[0][0];
            expect(logCall).toContain('GET');
            expect(logCall).toContain('/api/test');
        });

        test('should call next middleware', () => {
            logger(mockReq, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
        });

        test('should log POST requests', () => {
            mockReq.method = 'POST';
            mockReq.url = '/api/users';

            logger(mockReq, mockRes, mockNext);

            const logCall = console.log.mock.calls[0][0];
            expect(logCall).toContain('POST');
            expect(logCall).toContain('/api/users');
        });
    });
});
