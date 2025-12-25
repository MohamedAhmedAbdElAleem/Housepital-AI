const User = require("../models/User");
const Nurse = require("../models/Nurse");
const Doctor = require("../models/Doctor");
const Booking = require("../models/Booking");
const Dependent = require("../models/dependent");
const Clinic = require("../models/Clinic");
const Service = require("../models/Service");
const Transaction = require("../models/Transaction");
const Rating = require("../models/Rating");

const AuditLog = require("../models/audit-logging");

/**
 * @desc    Get comprehensive admin dashboard insights
 * @route   GET /api/admin/insights
 * @access  Private (Admin only)
 */
const getDashboardInsights = async (req, res) => {
    try {
        const now = new Date();
        const startOfToday = new Date(now.setHours(0, 0, 0, 0));
        const startOfWeek = new Date(now.setDate(now.getDate() - now.getDay()));
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        // Execute all queries in parallel for performance
        const [
            // User counts by role
            userStats,
            // Verification pending counts
            pendingVerifications,
            // Booking stats
            bookingStats,
            // Today's activity
            todayActivity,
            // Financial overview
            financialStats,
            // Provider availability
            providerAvailability,
            // Recent activity
            recentBookings,
            // Top performers
            topNurses
        ] = await Promise.all([
            // 1. User Statistics
            User.aggregate([
                {
                    $group: {
                        _id: "$role",
                        total: { $sum: 1 },
                        verified: { $sum: { $cond: [{ $eq: ["$verificationStatus", "verified"] }, 1, 0] } },
                        pending: { $sum: { $cond: [{ $eq: ["$status", "pending"] }, 1, 0] } },
                        approved: { $sum: { $cond: [{ $eq: ["$status", "approved"] }, 1, 0] } },
                        online: { $sum: { $cond: [{ $eq: ["$isOnline", true] }, 1, 0] } }
                    }
                }
            ]),

            // 2. Pending Verifications
            Promise.all([
                User.countDocuments({ verificationStatus: "pending" }),
                Nurse.countDocuments({ verificationStatus: "pending" }),
                Doctor.countDocuments({ verificationStatus: "pending" }),
                Dependent.countDocuments({ verificationStatus: "pending" }),
                Clinic.countDocuments({ verificationStatus: "pending" })
            ]),

            // 3. Booking Statistics
            Booking.aggregate([
                {
                    $facet: {
                        byStatus: [
                            { $group: { _id: "$status", count: { $sum: 1 } } }
                        ],
                        byType: [
                            { $group: { _id: "$type", count: { $sum: 1 } } }
                        ],
                        overall: [
                            {
                                $group: {
                                    _id: null,
                                    total: { $sum: 1 },
                                    completed: { $sum: { $cond: [{ $eq: ["$status", "completed"] }, 1, 0] } },
                                    cancelled: { $sum: { $cond: [{ $eq: ["$status", "cancelled"] }, 1, 0] } },
                                    noShow: { $sum: { $cond: [{ $eq: ["$status", "no-show"] }, 1, 0] } },
                                    avgRating: { $avg: "$customerRating" }
                                }
                            }
                        ]
                    }
                }
            ]),

            // 4. Today's Activity
            Promise.all([
                Booking.countDocuments({ createdAt: { $gte: startOfToday } }),
                Booking.countDocuments({ status: "completed", visitEndedAt: { $gte: startOfToday } }),
                User.countDocuments({ createdAt: { $gte: startOfToday } }),
                Booking.countDocuments({ status: { $in: ["pending", "searching", "assigned", "in-progress"] } })
            ]),

            // 5. Financial Statistics
            Transaction.aggregate([
                {
                    $facet: {
                        today: [
                            { $match: { createdAt: { $gte: startOfToday }, status: "completed" } },
                            {
                                $group: {
                                    _id: null,
                                    revenue: { $sum: { $cond: [{ $eq: ["$type", "booking_payment"] }, "$amount", 0] } },
                                    refunds: { $sum: { $cond: [{ $eq: ["$type", "refund"] }, "$amount", 0] } },
                                    platformFees: { $sum: { $cond: [{ $eq: ["$type", "platform_fee"] }, "$amount", 0] } }
                                }
                            }
                        ],
                        thisMonth: [
                            { $match: { createdAt: { $gte: startOfMonth }, status: "completed" } },
                            {
                                $group: {
                                    _id: null,
                                    revenue: { $sum: { $cond: [{ $eq: ["$type", "booking_payment"] }, "$amount", 0] } },
                                    refunds: { $sum: { $cond: [{ $eq: ["$type", "refund"] }, "$amount", 0] } },
                                    platformFees: { $sum: { $cond: [{ $eq: ["$type", "platform_fee"] }, "$amount", 0] } },
                                    withdrawals: { $sum: { $cond: [{ $eq: ["$type", "withdrawal"] }, "$amount", 0] } }
                                }
                            }
                        ],
                        pendingWithdrawals: [
                            { $match: { type: "withdrawal", status: "pending" } },
                            { $group: { _id: null, total: { $sum: "$amount" }, count: { $sum: 1 } } }
                        ]
                    }
                }
            ]),

            // 6. Provider Availability
            Promise.all([
                Nurse.countDocuments({ isOnline: true, verificationStatus: "approved" }),
                Nurse.countDocuments({ verificationStatus: "approved" }),
                Doctor.countDocuments({ verificationStatus: "approved" })
            ]),

            // 7. Recent Bookings (last 10)
            Booking.find()
                .sort({ createdAt: -1 })
                .limit(10)
                .select("serviceName status type createdAt patientName")
                .lean(),

            // 8. Top Performing Nurses
            Nurse.find({ verificationStatus: "approved" })
                .sort({ rating: -1, completedVisits: -1 })
                .limit(5)
                .populate("user", "name")
                .select("rating completedVisits completionRate")
                .lean()
        ]);

        // Format the response
        const insights = {
            timestamp: new Date().toISOString(),

            // User Overview
            users: {
                total: userStats.reduce((acc, s) => acc + s.total, 0),
                byRole: userStats.reduce((acc, s) => {
                    acc[s._id] = {
                        total: s.total,
                        verified: s.verified,
                        pending: s.pending,
                        approved: s.approved,
                        online: s.online
                    };
                    return acc;
                }, {})
            },

            // Pending Verifications (Action Required)
            pendingVerifications: {
                total: pendingVerifications.reduce((a, b) => a + b, 0),
                users: pendingVerifications[0],
                nurses: pendingVerifications[1],
                doctors: pendingVerifications[2],
                dependents: pendingVerifications[3],
                clinics: pendingVerifications[4]
            },

            // Booking Statistics
            bookings: {
                total: bookingStats[0]?.overall[0]?.total || 0,
                completed: bookingStats[0]?.overall[0]?.completed || 0,
                cancelled: bookingStats[0]?.overall[0]?.cancelled || 0,
                noShow: bookingStats[0]?.overall[0]?.noShow || 0,
                avgRating: Math.round((bookingStats[0]?.overall[0]?.avgRating || 0) * 10) / 10,
                byStatus: bookingStats[0]?.byStatus.reduce((acc, s) => {
                    acc[s._id] = s.count;
                    return acc;
                }, {}),
                byType: bookingStats[0]?.byType.reduce((acc, s) => {
                    acc[s._id] = s.count;
                    return acc;
                }, {})
            },

            // Today's Activity
            today: {
                newBookings: todayActivity[0],
                completedBookings: todayActivity[1],
                newRegistrations: todayActivity[2],
                activeBookings: todayActivity[3]
            },

            // Financial Overview
            financial: {
                today: {
                    revenue: financialStats[0]?.today[0]?.revenue || 0,
                    refunds: financialStats[0]?.today[0]?.refunds || 0,
                    platformFees: financialStats[0]?.today[0]?.platformFees || 0
                },
                thisMonth: {
                    revenue: financialStats[0]?.thisMonth[0]?.revenue || 0,
                    refunds: financialStats[0]?.thisMonth[0]?.refunds || 0,
                    platformFees: financialStats[0]?.thisMonth[0]?.platformFees || 0,
                    withdrawals: financialStats[0]?.thisMonth[0]?.withdrawals || 0
                },
                pendingWithdrawals: {
                    amount: financialStats[0]?.pendingWithdrawals[0]?.total || 0,
                    count: financialStats[0]?.pendingWithdrawals[0]?.count || 0
                }
            },

            // Provider Availability
            providers: {
                nurses: {
                    online: providerAvailability[0],
                    total: providerAvailability[1]
                },
                doctors: {
                    total: providerAvailability[2]
                }
            },

            // Recent Activity
            recentBookings: recentBookings.map(b => ({
                id: b._id,
                service: b.serviceName,
                patient: b.patientName,
                status: b.status,
                type: b.type,
                createdAt: b.createdAt
            })),

            // Top Performers
            topNurses: topNurses.map(n => ({
                id: n._id,
                name: n.user?.name || "Unknown",
                rating: n.rating,
                completedVisits: n.completedVisits,
                completionRate: n.completionRate
            }))
        };

        res.status(200).json({
            success: true,
            data: insights
        });

    } catch (error) {
        console.error("Dashboard insights error:", error);
        res.status(500).json({
            success: false,
            message: "Error fetching dashboard insights",
            error: error.message
        });
    }
};

