const User = require('../models/User');
const { logEvents } = require('../middleware/logger');
const jwt = require('jsonwebtoken');
const { createRedisClient } = require('../caching/redis');
const redis = createRedisClient();


/**
 * @desc    Register a new user
 * @route   POST /api/auth/register
 * @access  Public
 */
exports.register = async (req, res, next) => {
    try {
        const { name, email, mobile, password, confirmPassword } = req.body;

        // Convert email to lowercase for case-insensitive comparison
        const emailLowerCase = email.toLowerCase();

        // Check if user already exists (case-insensitive email)
        let user = await User.findOne({
            $or: [
                { email: emailLowerCase },
                { mobile }
            ]
        });

        if (user) {
            if (user.email === emailLowerCase) {
                return res.status(400).json({
                    success: false,
                    message: 'A user with this email already exists'
                });
            }
            if (user.mobile === mobile) {
                return res.status(400).json({
                    success: false,
                    message: 'A user with this mobile number already exists'
                });
            }
        }

        // Create new user
        user = new User({
            name,
            email: emailLowerCase, // Store email in lowercase
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
        

        // Convert email to lowercase for case-insensitive comparison
        const emailLowerCase = email.toLowerCase();
        // await redis.del(emailLowerCase);

        const temp_user = await User.findOne({ email });
        if (!temp_user) return res.status(404).json({ message: "User not found" });

        const userLastUpdate = temp_user?.updatedAt;

        const cachedUser = await redis.get(emailLowerCase);

        //console.log(cachedUser);

        // Only check cache times if cachedUser exists
        if (cachedUser && userLastUpdate) {
            const dbTime = new Date(userLastUpdate).toISOString();
            const cacheTime = new Date(cachedUser.updatedAt).toISOString();

            console.log(cachedUser.updatedAt);
            console.log(userLastUpdate);
            console.log(userLastUpdate == cachedUser.updatedAt);
            console.log(typeof(cachedUser.updatedAt),typeof(userLastUpdate))

            if (dbTime === cacheTime) {
                try {
                    const user = cachedUser;
                    console.log(`✅ User ${emailLowerCase} fetched from Redis cache`);

                    const token = jwt.sign(
                        { 
                            id: user._id,
                            name: user.name, 
                            email: user.email,
                            role: user.role
                        },
                        process.env.JWT_SECRET_KEY,
                        { expiresIn: '3h' }
                    );

                    return res.status(200).json({
                        success: true,
                        message: 'User logged in successfully (from cache)',
                        response: user,
                        token
                    });
                } catch (err) {
                    console.error('⚠️ Invalid cache data, deleting...', err);
                    await redis.del(emailLowerCase);
                }
            }
        }



        // Find user by email and include password field for comparison
        const user = await User.findOne({ email: emailLowerCase }).select('+password_hash');

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


        const payload = {
            id: user._id,
            name: user.name,
            email: user.email,
            role: user.role
        };
        const secretKey = process.env.JWT_SECRET_KEY;
        const options = { expiresIn: '3h' };

        const JWTToken = jwt.sign(payload, secretKey, options);



        redis.set(emailLowerCase, JSON.stringify(user), { ex: 3600 });

        console.log(`user ${email} added to the redis cache`);


        // Return success response with user data
        res.status(200).json({
            success: true,
            message: 'User logged in successfully',
            user: user.toJSON(),
            token: JWTToken 
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
    }
};

/**
 * @desc    Get current logged in user
 * @route   GET /api/auth/me
 * @access  Private
 */
exports.getCurrentUser = async (req, res, next) => {
    try {
        console.log('📋 getCurrentUser called');
        console.log('👤 req.user:', req.user);
        
        // Assuming middleware sets req.user with userId
        if (!req.user) {
            console.log('❌ No user in request');
            return res.status(401).json({
                success: false,
                message: 'Not authenticated'
            });
        }

        console.log('🔍 Finding user by ID:', req.user.id);
        const user = await User.findById(req.user.id);

        if (!user) {
            console.log('❌ User not found in database');
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        console.log('✅ User found:', user.email);
        res.status(200).json({
            success: true,
            user: user.toJSON()
        });

    } catch (error) {
        console.error('❌ Error in getCurrentUser:', error);
        logEvents(
            `Get current user error: ${error.message}`,
            'authErrLog.log'
        );

        res.status(500).json({
            success: false,
            message: error.message || 'Error getting user'
        });
    }
};



