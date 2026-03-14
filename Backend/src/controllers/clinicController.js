const Clinic = require("../models/Clinic");
const Doctor = require("../models/Doctor");

/**
 * Normalise an Egyptian mobile number to the 01XXXXXXXXX format.
 * Accepts: 01012345678 / +201012345678 / 00201012345678
 * Returns null if the value is empty/undefined (phone is optional).
 */
const normalisePhone = (raw) => {
	if (!raw || !raw.trim()) return undefined; // optional field – omit it
	let p = raw.trim().replace(/\s+/g, "");
	if (p.startsWith("+20")) p = "0" + p.slice(3);
	if (p.startsWith("0020")) p = "0" + p.slice(4);
	if (p.startsWith("20") && p.length === 12) p = "0" + p.slice(2);
	return p;
};

// @desc    Add new clinic
// @route   POST /api/clinics
// @access  Private (Doctor only)
const addClinic = async (req, res) => {
	try {
		const userId = req.user.id;

		// Find doctor profile associated with user
		const doctor = await Doctor.findOne({ user: userId });
		if (!doctor) {
			return res.status(404).json({
				message: "Doctor profile not found. Please create a profile first.",
			});
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
		} = req.body;

		const clinic = new Clinic({
			doctor: doctor._id,
			name,
			description,
			address,
			location,
			phone: normalisePhone(phone),
			images,
			workingHours,
			slotDurationMinutes,
			maxPatientsPerSlot,
		});

		await clinic.save();

		res.status(201).json({
			success: true,
			data: clinic,
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

		const clinics = await Clinic.find({ doctor: doctor._id }).sort({
			createdAt: -1,
		});

		res.json({
			success: true,
			count: clinics.length,
			data: clinics,
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
			return res
				.status(403)
				.json({ message: "Not authorized to update this clinic" });
		}

		const allowedUpdates = [
			"name",
			"description",
			"address",
			"location",
			"phone",
			"images",
			"workingHours",
			"slotDurationMinutes",
			"maxPatientsPerSlot",
			"bookingMode",
			"isActive",
		];

		allowedUpdates.forEach((field) => {
			if (req.body[field] !== undefined) {
				clinic[field] =
					field === "phone" ? normalisePhone(req.body[field]) : req.body[field];
			}
		});

		// If updating critical info, maybe reset verification?
		// keeping it simple for now

		await clinic.save();

		res.json({
			success: true,
			data: clinic,
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
			return res
				.status(403)
				.json({ message: "Not authorized to delete this clinic" });
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
	deleteClinic,
	getAllClinicsPublic,
	getClinicByIdPublic,
};

// ── Public (no auth) ──────────────────────────────────────────────────────

// @desc  Get all active clinics (for patient app discovery)
// @route GET /api/clinics/public
// @access Public
async function getAllClinicsPublic(req, res) {
	try {
		const { search, area } = req.query;
		const filter = { isActive: true };
		if (area) filter["address.area"] = new RegExp(area, "i");

		const clinics = await Clinic.find(filter)
			.populate("doctor", "name specialization profilePictureUrl")
			.sort({ createdAt: -1 });

		let result = clinics;
		if (search) {
			const re = new RegExp(search, "i");
			result = clinics.filter(
				(c) =>
					re.test(c.name) ||
					re.test(c.doctor?.name) ||
					re.test(c.address?.area),
			);
		}

		res.json({ success: true, data: result });
	} catch (error) {
		console.error("getAllClinicsPublic error:", error);
		res.status(500).json({ success: false, message: "Server Error" });
	}
}

// @desc  Get single clinic by ID (for patient app)
// @route GET /api/clinics/public/:id
// @access Public
async function getClinicByIdPublic(req, res) {
	try {
		const clinic = await Clinic.findById(req.params.id).populate(
			"doctor",
			"name specialization profilePictureUrl",
		);
		if (!clinic) {
			return res
				.status(404)
				.json({ success: false, message: "Clinic not found" });
		}
		res.json({ success: true, data: clinic });
	} catch (error) {
		console.error("getClinicByIdPublic error:", error);
		res.status(500).json({ success: false, message: "Server Error" });
	}
}
