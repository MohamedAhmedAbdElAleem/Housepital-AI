const Booking = require("../models/Booking");
const User = require("../models/User");

/**
 * @desc    Create a new booking
 * @route   POST /api/bookings/create
 * @access  Private
 */
exports.createBooking = async (req, res) => {
	try {
		console.log("📋 Creating booking...");
		console.log("Request body:", req.body);
		console.log("User from token:", req.user);

		const {
			type,
			serviceId,
			serviceName,
			servicePrice,
			patientId,
			patientName,
			isForSelf,
			hasMedicalTools,
			timeOption,
			scheduledDate,
			scheduledTime,
			notes,
			prescriptionUrl,
			addressId,
			address,
			nurseGenderPreference,
		} = req.body;

		// Validate required fields
		if (!serviceId || !serviceName || !patientId || !timeOption) {
			return res.status(400).json({
				success: false,
				message: "Missing required fields",
			});
		}

		// Validate scheduled time if option is 'schedule'
		if (timeOption === "schedule" && (!scheduledDate || !scheduledTime)) {
			return res.status(400).json({
				success: false,
				message: "Scheduled date and time are required for scheduled bookings",
			});
		}

		// Get userId from authenticated user
		const userId = req.user?.id;
		if (!userId) {
			return res.status(401).json({
				success: false,
				message: "User not authenticated",
			});
		}

		// Create booking
		const booking = new Booking({
			type: type || "home_nursing",
			serviceId,
			serviceName,
			servicePrice: servicePrice || 0,
			patientId,
			patientName,
			isForSelf: isForSelf || false,
			userId,
			hasMedicalTools: hasMedicalTools || false,
			timeOption,
			scheduledDate: scheduledDate ? new Date(scheduledDate) : null,
			scheduledTime,
			addressId: addressId || "",
			address: address || {},
			nurseGenderPreference: nurseGenderPreference || "any",
			notes: notes || "",
			prescriptionUrl: prescriptionUrl || "",
			status: "pending",
			paymentStatus: "pending",
		});

		await booking.save();

		console.log("✅ Booking created successfully:", booking._id);

		res.status(201).json({
			success: true,
			message: "Booking created successfully",
			booking: booking,
		});
	} catch (error) {
		console.error("❌ Error creating booking:", error);
		res.status(500).json({
			success: false,
			message: "Error creating booking",
			error: error.message,
		});
	}
};

/**
 * @desc    Get all bookings for the authenticated user
 * @route   GET /api/bookings/my-bookings
 * @access  Private
 */
exports.getMyBookings = async (req, res) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			return res.status(401).json({
				success: false,
				message: "User not authenticated",
			});
		}

		const bookings = await Booking.find({ userId })
			.sort({ createdAt: -1 })
			.populate("assignedNurse", "name email mobile");

		res.status(200).json({
			success: true,
			bookings: bookings,
		});
	} catch (error) {
		console.error("❌ Error fetching bookings:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching bookings",
			error: error.message,
		});
	}
};

/**
 * @desc    Get a single booking by ID
 * @route   GET /api/bookings/:id
 * @access  Private
 */
exports.getBookingById = async (req, res) => {
	try {
		const { id } = req.params;
		const userId = req.user?.id;

		const booking = await Booking.findById(id).populate(
			"assignedNurse",
			"name email mobile"
		);

		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		// Check if user owns this booking
		if (booking.userId.toString() !== userId) {
			return res.status(403).json({
				success: false,
				message: "Not authorized to view this booking",
			});
		}

		res.status(200).json({
			success: true,
			booking: booking,
		});
	} catch (error) {
		console.error("❌ Error fetching booking:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching booking",
			error: error.message,
		});
	}
};

/**
 * @desc    Cancel a booking
 * @route   PUT /api/bookings/:id/cancel
 * @access  Private
 */
