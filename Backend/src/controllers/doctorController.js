
const Doctor = require("../models/Doctor");
const User = require("../models/User");

// @desc    Create doctor profile
// @route   POST /api/doctors/profile
// @access  Private (Doctor only)
const createProfile = async (req, res) => {
    try {
        const userId = req.user.id; // From authMiddleware

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
            licenseUrl
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
            licenseUrl
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
        const doctor = await Doctor.findOne({ user: req.user.id }).populate("user", "name email phone");

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
            // Option to create if not exists? No, should use createProfile.
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
            // Allow updating booking settings here too?
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

        // Note: License number usually shouldn't be changed easily after verification
        // If we want to allow it, we should reset verificationStatus
        if (req.body.licenseNumber && req.body.licenseNumber !== doctor.licenseNumber) {
            doctor.licenseNumber = req.body.licenseNumber;
            doctor.verificationStatus = 'pending'; // Reset verification
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

module.exports = {
    createProfile,
    getProfile,
    updateProfile
};
