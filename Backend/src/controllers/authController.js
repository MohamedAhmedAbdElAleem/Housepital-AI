const User = require('../models/User');
const { logEvents } = require('../middleware/logger');

/**
 * @desc    Register a new user
 * @route   POST /api/auth/register
 * @access  Public
 */
exports.register = async (req, res, next) => {
    try {
        const { name, email, mobile, password, confirmPassword } = req.body;

        // Check if user already exists
        let user = await User.findOne({
            $or: [{ email }, { mobile }]
        });

        if (user) {
            const existingField = user.email === email ? 'email' : 'mobile';
            return res.status(400).json({
                success: false,
                message: `A user with this ${existingField} already exists`
            });
        }

        // Create new user
        user = new User({
            name,
            email,
            mobile,
            password_hash: password, // Will be hashed by the pre-save hook
            isVerified: false,
            role: 'customer'
        });

        // Save user to database
        await user.save();

        // Log the registration event (without password)
        logEvents(
            `User registered: ${user.email}`,
            'authLog.log'
        );

        // Return success response (sensitive data automatically excluded by toJSON)
        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            user: user.toJSON(),
            token: null // Could generate JWT here if needed
        });

    } catch (error) {
        // Log error without sensitive data
        logEvents(
            `Register error: ${error.message}`,
            'authErrLog.log'
        );

        // Return error response
        res.status(500).json({
            success: false,
            message: error.message || 'Error registering user'
        });

        next(error);
    }
};

/**
 * @desc    Login user
 * @route   POST /api/auth/login
 * @access  Public
 */
exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        // Find user by email and include password field for comparison
        const user = await User.findOne({ email }).select('+password_hash');

        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        // Compare password with stored hash
        const isPasswordValid = await user.comparePassword(password);

        if (!isPasswordValid) {
            // Log failed login attempt (don't log password)
            logEvents(
                `Failed login attempt for: ${email}`,
                'authLog.log'
            );

            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        // Log successful login
        logEvents(
            `User logged in: ${email}`,
            'authLog.log'
        );

        // Return success response with user data
        res.status(200).json({
            success: true,
            message: 'User logged in successfully',
            user: user.toJSON(),
            token: null // Could generate JWT here if needed
        });

    } catch (error) {
        // Log error
        logEvents(
            `Login error: ${error.message}`,
            'authErrLog.log'
        );

        res.status(500).json({
            success: false,
            message: error.message || 'Error logging in'
        });

        next(error);
    }
};

/**
 * @desc    Get current logged in user
 * @route   GET /api/auth/me
 * @access  Private
 */
exports.getCurrentUser = async (req, res, next) => {
    try {
        // Assuming middleware sets req.user with userId
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Not authenticated'
            });
        }

        const user = await User.findById(req.user.id);

        res.status(200).json({
            success: true,
            user
        });

    } catch (error) {
        logEvents(
            `Get current user error: ${error.message}`,
            'authErrLog.log'
        );

        res.status(500).json({
            success: false,
            message: error.message || 'Error getting user'
        });

        next(error);
    }
};
