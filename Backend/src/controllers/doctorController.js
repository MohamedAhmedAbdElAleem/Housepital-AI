
const Doctor = require("../models/Doctor");
const User = require("../models/User");
const walletService = require("../services/walletService");
const emailService = require("../services/emailService");

// @desc    Create doctor profile
// @route   POST /api/doctors/profile
// @access  Private (Doctor only)
const createProfile = async (req, res) => {
    try {
        const userId = req.user.id;

        // Check if user exists and is a doctor
        const user = await User.findById(userId);
        if (!user || user.role !== 'doctor') {
            return res.status(403).json({ message: "Access denied. User is not a doctor." });
        }

        // Check if profile already exists
        let doctor = await Doctor.findOne({ user: userId });
        if (doctor) {
            return res.status(400).json({ message: "Doctor profile already exists" });
        }

        // Create profile
        const {
            licenseNumber,
            specialization,
            yearsOfExperience,
            qualifications,
            bio,
            gender,
            nationalIdUrl,
            licenseUrl,
            degreeCertificateUrl,
            syndicateCardUrl
        } = req.body;

        doctor = new Doctor({
            user: userId,
            licenseNumber,
            specialization,
            yearsOfExperience,
            qualifications,
            bio,
            gender,
            nationalIdUrl,
            licenseUrl,
            degreeCertificateUrl,
            syndicateCardUrl,
            verificationStatus: 'pending',
            isActive: false
        });

        await doctor.save();

        res.status(201).json({
            success: true,
            data: doctor
        });
    } catch (error) {
        console.error(error);
        if (error.code === 11000) {
            return res.status(400).json({ message: "License number already registered" });
        }
        res.status(500).json({ message: "Server Error", error: error.message });
    }
};

