/**
 * User controller
 */

const users = []; // In-memory storage for demo purposes

const registerUser = (req, res) => {
    const { email, password, name } = req.body;

    // Check if user already exists
    const existingUser = users.find((user) => user.email === email);
    if (existingUser) {
        return res.status(409).json({
            success: false,
            error: 'User already exists',
        });
    }

    // Create new user
    const newUser = {
        id: users.length + 1,
        email,
        name,
        password, // In production, this should be hashed
        createdAt: new Date(),
    };

    users.push(newUser);

    // Return user without password
    const { password: _, ...userWithoutPassword } = newUser;

    res.status(201).json({
        success: true,
        data: userWithoutPassword,
    });
};

const loginUser = (req, res) => {
    const { email, password } = req.body;

    // Find user
    const user = users.find((u) => u.email === email && u.password === password);

    if (!user) {
        return res.status(401).json({
            success: false,
            error: 'Invalid credentials',
        });
    }

    // Return user without password
    const { password: _, ...userWithoutPassword } = user;

    res.status(200).json({
        success: true,
        data: userWithoutPassword,
        token: 'mock-jwt-token', // In production, generate real JWT
    });
};

const getAllUsers = (req, res) => {
    // Remove passwords from response
    const usersWithoutPasswords = users.map(({ password, ...user }) => user);

    res.status(200).json({
        success: true,
        count: users.length,
        data: usersWithoutPasswords,
    });
};

const getUserById = (req, res) => {
    const { id } = req.params;
    const user = users.find((u) => u.id === parseInt(id, 10));

    if (!user) {
        return res.status(404).json({
            success: false,
            error: 'User not found',
        });
    }

    const { password: _, ...userWithoutPassword } = user;

    res.status(200).json({
        success: true,
        data: userWithoutPassword,
    });
};

// Helper function for testing
const clearUsers = () => {
    users.length = 0;
};

module.exports = {
    registerUser,
    loginUser,
    getAllUsers,
    getUserById,
    clearUsers,
};