/**
 * @desc    Get detailed user statistics with trends
 * @route   GET /api/admin/insights/users
 * @access  Private (Admin only)
 */
const getUserInsights = async (req, res) => {
    try {
        const { period = "week" } = req.query;

        let startDate;
        const now = new Date();

        switch (period) {
            case "day":
                startDate = new Date(now.setHours(0, 0, 0, 0));
                break;
            case "week":
                startDate = new Date(now.setDate(now.getDate() - 7));
                break;
            case "month":
                startDate = new Date(now.setMonth(now.getMonth() - 1));
                break;
            default:
                startDate = new Date(now.setDate(now.getDate() - 7));
        }

        const [registrationTrend, roleDistribution, verificationStats] = await Promise.all([
            // Registration trend
            User.aggregate([
                { $match: { createdAt: { $gte: startDate } } },
                {
                    $group: {
                        _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
                        count: { $sum: 1 }
                    }
                },
                { $sort: { _id: 1 } }
            ]),

            // Role distribution
            User.aggregate([
                { $group: { _id: "$role", count: { $sum: 1 } } }
            ]),

            // Verification funnel
            User.aggregate([
                {
                    $group: {
                        _id: "$verificationStatus",
                        count: { $sum: 1 }
                    }
                }
            ])
        ]);

        res.status(200).json({
            success: true,
            data: {
                period,
                registrationTrend,
                roleDistribution: roleDistribution.reduce((acc, r) => {
                    acc[r._id] = r.count;
                    return acc;
                }, {}),
                verificationFunnel: verificationStats.reduce((acc, v) => {
                    acc[v._id] = v.count;
                    return acc;
                }, {})
            }
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Error fetching user insights",
            error: error.message
        });
    }
};

