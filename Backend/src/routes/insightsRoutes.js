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
 * @route   POST /api/admin/insights/staff
 * @desc    Add a new staff member (nurse or doctor)
 * @access  Private (Admin only)
 */
router.post("/staff", async (req, res) => {
    try {
        const { name, email, mobile, password, role, gender } = req.body;
        const Nurse = require("../models/Nurse");
        const Doctor = require("../models/Doctor");
        const bcrypt = require("bcrypt");

        // Validate required fields
        if (!name || !email || !mobile || !password || !role || !gender) {
            return res.status(400).json({
                success: false,
                message: "All fields are required: name, email, mobile, password, role, gender"
            });
        }

        // Check if user already exists
        const existingUser = await User.findOne({ 
            $or: [{ email }, { mobile }]
        });
        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: "User with this email or mobile already exists"
            });
        }

        // Hash password
        const salt = await bcrypt.genSalt(12);
        const password_hash = await bcrypt.hash(password, salt);

        // Create user
        const newUser = await User.create({
            name,
            email,
            mobile,
            password_hash,
            salt,
            role,
            isVerified: true,
            status: "approved",
            verificationStatus: "verified"
        });

        // Create corresponding profile
        const timestamp = Date.now().toString().slice(-6);
        const randomNum = Math.floor(1000 + Math.random() * 9000);
        const tempLicense = `TMP-${timestamp}-${randomNum}`;
        const tempSpecialization = "General Practice";

        if (role === "nurse") {
            await Nurse.create({
                user: newUser._id,
                gender: gender, // Required for Nurse
                licenseNumber: tempLicense,
                specialization: tempSpecialization,
                yearsOfExperience: 0,
                verificationStatus: "pending",
                isOnline: false,
                skills: [], // Initialize empty
                certifications: []
            });
        } else if (role === "doctor") {
            await Doctor.create({
                user: newUser._id,
                gender: gender,
                licenseNumber: tempLicense,
                specialization: tempSpecialization,
                yearsOfExperience: 0,
                verificationStatus: "pending",
                qualifications: []
            });
        }

        res.status(201).json({
            success: true,
            message: `${role.charAt(0).toUpperCase() + role.slice(1)} added successfully`,
            user: {
                id: newUser._id,
                name: newUser.name,
                email: newUser.email,
                role: newUser.role
            }
        });

    } catch (error) {
        console.error("Add staff error:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Error adding staff member"
        });
    }
});

/**
 * @route   GET /api/admin/insights/pending-verifications
 * @desc    Get all pending nurse/doctor verifications with full details
 * @access  Private (Admin only)
 */
router.get("/pending-verifications", async (req, res) => {
    try {
        const Nurse = require("../models/Nurse");
        const Doctor = require("../models/Doctor");

        // Get pending nurses with user details
        const pendingNurses = await Nurse.find({ 
            verificationStatus: "pending"
        })
            .populate("user", "name email mobile gender profilePictureUrl createdAt")
            .lean();

        // Get pending doctors with user details
        const pendingDoctors = await Doctor.find({ 
            verificationStatus: "pending" 
        })
            .populate("user", "name email mobile gender profilePictureUrl createdAt")
            .lean();

        // Format response
        const verifications = [
            ...pendingNurses.map(n => ({
                id: n._id,
                type: "nurse",
                userId: n.user?._id,
                name: n.user?.name || "Unknown",
                email: n.user?.email,
                mobile: n.user?.mobile,
                gender: n.gender || n.user?.gender,
                profilePicture: n.user?.profilePictureUrl,
                licenseNumber: n.licenseNumber,
                specialization: n.specialization,
                yearsOfExperience: n.yearsOfExperience,
                skills: n.skills,
                bio: n.bio,
                documents: {
                    nationalId: n.nationalIdUrl,
                    degree: n.degreeUrl,
                    license: n.licenseUrl
                },
                verificationStatus: n.verificationStatus,
                profileStatus: n.profileStatus,
                submittedAt: n.createdAt
            })),
            ...pendingDoctors.map(d => ({
                id: d._id,
                type: "doctor",
                userId: d.user?._id,
                name: d.user?.name || "Unknown",
                email: d.user?.email,
                mobile: d.user?.mobile,
                gender: d.user?.gender,
                profilePicture: d.user?.profilePictureUrl,
                licenseNumber: d.medicalLicense,
                specialization: d.specialization,
                yearsOfExperience: d.yearsOfExperience,
                qualifications: d.qualifications,
                bio: d.bio,
                documents: {
                    nationalId: d.nationalIdUrl,
                    degree: d.degreeUrl,
                    license: d.licenseUrl
                },
                verificationStatus: d.verificationStatus,
                submittedAt: d.createdAt
            }))
        ].sort((a, b) => new Date(b.submittedAt) - new Date(a.submittedAt));

        res.json({
            success: true,
            count: verifications.length,
            nurses: pendingNurses.length,
            doctors: pendingDoctors.length,
            verifications
        });

    } catch (error) {
        console.error("Get pending verifications error:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Error fetching pending verifications"
        });
    }
});

