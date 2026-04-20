const Service = require("../models/Service");
const Doctor = require("../models/Doctor");
const Nurse = require("../models/Nurse");

const normalizeCategory = (value = "") =>
	String(value)
		.toLowerCase()
		.trim()
		.replace(/[^a-z0-9]+/g, "_")
		.replace(/^_+|_+$/g, "");

// @desc    Get active public home nursing services
// @route   GET /api/services/public/home-nursing
// @access  Public
const getPublicHomeNursingServices = async (req, res) => {
	try {
		const services = await Service.find({
			type: "home_nursing",
			isActive: true,
		})
			.select("_id name nameAr category price durationMinutes currency")
			.sort({ name: 1 });

		res.json({ success: true, data: services });
	} catch (error) {
		console.error("getPublicHomeNursingServices error:", error);
		res
			.status(500)
			.json({ success: false, message: "Server Error", error: error.message });
	}
};

// @desc    Get all home nursing services for admin management
// @route   GET /api/services/admin/home-nursing
// @access  Private (Admin)
const getAdminHomeNursingServices = async (req, res) => {
	try {
		const { isActive, category, search } = req.query;
		const query = { type: "home_nursing" };

		if (isActive === "true" || isActive === "false") {
			query.isActive = isActive === "true";
		}

		if (category) {
			query.category = normalizeCategory(category);
		}

		if (search) {
			const searchRegex = new RegExp(String(search).trim(), "i");
			query.$or = [
				{ name: searchRegex },
				{ nameAr: searchRegex },
				{ category: searchRegex },
			];
		}

		const services = await Service.find(query)
			.populate({
				path: "providerId",
				select: "specialization profileStatus verificationStatus user",
				populate: { path: "user", select: "name email mobile" },
			})
			.sort({ createdAt: -1 });

		res.json({ success: true, count: services.length, data: services });
	} catch (error) {
		console.error("getAdminHomeNursingServices error:", error);
		res
			.status(500)
			.json({ success: false, message: "Server Error", error: error.message });
	}
};

// @desc    Get available nurse providers for home nursing services
// @route   GET /api/services/admin/home-nursing/providers
// @access  Private (Admin)
const getHomeNursingProviders = async (req, res) => {
	try {
		let nurses = await Nurse.find({ profileStatus: "approved" })
			.populate("user", "name email mobile status")
			.select("_id specialization skills verificationStatus profileStatus")
			.sort({ createdAt: -1 });

		if (nurses.length === 0) {
			nurses = await Nurse.find({})
				.populate("user", "name email mobile status")
				.select("_id specialization skills verificationStatus profileStatus")
				.sort({ createdAt: -1 });
		}

		const data = nurses.map((nurse) => ({
			id: nurse._id,
			name: nurse.user?.name || "Nurse",
			email: nurse.user?.email || "",
			mobile: nurse.user?.mobile || "",
			specialization: nurse.specialization || "",
			skills: nurse.skills || [],
			profileStatus: nurse.profileStatus,
			verificationStatus: nurse.verificationStatus,
		}));

		res.json({ success: true, count: data.length, data });
	} catch (error) {
		console.error("getHomeNursingProviders error:", error);
		res
			.status(500)
			.json({ success: false, message: "Server Error", error: error.message });
	}
};

