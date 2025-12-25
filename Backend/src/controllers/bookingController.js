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
