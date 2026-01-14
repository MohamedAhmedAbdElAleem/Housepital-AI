
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
        const doctor = await Doctor.findOne({ user: req.user.id }).populate("user", "name email phone profilePictureUrl");

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

        // Update User Profile Picture if provided
        if (req.body.profilePictureUrl) {
            await User.findByIdAndUpdate(req.user.id, {
                profilePictureUrl: req.body.profilePictureUrl
            });
        }

        // Note: License number usually shouldn't be changed easily after verification
        // If we want to allow it, we should reset verificationStatus
        if (req.body.licenseNumber && req.body.licenseNumber !== doctor.licenseNumber) {
            doctor.licenseNumber = req.body.licenseNumber;
            doctor.verificationStatus = 'pending'; // Reset verification
        }

        await doctor.save();

        // Return updated document with populated user info including new picture
        const updatedDoctor = await Doctor.findOne({ user: req.user.id }).populate("user", "name email phone profilePictureUrl");

        res.json({
            success: true,
            data: updatedDoctor
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};


// @desc    Get all doctors (Public with filters)
// @route   GET /api/doctors
// @access  Public
const getAllDoctors = async (req, res) => {
    try {
        const { specialization, name, clinicArea } = req.query;
        let query = { verificationStatus: 'approved' }; // Only approved doctors

        if (specialization) {
            query.specialization = specialization;
        }

        // Search by name (via User populate? Complex in Mongoose without aggregate, 
        // essentially we find Users first or use aggregate. 
        // For simplicity let's stick to filters on Doctor model fields first or basic implementation)
        
        // If searching by Name, we might need to find Users first
        if (name) {
             const userIdList = await User.find({ 
                 name: { $regex: name, $options: 'i' }, 
                 role: 'doctor' 
             }).distinct('_id');
             query.user = { $in: userIdList };
        }

        const doctors = await Doctor.find(query)
            .populate("user", "name email phone profilePictureUrl")
            .populate("user", "name email phone profilePictureUrl");
            
        // Note: Doctor model defines `clinics` in previous steps? 
        // No, Service has clinics. Doctor has ONE clinicAddress (legacy) or we find clinics by doctorId.
        // Let's just return doctor profile for now.
        
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

// @desc    Get doctor details
// @route   GET /api/doctors/:id
// @access  Public
const getDoctorDetails = async (req, res) => {
    try {
        const doctor = await Doctor.findById(req.params.id)
            .populate("user", "name email phone profilePictureUrl");

        if (!doctor) {
            return res.status(404).json({ message: "Doctor not found" });
        }
        
        // Fetch clinics for this doctor
        // Assuming Clinic model has `doctor: doctorId` or we find clinics where doctor works?
        // In ClinicController we added `addClinic` linking to `req.user.id`. 
        // So Clinic Model has `doctor` field.
        const Clinic = require("../models/Clinic");
        const clinics = await Clinic.find({ doctor: doctor._id }); // Clinic links to Doctor ID

        // Fetch services
        const Service = require("../models/Service");
        const services = await Service.find({ providerId: doctor._id, providerModel: 'Doctor' });

        res.json({
            success: true,
            data: {
                ...doctor.toObject(),
                clinics,
                services
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

module.exports = {
    createProfile,
    getProfile,
    updateProfile,
    getAllDoctors,
    getDoctorDetails
};