exports.cancelBooking = async (req, res) => {
	try {
		const { id } = req.params;
		const userId = req.user?.id;

		const booking = await Booking.findById(id);

		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		// Check if user owns this booking
		if (booking.userId.toString() !== userId) {
			return res.status(403).json({
				success: false,
				message: "Not authorized to cancel this booking",
			});
		}

		// Check if booking can be cancelled
		if (booking.status === "completed" || booking.status === "cancelled") {
			return res.status(400).json({
				success: false,
				message: `Cannot cancel a ${booking.status} booking`,
			});
		}

		booking.status = "cancelled";
		await booking.save();

		res.status(200).json({
			success: true,
			message: "Booking cancelled successfully",
			booking: booking,
		});
	} catch (error) {
		console.error("❌ Error cancelling booking:", error);
		res.status(500).json({
			success: false,
			message: "Error cancelling booking",
			error: error.message,
		});
	}
};

/**
 * @desc    Update booking status (for nurses/admin)
 * @route   PUT /api/bookings/:id/status
 * @access  Private (Nurse/Admin)
 */
exports.updateBookingStatus = async (req, res) => {
	try {
		const { id } = req.params;
		const { status } = req.body;

		const validStatuses = [
			"pending",
			"confirmed",
			"assigned",
			"in-progress",
			"completed",
			"cancelled",
		];
		if (!validStatuses.includes(status)) {
			return res.status(400).json({
				success: false,
				message: "Invalid status",
			});
		}

		const booking = await Booking.findById(id);

		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		booking.status = status;
		await booking.save();

		res.status(200).json({
			success: true,
			message: "Booking status updated successfully",
			booking: booking,
		});
	} catch (error) {
		console.error("❌ Error updating booking status:", error);
		res.status(500).json({
			success: false,
			message: "Error updating booking status",
			error: error.message,
		});
	}
};

/**
 * @desc    Get pending bookings for nurses
 * @route   GET /api/bookings/nurse/pending
 * @access  Private (Nurse)
 */
exports.getNursePendingBookings = async (req, res) => {
	try {
		const nurseId = req.user?.id;
		console.log("📋 Fetching pending bookings for nurse:", nurseId);

		// Find bookings that are pending/searching and not assigned yet
		const bookings = await Booking.find({
			status: { $in: ["pending", "searching"] },
			assignedNurse: null,
			type: "home_nursing"
		})
			.sort({ createdAt: -1 })
			.populate("userId", "name email mobile")
			.limit(10);

		console.log(`✅ Found ${bookings.length} pending bookings`);

		res.status(200).json({
			success: true,
			bookings: bookings,
		});
	} catch (error) {
		console.error("❌ Error fetching pending bookings:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching pending bookings",
			error: error.message,
		});
	}
};

/**
 * @desc    Get nurse's active booking (currently assigned)
 * @route   GET /api/bookings/nurse/active
 * @access  Private (Nurse)
 */
exports.getNurseActiveBooking = async (req, res) => {
	try {
		const Nurse = require("../models/Nurse");
		const nurseProfile = await Nurse.findOne({ user: req.user?.id });

		if (!nurseProfile) {
			return res.status(404).json({
				success: false,
				message: "Nurse profile not found",
			});
		}

		const booking = await Booking.findOne({
			assignedNurse: nurseProfile._id,
			status: { $in: ["assigned", "in-progress"] }
		}).populate("userId", "name email mobile address");

		res.status(200).json({
			success: true,
			booking: booking || null,
		});
	} catch (error) {
		console.error("❌ Error fetching active booking:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching active booking",
			error: error.message,
		});
	}
};

/**
 * @desc    Nurse accepts a booking
 * @route   POST /api/bookings/:id/accept
 * @access  Private (Nurse)
 */
