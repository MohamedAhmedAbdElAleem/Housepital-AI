
const Clinic = require("../models/Clinic");
const Doctor = require("../models/Doctor");

// @desc    Add new clinic
// @route   POST /api/clinics
// @access  Private (Doctor only)
const addClinic = async (req, res) => {
    try {
        const userId = req.user.id;
        
        // Find doctor profile associated with user
        const doctor = await Doctor.findOne({ user: userId });
        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found. Please create a profile first." });
        }

        const {
            name,
            description,
            address, // { street, area, city, state, zipCode, landmark }
            location, // { type: "Point", coordinates: [long, lat] }
            phone,
            images,
            workingHours,
            slotDurationMinutes,
            maxPatientsPerSlot,
            bookingMode, // New
            verificationDocuments // New
        } = req.body;

        const clinic = new Clinic({
            doctor: doctor._id,
            name,
            description,
            address,
            location,
            phone,
            images,
            workingHours,
            slotDurationMinutes,
            maxPatientsPerSlot,
            bookingMode,
            verificationDocuments
        });

        await clinic.save();

        res.status(201).json({
            success: true,
            data: clinic
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error", error: error.message });
    }
};

// @desc    Get all clinics for current doctor
// @route   GET /api/clinics/my-clinics
// @access  Private (Doctor only)
const getMyClinics = async (req, res) => {
    try {
        const userId = req.user.id;
        
        const doctor = await Doctor.findOne({ user: userId });
        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found" });
        }

        const clinics = await Clinic.find({ doctor: doctor._id, isActive: true }).sort({ createdAt: -1 });

        res.json({
            success: true,
            count: clinics.length,
            data: clinics
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

// @desc    Update clinic
// @route   PUT /api/clinics/:id
// @access  Private (Doctor only)
const updateClinic = async (req, res) => {
    try {
        const userId = req.user.id;
        const clinicId = req.params.id;

        const doctor = await Doctor.findOne({ user: userId });
        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found" });
        }

        let clinic = await Clinic.findById(clinicId);

        if (!clinic) {
            return res.status(404).json({ message: "Clinic not found" });
        }

        // Verify ownership
        if (clinic.doctor.toString() !== doctor._id.toString()) {
            return res.status(403).json({ message: "Not authorized to update this clinic" });
        }

        const allowedUpdates = [
            "name", "description", "address", "location", "phone", 
            "images", "workingHours", "slotDurationMinutes", 
            "maxPatientsPerSlot", "bookingMode", "verificationDocuments", "isActive"
        ];

        allowedUpdates.forEach((field) => {
            if (req.body[field] !== undefined) {
                clinic[field] = req.body[field];
            }
        });

        // If updating critical info, maybe reset verification?
        // keeping it simple for now

        await clinic.save();

        res.json({
            success: true,
            data: clinic
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

// @desc    Delete clinic (soft delete)
// @route   DELETE /api/clinics/:id
// @access  Private (Doctor only)
const deleteClinic = async (req, res) => {
    try {
        const userId = req.user.id;
        const clinicId = req.params.id;

        const doctor = await Doctor.findOne({ user: userId });
        if (!doctor) {
            return res.status(404).json({ message: "Doctor profile not found" });
        }

        let clinic = await Clinic.findById(clinicId);

        if (!clinic) {
            return res.status(404).json({ message: "Clinic not found" });
        }

        if (clinic.doctor.toString() !== doctor._id.toString()) {
            return res.status(403).json({ message: "Not authorized to delete this clinic" });
        }

        // Soft delete
        clinic.isActive = false;
        await clinic.save();

        res.json({ success: true, message: "Clinic deactivated successfully" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error" });
    }
};

module.exports = {
    addClinic,
    getMyClinics,
    updateClinic,
    deleteClinic
};
