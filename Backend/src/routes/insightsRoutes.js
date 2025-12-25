const express = require("express");
const router = express.Router();
const {
    getDashboardInsights,
    getUserInsights,
    getBookingInsights,
    getFinancialInsights,
    getAllUsers,
    getAuditLogs,
    getAllUsers
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

module.exports = router;

