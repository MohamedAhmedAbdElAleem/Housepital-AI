const express = require("express");
const router = express.Router();
const {
    getDashboardInsights,
    getUserInsights,
    getBookingInsights,
    getFinancialInsights,
    getAllUsers,
    getAuditLogs
} = require("../controllers/insightsController");
const { authenticateToken, authorizeRole } = require("../middleware/authMiddleware");
const User = require("../models/User");

// All routes require authentication and admin role
//router.use(authenticateToken);
// router.use(authorizeRole("admin"));

/**
 * @route   GET /api/admin/insights
 * @desc    Get comprehensive dashboard insights
 * @access  Private (Admin only)
 */
router.get("/", getDashboardInsights);

/**
 * @route   GET /api/admin/insights/users
 * @desc    Get detailed user statistics with trends
 * @query   period - "day" | "week" | "month" (default: "week")
 * @access  Private (Admin only)
 */
router.get("/users", getUserInsights);

/**
 * @route   GET /api/admin/insights/all-users
 * @desc    Get all users list
 * @access  Private (Admin only)
 */
router.get("/all-users", getAllUsers);

/**
 * @route   GET /api/admin/insights/logs
 * @desc    Get system audit logs
 * @access  Private (Admin only)
 */
router.get("/logs", getAuditLogs);

/**
 * @route   GET /api/admin/insights/bookings
 * @desc    Get booking analytics
 * @query   period - "day" | "week" | "month" (default: "week")
 * @access  Private (Admin only)
 */
router.get("/bookings", getBookingInsights);

/**
 * @route   GET /api/admin/insights/financial
 * @desc    Get financial analytics
 * @query   period - "week" | "month" | "year" (default: "month")
 * @access  Private (Admin only)
 */
router.get("/financial", getFinancialInsights);

/**
 * @route   POST /api/admin/staff
 * @desc    Add a new staff member (nurse, doctor, or admin)
 * @access  Private (Admin only)
 */
router.post("/staff", async (req, res) => {
    try {
        const { name, email, mobile, password, role, gender, isVerified, status } = req.body;

        // Validate role
        if (!['nurse', 'doctor', 'admin'].includes(role)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid role. Must be nurse, doctor, or admin'
            });
        }

        // Check if user already exists
        const existingUser = await User.findOne({
            $or: [{ email: email.toLowerCase() }, { mobile }]
        });

        if (existingUser) {
            if (existingUser.email === email.toLowerCase()) {
                return res.status(400).json({
                    success: false,
                    message: 'A user with this email already exists'
                });
            }
            return res.status(400).json({
                success: false,
                message: 'A user with this mobile number already exists'
            });
        }

        // Create new staff user
        const newUser = new User({
            name,
            email: email.toLowerCase(),
            mobile,
            password_hash: password, // Will be hashed by pre-save hook
            role,
            gender: gender || undefined,
            isVerified: isVerified !== undefined ? isVerified : true,
            status: status || 'approved',
            verificationStatus: 'verified'
        });

        await newUser.save();

        res.status(201).json({
            success: true,
            message: `${role.charAt(0).toUpperCase() + role.slice(1)} added successfully`,
            user: newUser.toJSON()
        });

    } catch (error) {
        console.error('Add staff error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Error adding staff member'
        });
    }
});

/**
 * @route   GET /api/admin/staff
 * @desc    Get all staff members
 * @access  Private (Admin only)
 */
router.get("/staff", async (req, res) => {
    try {
        const { role } = req.query;

        const query = { role: { $in: ['nurse', 'doctor', 'admin'] } };
        if (role && ['nurse', 'doctor', 'admin'].includes(role)) {
            query.role = role;
        }

        const staff = await User.find(query)
            .select('-password_hash -salt -hashingAlgorithm -costFactor')
            .sort({ createdAt: -1 });

        res.json({
            success: true,
            count: staff.length,
            staff
        });

    } catch (error) {
        console.error('Get staff error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Error fetching staff members'
        });
    }
});

/**
 * @route   PATCH /api/admin/users/:userId
 * @desc    Update a user's details (admin only)
 * @access  Private (Admin only)
 */
router.patch("/users/:userId", async (req, res) => {
    try {
        const { userId } = req.params;
        const { name, email, mobile, role, verificationStatus, isVerified, status } = req.body;

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Update fields if provided
        if (name) user.name = name;
        if (email) user.email = email;
        if (mobile) user.mobile = mobile;
        if (role && ['customer', 'nurse', 'doctor', 'admin'].includes(role)) {
            user.role = role;
        }
        if (verificationStatus && ['unverified', 'pending', 'verified', 'rejected'].includes(verificationStatus)) {
            user.verificationStatus = verificationStatus;
        }
        if (typeof isVerified === 'boolean') {
            user.isVerified = isVerified;
        }
        if (status && ['pending', 'approved', 'rejected', 'suspended'].includes(status)) {
            user.status = status;
        }

        await user.save();

        res.json({
            success: true,
            message: 'User updated successfully',
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                mobile: user.mobile,
                role: user.role,
                verificationStatus: user.verificationStatus,
                isVerified: user.isVerified,
                status: user.status
            }
        });

    } catch (error) {
        console.error('Update user error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Error updating user'
        });
    }
});

/**
 * @route   DELETE /api/admin/insights/users/:userId
 * @desc    Delete a user permanently
 * @access  Private (Admin only)
 */
router.delete("/users/:userId", async (req, res) => {
    try {
        const { userId } = req.params;

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        await User.findByIdAndDelete(userId);

        res.json({
            success: true,
            message: 'User deleted successfully'
        });

    } catch (error) {
        console.error('Delete user error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Error deleting user'
        });
    }
});

/**
 * @route   PATCH /api/admin/insights/users/:userId/deactivate
 * @desc    Deactivate a user account
 * @access  Private (Admin only)
 */
router.patch("/users/:userId/deactivate", async (req, res) => {
    try {
        const { userId } = req.params;
        const { isActive, deactivation } = req.body;

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        user.isActive = false;
        user.deactivation = {
            startDate: deactivation?.startDate || new Date(),
            endDate: deactivation?.endDate,
            durationDays: deactivation?.durationDays,
            reason: deactivation?.reason || 'Administrative action'
        };

        await user.save();

        res.json({
            success: true,
            message: 'User deactivated successfully',
            user: {
                id: user._id,
                name: user.name,
                isActive: user.isActive,
                deactivation: user.deactivation
            }
        });

    } catch (error) {
        console.error('Deactivate user error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Error deactivating user'
        });
    }
});

/**
 * @route   PATCH /api/admin/insights/users/:userId/reactivate
 * @desc    Reactivate a user account
 * @access  Private (Admin only)
 */
router.patch("/users/:userId/reactivate", async (req, res) => {
    try {
        const { userId } = req.params;

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        user.isActive = true;
        user.deactivation = undefined;

        await user.save();

        res.json({
            success: true,
            message: 'User reactivated successfully',
            user: {
                id: user._id,
                name: user.name,
                isActive: user.isActive
            }
        });

    } catch (error) {
        console.error('Reactivate user error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Error reactivating user'
        });
    }
});

module.exports = router;