// @desc    Create a home nursing service as admin
// @route   POST /api/services/admin/home-nursing
// @access  Private (Admin)
const createAdminHomeNursingService = async (req, res) => {
	try {
		const {
			name,
			nameAr,
			description,
			descriptionAr,
			category,
			price,
			currency,
			durationMinutes,
			requiresTools,
			toolsList,
			estimatedToolsDeposit,
			requiresPrescription,
			isActive,
			providerId,
		} = req.body;

		if (!name || price == null || durationMinutes == null || !providerId) {
			return res.status(400).json({
				success: false,
				message: "name, price, durationMinutes, and providerId are required",
			});
		}

		const nurse = await Nurse.findById(providerId).select("_id");
		if (!nurse) {
			return res
				.status(404)
				.json({ success: false, message: "Nurse provider not found" });
		}

		const normalizedCategory = normalizeCategory(category || name);
		if (!normalizedCategory) {
			return res
				.status(400)
				.json({ success: false, message: "Invalid category/name format" });
		}

		const duplicate = await Service.findOne({
			type: "home_nursing",
			providerModel: "Nurse",
			providerId,
			category: normalizedCategory,
			isActive: true,
		});

		if (duplicate) {
			return res.status(409).json({
				success: false,
				message: "An active service with the same category already exists for this nurse",
			});
		}

		const service = await Service.create({
			name: String(name).trim(),
			nameAr,
			description,
			descriptionAr,
			type: "home_nursing",
			category: normalizedCategory,
			providerId,
			providerModel: "Nurse",
			price,
			currency: currency || "EGP",
			durationMinutes,
			requiresTools: !!requiresTools,
			toolsList: toolsList || [],
			estimatedToolsDeposit: estimatedToolsDeposit || 0,
			requiresPrescription: !!requiresPrescription,
			isActive: isActive !== undefined ? !!isActive : true,
		});

		await service.populate({
			path: "providerId",
			select: "specialization profileStatus verificationStatus user",
			populate: { path: "user", select: "name email mobile" },
		});

		res.status(201).json({ success: true, data: service });
	} catch (error) {
		console.error("createAdminHomeNursingService error:", error);
		res
			.status(500)
			.json({ success: false, message: "Server Error", error: error.message });
	}
};

// @desc    Update a home nursing service as admin
// @route   PUT /api/services/admin/home-nursing/:id
// @access  Private (Admin)
const updateAdminHomeNursingService = async (req, res) => {
	try {
		const service = await Service.findOne({
			_id: req.params.id,
			type: "home_nursing",
		});

		if (!service) {
			return res
				.status(404)
				.json({ success: false, message: "Home nursing service not found" });
		}

		const allowedFields = [
			"name",
			"nameAr",
			"description",
			"descriptionAr",
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

		if (req.body.category !== undefined) {
			service.category = normalizeCategory(req.body.category);
		}

		if (req.body.providerId !== undefined) {
			const nurse = await Nurse.findById(req.body.providerId).select("_id");
			if (!nurse) {
				return res
					.status(404)
					.json({ success: false, message: "Nurse provider not found" });
			}

			service.providerId = req.body.providerId;
			service.providerModel = "Nurse";
		}

		await service.save();
		await service.populate({
			path: "providerId",
			select: "specialization profileStatus verificationStatus user",
			populate: { path: "user", select: "name email mobile" },
		});

		res.json({ success: true, data: service });
	} catch (error) {
		console.error("updateAdminHomeNursingService error:", error);
		res
			.status(500)
			.json({ success: false, message: "Server Error", error: error.message });
	}
};

// @desc    Archive (deactivate) a home nursing service as admin
// @route   DELETE /api/services/admin/home-nursing/:id
// @access  Private (Admin)
const archiveAdminHomeNursingService = async (req, res) => {
	try {
		const service = await Service.findOne({
			_id: req.params.id,
			type: "home_nursing",
		});

		if (!service) {
			return res
				.status(404)
				.json({ success: false, message: "Home nursing service not found" });
		}

		service.isActive = false;
		await service.save();

		res.json({ success: true, message: "Service archived successfully" });
	} catch (error) {
		console.error("archiveAdminHomeNursingService error:", error);
		res
			.status(500)
			.json({ success: false, message: "Server Error", error: error.message });
	}
};

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
	getPublicHomeNursingServices,
	getAdminHomeNursingServices,
	getHomeNursingProviders,
	createAdminHomeNursingService,
	updateAdminHomeNursingService,
	archiveAdminHomeNursingService,
	getServicesByClinic,
	getMyServices,
	createService,
	updateService,
	deleteService,
};