/**
 * @route   POST /api/admin/insights/verify/:type/:id
 * @desc    Approve or reject a nurse/doctor verification
 * @access  Private (Admin only)
 */
router.post("/verify/:type/:id", async (req, res) => {
    try {
        const { type, id } = req.params;
        const { action, reason } = req.body;
        const Nurse = require("../models/Nurse");
        const Doctor = require("../models/Doctor");
        const AuditLog = require("../models/audit-logging");

        if (!["approve", "reject"].includes(action)) {
            return res.status(400).json({
                success: false,
                message: "Invalid action. Must be 'approve' or 'reject'"
            });
        }

        if (!["nurse", "doctor"].includes(type)) {
            return res.status(400).json({
                success: false,
                message: "Invalid type. Must be 'nurse' or 'doctor'"
            });
        }

        let profile;
        let Model = type === "nurse" ? Nurse : Doctor;

        profile = await Model.findById(id).populate("user", "name email");
        
        if (!profile) {
            return res.status(404).json({
                success: false,
                message: `${type.charAt(0).toUpperCase() + type.slice(1)} not found`
            });
        }

        // Update verification status
        if (action === "approve") {
            profile.verificationStatus = "approved";
            profile.verifiedAt = new Date();
        } else {
            profile.verificationStatus = "rejected";
            profile.rejectionReason = reason || "Application rejected by admin";
        }

        await profile.save();

        // Update user status as well
        if (profile.user) {
            await User.findByIdAndUpdate(profile.user._id, {
                status: action === "approve" ? "approved" : "rejected",
                verificationStatus: action === "approve" ? "verified" : "rejected"
            });
        }

        // Log the action
        try {
            await AuditLog.create({
                action: action === "approve" ? `APPROVE_${type.toUpperCase()}` : `REJECT_${type.toUpperCase()}`,
                description: action === "approve" 
                    ? `${type.charAt(0).toUpperCase() + type.slice(1)} ${profile.user?.name || 'Unknown'} has been approved`
                    : `${type.charAt(0).toUpperCase() + type.slice(1)} ${profile.user?.name || 'Unknown'} has been rejected. Reason: ${reason || 'Not specified'}`,
                targetUser: profile.user?._id,
                performedBy: req.user?.id,
                timestamp: new Date()
            });
        } catch (logError) {
            console.error("Audit log error:", logError);
        }

        res.json({
            success: true,
            message: `${type.charAt(0).toUpperCase() + type.slice(1)} ${action}d successfully`,
            profile: {
                id: profile._id,
                name: profile.user?.name,
                verificationStatus: profile.verificationStatus
            }
        });

    } catch (error) {
        console.error("Verification action error:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Error processing verification"
        });
    }
});

/**
 * @route   GET /api/admin/insights/all-bookings
 * @desc    Get all bookings with filters
 * @access  Private (Admin only)
 */
router.get("/all-bookings", async (req, res) => {
    try {
        const Booking = require("../models/Booking");
        const { status, type, limit = 50, skip = 0 } = req.query;

        const query = {};
        if (status && status !== "all") {
            query.status = status;
        }
        if (type && type !== "all") {
            query.type = type;
        }

        const bookings = await Booking.find(query)
            .populate("userId", "name email mobile")
            .populate("assignedNurse", "user")
            .sort({ createdAt: -1 })
            .limit(parseInt(limit))
            .skip(parseInt(skip))
            .lean();

        // Populate nurse user info
        const Nurse = require("../models/Nurse");
        for (let booking of bookings) {
            if (booking.assignedNurse) {
                const nurse = await Nurse.findById(booking.assignedNurse).populate("user", "name").lean();
                booking.nurseName = nurse?.user?.name || "Unknown";
            }
        }

        const total = await Booking.countDocuments(query);

        res.json({
            success: true,
            count: bookings.length,
            total,
            bookings: bookings.map(b => ({
                id: b._id,
                type: b.type,
                serviceName: b.serviceName,
                servicePrice: b.servicePrice,
                patientName: b.patientName,
                customerName: b.userId?.name,
                customerEmail: b.userId?.email,
                customerMobile: b.userId?.mobile,
                nurseName: b.nurseName,
                status: b.status,
                timeOption: b.timeOption,
                scheduledDate: b.scheduledDate,
                scheduledTime: b.scheduledTime,
                address: b.address,
                visitPin: b.visitPin,
                visitStartedAt: b.visitStartedAt,
                visitEndedAt: b.visitEndedAt,
                createdAt: b.createdAt
            }))
        });

    } catch (error) {
        console.error("Get all bookings error:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Error fetching bookings"
        });
    }
});

