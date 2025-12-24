/**
 * Integration tests for user API endpoints
 */

const request = require('supertest');
const app = require('../../server');
const { clearUsers } = require('../../controllers/userController');

describe('User API - Integration Tests', () => {
    beforeEach(() => {
        clearUsers(); // Clear users before each test
    });

    describe('GET /health', () => {
        test('should return health status', async () => {
            const response = await request(app).get('/health');

            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('status', 'healthy');
            expect(response.body).toHaveProperty('timestamp');
        });
    });

    describe('POST /api/users/register', () => {
        test('should register a new user successfully', async () => {
            const userData = {
                email: 'newuser@example.com',
                password: 'Password123',
                name: 'New User',
            };

            const response = await request(app)
                .post('/api/users/register')
                .send(userData)
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(201);
            expect(response.body.success).toBe(true);
            expect(response.body.data).toHaveProperty('email', 'newuser@example.com');
            expect(response.body.data).toHaveProperty('name', 'New User');
            expect(response.body.data).toHaveProperty('id');
            expect(response.body.data).not.toHaveProperty('password');
        });

        test('should reject registration with missing name', async () => {
            const userData = {
                email: 'test@example.com',
                password: 'Password123',
            };

            const response = await request(app)
                .post('/api/users/register')
                .send(userData)
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(400);
            expect(response.body.success).toBe(false);
            expect(response.body.error).toContain('Name is required');
        });

        test('should reject registration with invalid email', async () => {
            const userData = {
                email: 'invalid-email',
                password: 'Password123',
                name: 'Test User',
            };

            const response = await request(app)
                .post('/api/users/register')
                .send(userData)
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(400);
            expect(response.body.success).toBe(false);
            expect(response.body.error).toContain('email');
        });

        test('should reject registration with short password', async () => {
            const userData = {
                email: 'test@example.com',
                password: 'Short1',
                name: 'Test User',
            };

            const response = await request(app)
                .post('/api/users/register')
                .send(userData)
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(400);
            expect(response.body.success).toBe(false);
            expect(response.body.error).toContain('Password');
        });

        test('should reject duplicate email registration', async () => {
            const userData = {
                email: 'duplicate@example.com',
                password: 'Password123',
                name: 'Test User',
            };

            // First registration
            await request(app)
                .post('/api/users/register')
                .send(userData)
                .set('Content-Type', 'application/json');

            // Second registration with same email
            const response = await request(app)
                .post('/api/users/register')
                .send(userData)
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(409);
            expect(response.body.success).toBe(false);
            expect(response.body.error).toContain('already exists');
        });
    });

    describe('POST /api/users/login', () => {
        beforeEach(async () => {
            // Register a user for login tests
            await request(app)
                .post('/api/users/register')
                .send({
                    email: 'loginuser@example.com',
                    password: 'Password123',
                    name: 'Login User',
                });
        });

        test('should login successfully with valid credentials', async () => {
            const response = await request(app)
                .post('/api/users/login')
                .send({
                    email: 'loginuser@example.com',
                    password: 'Password123',
                })
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data).toHaveProperty('email', 'loginuser@example.com');
            expect(response.body).toHaveProperty('token');
            expect(response.body.data).not.toHaveProperty('password');
        });

        test('should reject login with invalid password', async () => {
            const response = await request(app)
                .post('/api/users/login')
                .send({
                    email: 'loginuser@example.com',
                    password: 'WrongPassword123',
                })
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(401);
            expect(response.body.success).toBe(false);
            expect(response.body.error).toContain('Invalid credentials');
        });

        test('should reject login with non-existent email', async () => {
            const response = await request(app)
                .post('/api/users/login')
                .send({
                    email: 'nonexistent@example.com',
                    password: 'Password123',
                })
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(401);
            expect(response.body.success).toBe(false);
        });

        test('should reject login with invalid email format', async () => {
            const response = await request(app)
                .post('/api/users/login')
                .send({
                    email: 'invalid-email',
                    password: 'Password123',
                })
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(400);
            expect(response.body.success).toBe(false);
            expect(response.body.error).toContain('email');
        });

        test('should reject login without password', async () => {
            const response = await request(app)
                .post('/api/users/login')
                .send({
                    email: 'loginuser@example.com',
                })
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(400);
            expect(response.body.success).toBe(false);
            expect(response.body.error).toContain('Password');
        });
    });

    describe('GET /api/users', () => {
        test('should return empty array when no users exist', async () => {
            const response = await request(app).get('/api/users');

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.count).toBe(0);
            expect(response.body.data).toEqual([]);
        });

        test('should return all users', async () => {
            // Register multiple users
            await request(app)
                .post('/api/users/register')
                .send({
                    email: 'user1@example.com',
                    password: 'Password123',
                    name: 'User One',
                });

            await request(app)
                .post('/api/users/register')
                .send({
                    email: 'user2@example.com',
                    password: 'Password456',
                    name: 'User Two',
                });

            const response = await request(app).get('/api/users');

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.count).toBe(2);
            expect(response.body.data).toHaveLength(2);
            expect(response.body.data[0]).not.toHaveProperty('password');
            expect(response.body.data[1]).not.toHaveProperty('password');
        });
    });

    describe('GET /api/users/:id', () => {
        beforeEach(async () => {
            await request(app)
                .post('/api/users/register')
                .send({
                    email: 'getuser@example.com',
                    password: 'Password123',
                    name: 'Get User',
                });
        });

        test('should get user by id', async () => {
            const response = await request(app).get('/api/users/1');

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data).toHaveProperty('id', 1);
            expect(response.body.data).toHaveProperty('email', 'getuser@example.com');
            expect(response.body.data).not.toHaveProperty('password');
        });

        test('should return 404 for non-existent user', async () => {
            const response = await request(app).get('/api/users/999');

            expect(response.status).toBe(404);
            expect(response.body.success).toBe(false);
            expect(response.body.error).toContain('not found');
        });
    });

    describe('Complete workflow integration test', () => {
        test('should complete full user registration, login, and retrieval flow', async () => {
            // Step 1: Register a user
            const registerResponse = await request(app)
                .post('/api/users/register')
                .send({
                    email: 'workflow@example.com',
                    password: 'Workflow123',
                    name: 'Workflow User',
                });

            expect(registerResponse.status).toBe(201);
            const userId = registerResponse.body.data.id;

            // Step 2: Login with the user
            const loginResponse = await request(app)
                .post('/api/users/login')
                .send({
                    email: 'workflow@example.com',
                    password: 'Workflow123',
                });

            expect(loginResponse.status).toBe(200);
            expect(loginResponse.body).toHaveProperty('token');

            // Step 3: Get user by ID
            const getUserResponse = await request(app).get(`/api/users/${userId}`);

            expect(getUserResponse.status).toBe(200);
            expect(getUserResponse.body.data).toHaveProperty('email', 'workflow@example.com');

            // Step 4: Get all users
            const getAllResponse = await request(app).get('/api/users');

            expect(getAllResponse.status).toBe(200);
            expect(getAllResponse.body.count).toBeGreaterThan(0);
        });
    });
});
