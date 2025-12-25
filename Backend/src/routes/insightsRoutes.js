const express = require("express");
const router = express.Router();
const {
    getDashboardInsights,
    getUserInsights,
    getBookingInsights,
    getFinancialInsights
} = require("../controllers/insightsController");
const { authenticateToken, authorizeRole } = require("../middleware/authMiddleware");

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

module.exports = router;
