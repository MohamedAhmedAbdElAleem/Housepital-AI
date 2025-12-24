/**
 * Unit tests for user controller
 */

const {
    registerUser,
    loginUser,
    getAllUsers,
    getUserById,
    clearUsers,
} = require('../../controllers/userController');

describe('UserController - Unit Tests', () => {
    let mockReq;
    let mockRes;

    beforeEach(() => {
        clearUsers(); // Clear users before each test
        mockReq = {
            body: {},
            params: {},
        };
        mockRes = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn().mockReturnThis(),
        };
    });

    describe('registerUser', () => {
        test('should register a new user successfully', () => {
            mockReq.body = {
                email: 'test@example.com',
                password: 'Password123',
                name: 'Test User',
            };

            registerUser(mockReq, mockRes);

            expect(mockRes.status).toHaveBeenCalledWith(201);
            expect(mockRes.json).toHaveBeenCalledWith({
                success: true,
                data: expect.objectContaining({
                    email: 'test@example.com',
                    name: 'Test User',
                    id: 1,
                }),
            });
            // Password should not be in response
            expect(mockRes.json.mock.calls[0][0].data.password).toBeUndefined();
        });

        test('should reject duplicate email registration', () => {
            const userData = {
                email: 'test@example.com',
                password: 'Password123',
                name: 'Test User',
            };

            mockReq.body = userData;
            registerUser(mockReq, mockRes);

            // Try to register again with same email
            mockReq.body = userData;
            registerUser(mockReq, mockRes);

            expect(mockRes.status).toHaveBeenCalledWith(409);
            expect(mockRes.json).toHaveBeenCalledWith({
                success: false,
                error: 'User already exists',
            });
        });
    });

    describe('loginUser', () => {
        beforeEach(() => {
            // Register a user first
            mockReq.body = {
                email: 'test@example.com',
                password: 'Password123',
                name: 'Test User',
            };
            registerUser(mockReq, mockRes);
        });

        test('should login with valid credentials', () => {
            mockReq.body = {
                email: 'test@example.com',
                password: 'Password123',
            };

            loginUser(mockReq, mockRes);

            expect(mockRes.status).toHaveBeenCalledWith(200);
            expect(mockRes.json).toHaveBeenCalledWith({
                success: true,
                data: expect.objectContaining({
                    email: 'test@example.com',
                    name: 'Test User',
                }),
                token: 'mock-jwt-token',
            });
        });

        test('should reject invalid credentials', () => {
            mockReq.body = {
                email: 'test@example.com',
                password: 'WrongPassword',
            };

            loginUser(mockReq, mockRes);

            expect(mockRes.status).toHaveBeenCalledWith(401);
            expect(mockRes.json).toHaveBeenCalledWith({
                success: false,
                error: 'Invalid credentials',
            });
        });

        test('should reject non-existent user', () => {
            mockReq.body = {
                email: 'nonexistent@example.com',
                password: 'Password123',
            };

            loginUser(mockReq, mockRes);

            expect(mockRes.status).toHaveBeenCalledWith(401);
        });
    });

    describe('getAllUsers', () => {
        test('should return empty array when no users', () => {
            getAllUsers(mockReq, mockRes);

            expect(mockRes.status).toHaveBeenCalledWith(200);
            expect(mockRes.json).toHaveBeenCalledWith({
                success: true,
                count: 0,
                data: [],
            });
        });

        test('should return all users without passwords', () => {
            // Register two users
            mockReq.body = {
                email: 'user1@example.com',
                password: 'Password123',
                name: 'User One',
            };
            registerUser(mockReq, mockRes);

            mockReq.body = {
                email: 'user2@example.com',
                password: 'Password456',
                name: 'User Two',
            };
            registerUser(mockReq, mockRes);

            getAllUsers(mockReq, mockRes);

            const lastCall = mockRes.json.mock.calls[mockRes.json.mock.calls.length - 1][0];
            expect(lastCall.count).toBe(2);
            expect(lastCall.data).toHaveLength(2);
            expect(lastCall.data[0].password).toBeUndefined();
            expect(lastCall.data[1].password).toBeUndefined();
        });
    });

    describe('getUserById', () => {
        beforeEach(() => {
            mockReq.body = {
                email: 'test@example.com',
                password: 'Password123',
                name: 'Test User',
            };
            registerUser(mockReq, mockRes);
        });

        test('should return user by id', () => {
            mockReq.params = { id: '1' };

            getUserById(mockReq, mockRes);

            expect(mockRes.status).toHaveBeenCalledWith(200);
            expect(mockRes.json).toHaveBeenCalledWith({
                success: true,
                data: expect.objectContaining({
                    id: 1,
                    email: 'test@example.com',
                }),
            });
        });

        test('should return 404 for non-existent user', () => {
            mockReq.params = { id: '999' };

            getUserById(mockReq, mockRes);

            expect(mockRes.status).toHaveBeenCalledWith(404);
            expect(mockRes.json).toHaveBeenCalledWith({
                success: false,
                error: 'User not found',
            });
        });
    });
});