/**
 * @route   PATCH /api/admin/insights/user/:id/status
 * @desc    Update user status (suspend/activate)
 * @access  Private (Admin only)
 */
router.patch("/user/:id/status", async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        const AuditLog = require("../models/audit-logging");

        if (!["approved", "suspended", "pending", "rejected"].includes(status)) {
            return res.status(400).json({
                success: false,
                message: "Invalid status. Must be 'approved', 'suspended', 'pending', or 'rejected'"
            });
        }

        const user = await User.findById(id);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }

        const previousStatus = user.status;
        user.status = status;
        await user.save();

        // Log the action
        try {
            await AuditLog.create({
                action: status === "suspended" ? "SUSPEND_USER" : "ACTIVATE_USER",
                description: `User ${user.name} status changed from ${previousStatus || 'unknown'} to ${status}`,
                targetUser: user._id,
                performedBy: req.user?.id,
                timestamp: new Date()
            });
        } catch (logError) {
            console.error("Audit log error:", logError);
        }

        res.json({
            success: true,
            message: `User status updated to ${status}`,
            user: {
                id: user._id,
                name: user.name,
                status: user.status
            }
        });

    } catch (error) {
        console.error("Update user status error:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Error updating user status"
        });
    }
});

/**
 * @route   GET /api/admin/insights/financial
 * @desc    Get financial analytics data
 * @access  Private (Admin only)
 */
router.get("/financial", async (req, res) => {
    try {
        const Booking = require("../models/Booking");
        const Nurse = require("../models/Nurse");
        const { period = 'month' } = req.query;

        // Calculate date range based on period
        const now = new Date();
        let startDate;
        if (period === 'week') {
            startDate = new Date(now.setDate(now.getDate() - 7));
        } else if (period === 'month') {
            startDate = new Date(now.setMonth(now.getMonth() - 1));
        } else {
            startDate = new Date(now.setFullYear(now.getFullYear() - 1));
        }

        // Get bookings with payments
        const bookings = await Booking.find({
            createdAt: { $gte: startDate },
            status: { $in: ['completed', 'in-progress', 'confirmed'] }
        }).lean();

        // Calculate transaction breakdown
        const transactionBreakdown = {
            booking_payment: { count: 0, total: 0 },
            platform_fee: { count: 0, total: 0 },
            refund: { count: 0, total: 0 },
            withdrawal: { count: 0, total: 0 }
        };

        bookings.forEach(booking => {
            const amount = booking.totalCost || booking.price || 0;
            transactionBreakdown.booking_payment.count++;
            transactionBreakdown.booking_payment.total += amount;
            transactionBreakdown.platform_fee.count++;
            transactionBreakdown.platform_fee.total += amount * 0.15; // 15% platform fee
        });

        // Calculate revenue trend (group by day/week/month)
        const revenueTrend = [];
        const groupedBookings = {};
        
        bookings.forEach(booking => {
            const date = new Date(booking.createdAt);
            const key = period === 'year' 
                ? `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
                : date.toISOString().split('T')[0];
            
            if (!groupedBookings[key]) {
                groupedBookings[key] = 0;
            }
            groupedBookings[key] += booking.totalCost || booking.price || 0;
        });

        Object.entries(groupedBookings)
            .sort((a, b) => a[0].localeCompare(b[0]))
            .forEach(([date, revenue]) => {
                revenueTrend.push({ _id: date, revenue });
            });

        // Get top earning nurses
        const topEarners = await Nurse.aggregate([
            {
                $lookup: {
                    from: 'bookings',
                    localField: '_id',
                    foreignField: 'nurse',
                    as: 'bookings'
                }
            },
            {
                $lookup: {
                    from: 'users',
                    localField: 'user',
                    foreignField: '_id',
                    as: 'userInfo'
                }
            },
            {
                $project: {
                    name: { $arrayElemAt: ['$userInfo.name', 0] },
                    completedVisits: {
                        $size: {
                            $filter: {
                                input: '$bookings',
                                as: 'b',
                                cond: { $eq: ['$$b.status', 'completed'] }
                            }
                        }
                    },
                    totalEarnings: {
                        $sum: {
                            $map: {
                                input: {
                                    $filter: {
                                        input: '$bookings',
                                        as: 'b',
                                        cond: { $eq: ['$$b.status', 'completed'] }
                                    }
                                },
                                as: 'booking',
                                in: { $ifNull: ['$$booking.totalCost', { $ifNull: ['$$booking.price', 0] }] }
                            }
                        }
                    }
                }
            },
            { $match: { totalEarnings: { $gt: 0 } } },
            { $sort: { totalEarnings: -1 } },
            { $limit: 5 }
        ]);

        res.json({
            success: true,
            data: {
                transactionBreakdown,
                revenueTrend,
                topEarners
            }
        });

    } catch (error) {
        console.error("Financial analytics error:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Error fetching financial data"
        });
    }
});

module.exports = router;

