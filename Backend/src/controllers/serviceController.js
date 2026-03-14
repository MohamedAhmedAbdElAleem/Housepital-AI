const Service = require("../models/Service");
const Doctor = require("../models/Doctor");

// @desc    Get all active services for a specific clinic (public – no auth)
// @route   GET /api/services/public/by-clinic/:clinicId
// @access  Public
const getServicesByClinic = async (req, res) => {
	try {
		const { clinicId } = req.params;
		const services = await Service.find({
			clinics: clinicId,
			isActive: true,
		}).sort({ createdAt: -1 });
		res.json({ success: true, data: services });
	} catch (error) {
		console.error("getServicesByClinic error:", error);
		res.status(500).json({ success: false, message: "Server Error" });
	}
};

// @desc    Get all services for the current doctor
// @route   GET /api/services/my-services
// @access  Private (Doctor only)
const getMyServices = async (req, res) => {
	try {
		const userId = req.user.id;

		const doctor = await Doctor.findOne({ user: userId });
		if (!doctor) {
			return res.status(404).json({
				success: false,
				message: "Doctor profile not found. Please create a profile first.",
			});
		}

		const services = await Service.find({ providerId: doctor._id })
			.populate("clinics", "name address phone")
			.sort({ createdAt: -1 });

		res.json({ success: true, data: services });
	} catch (error) {
		console.error("getMyServices error:", error);
		res
			.status(500)
			.json({ success: false, message: "Server Error", error: error.message });
	}
};

// @desc    Create a new service
// @route   POST /api/services
// @access  Private (Doctor only)
const createService = async (req, res) => {
	try {
		const userId = req.user.id;

		const doctor = await Doctor.findOne({ user: userId });
		if (!doctor) {
			return res.status(404).json({
				success: false,
				message: "Doctor profile not found. Please create a profile first.",
			});
		}

		const {
			name,
			nameAr,
			description,
			descriptionAr,
			type,
			category,
			clinics,
			price,
			currency,
			durationMinutes,
			requiresTools,
			toolsList,
			estimatedToolsDeposit,
			requiresPrescription,
			isActive,
		} = req.body;

		const service = new Service({
			name,
			nameAr,
			description,
			descriptionAr,
			type: type || "clinic",
			category,
			providerId: doctor._id,
			providerModel: "Doctor",
			clinics: clinics || [],
			price,
			currency: currency || "EGP",
			durationMinutes,
			requiresTools: requiresTools || false,
			toolsList: toolsList || [],
			estimatedToolsDeposit: estimatedToolsDeposit || 0,
			requiresPrescription: requiresPrescription || false,
			isActive: isActive !== undefined ? isActive : true,
		});

		await service.save();
		await service.populate("clinics", "name address phone");

		res.status(201).json({ success: true, data: service });
	} catch (error) {
		console.error("createService error:", error);
		res
			.status(500)
			.json({ success: false, message: "Server Error", error: error.message });
	}
};

// @desc    Update a service
// @route   PUT /api/services/:id
// @access  Private (Doctor only — must own the service)
const updateService = async (req, res) => {
	try {
		const userId = req.user.id;

		const doctor = await Doctor.findOne({ user: userId });
		if (!doctor) {
			return res
				.status(404)
				.json({ success: false, message: "Doctor profile not found." });
		}

		const service = await Service.findOne({
			_id: req.params.id,
			providerId: doctor._id,
		});
		if (!service) {
			return res.status(404).json({
				success: false,
				message: "Service not found or access denied.",
			});
		}

		const allowedFields = [
			"name",
			"nameAr",
			"description",
			"descriptionAr",
			"type",
			"category",
			"clinics",
			"price",
			"currency",
			"durationMinutes",
			"requiresTools",
			"toolsList",
			"estimatedToolsDeposit",
			"requiresPrescription",
			"isActive",
		];

		allowedFields.forEach((field) => {
			if (req.body[field] !== undefined) {
				service[field] = req.body[field];
			}
		});

		await service.save();
		await service.populate("clinics", "name address phone");

		res.json({ success: true, data: service });
	} catch (error) {
		console.error("updateService error:", error);
		res
			.status(500)
			.json({ success: false, message: "Server Error", error: error.message });
	}
};

// @desc    Delete a service
// @route   DELETE /api/services/:id
// @access  Private (Doctor only — must own the service)
const deleteService = async (req, res) => {
	try {
		const userId = req.user.id;

		const doctor = await Doctor.findOne({ user: userId });
		if (!doctor) {
			return res
				.status(404)
				.json({ success: false, message: "Doctor profile not found." });
		}

		const service = await Service.findOneAndDelete({
			_id: req.params.id,
			providerId: doctor._id,
		});

		if (!service) {
			return res.status(404).json({
				success: false,
				message: "Service not found or access denied.",
			});
		}

		res.json({ success: true, message: "Service deleted successfully." });
	} catch (error) {
		console.error("deleteService error:", error);
		res
			.status(500)
			.json({ success: false, message: "Server Error", error: error.message });
	}
};

module.exports = {
	getServicesByClinic,
	getMyServices,
	createService,
	updateService,
	deleteService,
};