/**
 * @desc    Get booking analytics
 * @route   GET /api/admin/insights/bookings
 * @access  Private (Admin only)
 */
const getBookingInsights = async (req, res) => {
    try {
        const { period = "week" } = req.query;

        let startDate;
        const now = new Date();

        switch (period) {
            case "day":
                startDate = new Date(now.setHours(0, 0, 0, 0));
                break;
            case "week":
                startDate = new Date(now.setDate(now.getDate() - 7));
                break;
            case "month":
                startDate = new Date(now.setMonth(now.getMonth() - 1));
                break;
            default:
                startDate = new Date(now.setDate(now.getDate() - 7));
        }

        const [bookingTrend, cancellationAnalysis, servicePopularity, avgMetrics] = await Promise.all([
            // Booking trend over time
            Booking.aggregate([
                { $match: { createdAt: { $gte: startDate } } },
                {
                    $group: {
                        _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
                        total: { $sum: 1 },
                        completed: { $sum: { $cond: [{ $eq: ["$status", "completed"] }, 1, 0] } },
                        cancelled: { $sum: { $cond: [{ $eq: ["$status", "cancelled"] }, 1, 0] } }
                    }
                },
                { $sort: { _id: 1 } }
            ]),

            // Cancellation analysis
            Booking.aggregate([
                { $match: { status: "cancelled", createdAt: { $gte: startDate } } },
                {
                    $group: {
                        _id: "$cancelledBy",
                        count: { $sum: 1 },
                        totalFees: { $sum: "$cancellationFee" },
                        totalRefunds: { $sum: "$refundAmount" }
                    }
                }
            ]),

            // Most popular services
            Booking.aggregate([
                { $match: { createdAt: { $gte: startDate } } },
                {
                    $group: {
                        _id: "$serviceName",
                        bookings: { $sum: 1 },
                        revenue: { $sum: "$totalAmount" },
                        avgRating: { $avg: "$customerRating" }
                    }
                },
                { $sort: { bookings: -1 } },
                { $limit: 10 }
            ]),

            // Average metrics
            Booking.aggregate([
                { $match: { status: "completed", createdAt: { $gte: startDate } } },
                {
                    $group: {
                        _id: null,
                        avgResponseTime: { $avg: "$nurseResponseTime" },
                        avgServicePrice: { $avg: "$servicePrice" },
                        avgRating: { $avg: "$customerRating" }
                    }
                }
            ])
        ]);

        res.status(200).json({
            success: true,
            data: {
                period,
                bookingTrend,
                cancellationAnalysis: cancellationAnalysis.reduce((acc, c) => {
                    acc[c._id || "unknown"] = {
                        count: c.count,
                        totalFees: c.totalFees,
                        totalRefunds: c.totalRefunds
                    };
                    return acc;
                }, {}),
                topServices: servicePopularity,
                averages: {
                    responseTimeSeconds: Math.round(avgMetrics[0]?.avgResponseTime || 0),
                    servicePrice: Math.round(avgMetrics[0]?.avgServicePrice || 0),
                    rating: Math.round((avgMetrics[0]?.avgRating || 0) * 10) / 10
                }
            }
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Error fetching booking insights",
            error: error.message
        });
    }
};