exports.acceptBooking = async (req, res) => {
	try {
		const { id } = req.params;
		const Nurse = require("../models/Nurse");

		// Get nurse profile
		const nurseProfile = await Nurse.findOne({ user: req.user?.id });
		if (!nurseProfile) {
			return res.status(404).json({
				success: false,
				message: "Nurse profile not found",
			});
		}

		const booking = await Booking.findById(id);

		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		// Check if booking is still available
		if (booking.assignedNurse) {
			return res.status(400).json({
				success: false,
				message: "Booking already assigned to another nurse",
			});
		}

		if (!["pending", "searching"].includes(booking.status)) {
			return res.status(400).json({
				success: false,
				message: "Booking is not available for acceptance",
			});
		}

		// Generate 4-digit PIN
		const generatePin = () => {
			return Math.floor(1000 + Math.random() * 9000).toString();
		};

		// Assign nurse and update status
		booking.assignedNurse = nurseProfile._id;
		booking.status = "assigned";
		booking.visitPin = generatePin();
		await booking.save();

		// Re-fetch with populated user data for response
		const populatedBooking = await Booking.findById(booking._id)
			.populate("userId", "name email mobile");

		console.log(`✅ Booking ${id} accepted by nurse ${nurseProfile._id}, PIN: ${booking.visitPin}`);

		res.status(200).json({
			success: true,
			message: "Booking accepted successfully",
			booking: populatedBooking,
		});
	} catch (error) {
		console.error("❌ Error accepting booking:", error);
		res.status(500).json({
			success: false,
			message: "Error accepting booking",
			error: error.message,
		});
	}
};

/**
 * @desc    Verify PIN and start visit
 * @route   POST /api/bookings/:id/verify-pin
 * @access  Private (Nurse)
 */
exports.verifyPinAndStartVisit = async (req, res) => {
	try {
		const { id } = req.params;
		const { pin } = req.body;
		const Nurse = require("../models/Nurse");

		if (!pin || pin.length !== 4) {
			return res.status(400).json({
				success: false,
				message: "Valid 4-digit PIN required",
			});
		}

		const nurseProfile = await Nurse.findOne({ user: req.user?.id });
		if (!nurseProfile) {
			return res.status(404).json({
				success: false,
				message: "Nurse profile not found",
			});
		}

		const booking = await Booking.findById(id);

		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		// Verify nurse is assigned to this booking
		if (booking.assignedNurse?.toString() !== nurseProfile._id.toString()) {
			return res.status(403).json({
				success: false,
				message: "Not authorized for this booking",
			});
		}

		// Verify PIN
		if (booking.visitPin !== pin) {
			return res.status(400).json({
				success: false,
				message: "Invalid PIN",
			});
		}

		// Start visit
		booking.status = "in-progress";
		booking.visitStartedAt = new Date();
		booking.checkedInAt = new Date();
		await booking.save();

		console.log(`✅ Visit started for booking ${id}`);

		res.status(200).json({
			success: true,
			message: "Visit started successfully",
			booking: booking,
		});
	} catch (error) {
		console.error("❌ Error starting visit:", error);
		res.status(500).json({
			success: false,
			message: "Error starting visit",
			error: error.message,
		});
	}
};

/**
 * @desc    Complete visit
 * @route   POST /api/bookings/:id/complete
 * @access  Private (Nurse)
 */
exports.completeVisit = async (req, res) => {
	try {
		const { id } = req.params;
		const { report } = req.body;
		const Nurse = require("../models/Nurse");

		const nurseProfile = await Nurse.findOne({ user: req.user?.id });
		if (!nurseProfile) {
			return res.status(404).json({
				success: false,
				message: "Nurse profile not found",
			});
		}

		const booking = await Booking.findById(id);

		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		// Verify nurse is assigned to this booking
		if (booking.assignedNurse?.toString() !== nurseProfile._id.toString()) {
			return res.status(403).json({
				success: false,
				message: "Not authorized for this booking",
			});
		}

		if (booking.status !== "in-progress") {
			return res.status(400).json({
				success: false,
				message: "Visit must be in progress to complete",
			});
		}

		// Complete visit
		booking.status = "completed";
		booking.visitEndedAt = new Date();
		booking.visitReport = report || "";
		await booking.save();

		console.log(`✅ Visit completed for booking ${id}`);

		res.status(200).json({
			success: true,
			message: "Visit completed successfully",
			booking: booking,
		});
	} catch (error) {
		console.error("❌ Error completing visit:", error);
		res.status(500).json({
			success: false,
			message: "Error completing visit",
			error: error.message,
		});
	}
};