// @desc    Get current doctor profile
// @route   GET /api/doctors/profile
// @access  Private
const getProfile = async (req, res) => {
    try {
        const doctor = await Doctor.findOne({ user: req.user.id })
            .populate("user", "name email phone wallet walletBlocked status");

        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found" });
        }

        res.json({
            success: true,
            data: doctor
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

// @desc    Update doctor profile
// @route   PUT /api/doctors/profile
// @access  Private
const updateProfile = async (req, res) => {
    try {
        let doctor = await Doctor.findOne({ user: req.user.id });

        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found" });
        }

        // Fields to update
        const fieldsToUpdate = [
            "specialization",
            "yearsOfExperience",
            "qualifications",
            "bio",
            "gender",
            "nationalIdUrl",
            "licenseUrl",
            "degreeCertificateUrl",
            "syndicateCardUrl",
            "bookingMode",
            "minAdvanceBookingHours",
            "rushBookingEnabled",
            "rushBookingPremiumPercent"
        ];

        fieldsToUpdate.forEach((field) => {
            if (req.body[field] !== undefined) {
                doctor[field] = req.body[field];
            }
        });

        // If license number changes, reset verification
        if (req.body.licenseNumber && req.body.licenseNumber !== doctor.licenseNumber) {
            doctor.licenseNumber = req.body.licenseNumber;
            doctor.verificationStatus = 'pending';
            doctor.isActive = false;
        }

        // If rejected doctor re-submits, reset to pending
        if (doctor.verificationStatus === 'rejected') {
            // Check if any document was updated
            const docFields = ['nationalIdUrl', 'licenseUrl', 'degreeCertificateUrl', 'syndicateCardUrl'];
            const hasDocUpdate = docFields.some(f => req.body[f] !== undefined);
            if (hasDocUpdate) {
                doctor.verificationStatus = 'pending';
                doctor.rejectionReason = null;
                doctor.isActive = false;
            }
        }

        await doctor.save();

        res.json({
            success: true,
            data: doctor
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

// @desc    Toggle doctor active status (for receiving bookings)
// @route   PUT /api/doctors/toggle-active
// @access  Private (Doctor only)
const toggleActive = async (req, res) => {
    try {
        const userId = req.user.id;

        const doctor = await Doctor.findOne({ user: userId });
        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found" });
        }

        // Only approved doctors can toggle active
        if (doctor.verificationStatus !== 'approved') {
            return res.status(403).json({
                message: "Your account must be approved by admin before you can go active."
            });
        }

        const wantActive = req.body.isActive;

        if (wantActive === true) {
            // Check wallet balance
            const walletData = await walletService.getWalletBalance(userId);
            if (walletData.balance < walletService.WALLET_THRESHOLD) {
                return res.status(403).json({
                    success: false,
                    message: `Your wallet balance (${walletData.balance} EGP) is below the minimum threshold of ${walletService.WALLET_THRESHOLD} EGP. Please recharge your wallet to go active.`,
                    walletBalance: walletData.balance,
                    threshold: walletService.WALLET_THRESHOLD
                });
            }
        }

        doctor.isActive = wantActive;
        await doctor.save();

        res.json({
            success: true,
            data: { isActive: doctor.isActive },
            message: doctor.isActive
                ? "You are now active and can receive bookings."
                : "You are now inactive. You will not receive new bookings."
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error", error: error.message });
    }
};

// @desc    Get all pending doctors (for admin review)
// @route   GET /api/doctors/pending
// @access  Private (Admin only)
const getPendingDoctors = async (req, res) => {
    try {
        if (req.user.role !== 'admin') {
            return res.status(403).json({ message: "Admin access only" });
        }

        const status = req.query.status || 'pending';
        const filter = {};
        if (status !== 'all') {
            filter.verificationStatus = status;
        }

        const doctors = await Doctor.find(filter)
            .populate("user", "name email mobile profilePictureUrl createdAt")
            .sort({ createdAt: -1 });

        res.json({
            success: true,
            count: doctors.length,
            data: doctors
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

// @desc    Approve or reject a doctor
// @route   PUT /api/doctors/:doctorId/verify
// @access  Private (Admin only)
const verifyDoctor = async (req, res) => {
    try {
        if (req.user.role !== 'admin') {
            return res.status(403).json({ message: "Admin access only" });
        }

        const { doctorId } = req.params;
        const { action, rejectionReason } = req.body; // action: 'approve' or 'reject'

        if (!['approve', 'reject'].includes(action)) {
            return res.status(400).json({ message: "Action must be 'approve' or 'reject'" });
        }

        const doctor = await Doctor.findById(doctorId).populate("user", "name email");
        if (!doctor) {
            return res.status(404).json({ message: "Doctor not found" });
        }

        if (action === 'approve') {
            doctor.verificationStatus = 'approved';
            doctor.rejectionReason = null;
            doctor.verifiedBy = req.user.id;
            doctor.verifiedAt = new Date();
            await doctor.save();

            // Send approval email
            if (doctor.user?.email) {
                await emailService.sendApprovalEmail(doctor.user.email, doctor.user.name);
            }

            res.json({
                success: true,
                message: `Dr. ${doctor.user?.name || 'Unknown'} has been approved.`,
                data: doctor
            });
        } else {
            // Reject
            if (!rejectionReason || rejectionReason.trim() === '') {
                return res.status(400).json({ message: "Rejection reason is required" });
            }

            doctor.verificationStatus = 'rejected';
            doctor.rejectionReason = rejectionReason;
            doctor.isActive = false;
            doctor.verifiedBy = req.user.id;
            doctor.verifiedAt = new Date();
            await doctor.save();

            // Send rejection email
            if (doctor.user?.email) {
                await emailService.sendRejectionEmail(doctor.user.email, doctor.user.name, rejectionReason);
            }

            res.json({
                success: true,
                message: `Dr. ${doctor.user?.name || 'Unknown'} has been rejected.`,
                data: doctor
            });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error", error: error.message });
    }
};

module.exports = {
    createProfile,
    getProfile,
    updateProfile,
    toggleActive,
    getPendingDoctors,
    verifyDoctor
};