/**
 * @desc    Get financial analytics
 * @route   GET /api/admin/insights/financial
 * @access  Private (Admin only)
 */
const getFinancialInsights = async (req, res) => {
    try {
        const { period = "month" } = req.query;

        let startDate;
        const now = new Date();

        switch (period) {
            case "week":
                startDate = new Date(now.setDate(now.getDate() - 7));
                break;
            case "month":
                startDate = new Date(now.setMonth(now.getMonth() - 1));
                break;
            case "year":
                startDate = new Date(now.setFullYear(now.getFullYear() - 1));
                break;
            default:
                startDate = new Date(now.setMonth(now.getMonth() - 1));
        }

        const [revenueTrend, transactionBreakdown, nursePayouts] = await Promise.all([
            // Revenue trend
            Transaction.aggregate([
                {
                    $match: {
                        createdAt: { $gte: startDate },
                        status: "completed",
                        type: "booking_payment"
                    }
                },
                {
                    $group: {
                        _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
                        revenue: { $sum: "$amount" },
                        count: { $sum: 1 }
                    }
                },
                { $sort: { _id: 1 } }
            ]),

            // Transaction breakdown by type
            Transaction.aggregate([
                { $match: { createdAt: { $gte: startDate }, status: "completed" } },
                {
                    $group: {
                        _id: "$type",
                        total: { $sum: "$amount" },
                        count: { $sum: 1 }
                    }
                }
            ]),

            // Top nurse earnings
            Nurse.find({ verificationStatus: "approved" })
                .sort({ totalEarnings: -1 })
                .limit(10)
                .populate("user", "name")
                .select("totalEarnings availableBalance pendingBalance completedVisits")
                .lean()
        ]);

        res.status(200).json({
            success: true,
            data: {
                period,
                revenueTrend,
                transactionBreakdown: transactionBreakdown.reduce((acc, t) => {
                    acc[t._id] = { total: t.total, count: t.count };
                    return acc;
                }, {}),
                topEarners: nursePayouts.map(n => ({
                    id: n._id,
                    name: n.user?.name || "Unknown",
                    totalEarnings: n.totalEarnings,
                    availableBalance: n.availableBalance,
                    pendingBalance: n.pendingBalance,
                    completedVisits: n.completedVisits
                }))
            }
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Error fetching financial insights",
            error: error.message
        });
    }
};

/**
 * @desc    Get all users (with optional filtering)
 * @route   GET /api/admin/insights/all-users
 * @access  Private (Admin only)
 */
const getAllUsers = async (req, res) => {
    try {
        const { role, status, search } = req.query;

        const query = {};

        // Filter by role
        if (role && role !== 'all') {
            query.role = role;
        }

        // Filter by status
        if (status && status !== 'all') {
            query.status = status;
        }

        // Search by name, email, or mobile
        if (search) {
            query.$or = [
                { name: { $regex: search, $options: 'i' } },
                { email: { $regex: search, $options: 'i' } },
                { mobile: { $regex: search, $options: 'i' } }
            ];
        }

        const users = await User.find(query)
            .select('-password_hash -salt -hashingAlgorithm -costFactor') // Exclude sensitive data
            .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: users.length,
            users: users
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Error fetching users",
            error: error.message
        });
    }
};

/**
 * @desc    Get system audit logs
 * @route   GET /api/admin/insights/logs
 * @access  Private (Admin only)
 */
const getAuditLogs = async (req, res) => {
    try {
        const { limit = 50, skip = 0 } = req.query;

        const logs = await AuditLog.find()
            .populate('performedBy', 'name email')
            .sort({ timestamp: -1 })
            .limit(parseInt(limit))
            .skip(parseInt(skip));

        const total = await AuditLog.countDocuments();

        res.status(200).json({
            success: true,
            count: logs.length,
            total,
            logs
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Error fetching audit logs",
            error: error.message
        });
    }
};

module.exports = {
    getDashboardInsights,
    getUserInsights,
    getBookingInsights,
    getFinancialInsights,
    getAllUsers,
    getAuditLogs
};
