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
        const { name, email, mobile, password, confirmPassword, role } = req.body;

        console.log('📝 Registration Request:');
        console.log('   Name:', name);
        console.log('   Email:', email);
        console.log('   Mobile:', mobile);
        console.log('   Role:', role);

        // Convert email to lowercase for case-insensitive comparison
        const emailLowerCase = email.toLowerCase();

        // Build query conditions
        const queryConditions = [{ email: emailLowerCase }];

        // Only check mobile if it's provided and not empty
        if (mobile && mobile.trim() !== '') {
            queryConditions.push({ mobile });
        }

        // Check if user already exists (case-insensitive email)
        let user = await User.findOne({
            $or: queryConditions
        });

        if (user) {
            if (user.email === emailLowerCase) {
                return res.status(400).json({
                    success: false,
                    message: 'A user with this email already exists'
                });
            }
            if (mobile && user.mobile === mobile) {
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
            role: role || 'customer' // Use provided role or default to customer
        });

        // Save user to database
        await user.save();

        // Generate JWT token for the new user
        const token = jwt.sign(
            { id: user._id, email: user.email, role: user.role },
            process.env.JWT_SECRET_KEY || 'housepital_secret_key_2024',
            { expiresIn: '30d' }
        );

        // Log the registration event (without password)
        logEvents(
            `User registered: ${user.email}`,
            'authLog.log'
        );

        // Return success response with token
        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            user: user.toJSON(),
            token: token
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

        // SECURITY: Always verify password - never skip password check even with cache
        // Cache is only used for performance, not for authentication bypass

        // Find user by email and include password field for comparison
        const user = await User.findOne({ email: emailLowerCase }).select('+password_hash');

        if (!user) {
            console.log('❌ Login failed: User not found in second check');
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        // Compare password
        console.log('🔑 Comparing password...');
        const isPasswordValid = await user.comparePassword(password);

        if (!isPasswordValid) {
            console.log('❌ Login failed: Invalid password');
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        console.log('✅ Password valid, generating token...');
        const payload = {
            id: user._id,
            name: user.name,
            email: user.email,
            role: user.role
        };
        
        const secretKey = process.env.JWT_SECRET_KEY || 'housepital_secret_key_2024';
        const options = { expiresIn: '30d' };

        const JWTToken = jwt.sign(payload, secretKey, options);

        // Safely set redis cache
        try {
            await redis.set(emailLowerCase, JSON.stringify(user), { ex: 2592000 }); // 30 days in seconds
            console.log(`💾 user ${email} added to the redis cache`);
        } catch (redisErr) {
            console.warn('⚠️ Redis cache failed, but login continues:', redisErr.message);
        }

        // Build extended user data for doctor/nurse roles
        let profileData = null;
        if (user.role === 'doctor') {
            const Doctor = require('../models/Doctor');
            profileData = await Doctor.findOne({ user: user._id })
                .select('verificationStatus rejectionReason isActive');
        } else if (user.role === 'nurse') {
            const Nurse = require('../models/Nurse');
            profileData = await Nurse.findOne({ user: user._id })
                .select('verificationStatus rejectionReason isActive');
        }

        // Return success response with user data
        return res.status(200).json({
            success: true,
            message: 'User logged in successfully',
            user: {
                ...user.toJSON(),
                // Include profile-specific fields
                ...(profileData ? {
                    verificationStatus: profileData.verificationStatus,
                    rejectionReason: profileData.rejectionReason,
                    isActive: profileData.isActive,
                    hasProfile: true
                } : (['doctor', 'nurse'].includes(user.role) ? { hasProfile: false } : {})),
            },
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



