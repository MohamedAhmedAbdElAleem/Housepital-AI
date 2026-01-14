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
		const {
			serviceId,
			serviceName,
			servicePrice,
			patientId,
			patientName,
			isForSelf,
			clinicId,
			type,
			hasMedicalTools,
			timeOption,
			scheduledDate,
			scheduledTime,
			notes,
			prescriptionUrl
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

		const userId = req.user?.id;
		if (!userId) {
			return res.status(401).json({
				success: false,
				message: "User not authenticated",
			});
		}

		// Resolve Patient Name if missing
		let resolvedPatientName = patientName;
		if (!resolvedPatientName && (isForSelf || String(patientId) === String(userId))) {
			const user = await User.findById(userId);
			if (user) resolvedPatientName = user.name;
		}

		if (!resolvedPatientName) {
             return res.status(400).json({ success: false, message: "Patient name is required" });
        }

		// Determine Booking Type & Doctor ID
		let bookingType = type || "home_nursing";
		let doctorId = null;

		// If clinic appointment, we should look up the service to find the provider (Doctor)
		if (bookingType === 'clinic_appointment' || clinicId) {
			bookingType = 'clinic_appointment';
			// You might want to fetch Service here to get providerId if not passed
			// For now assuming the frontend might pass doctorId or we derive it differently
			// Let's rely on service lookup if needed, but for MVP let's trust if passed or lookup
			const Service = require("../models/Service");
			const service = await Service.findById(serviceId);
			if (service && service.providerModel === 'Doctor') {
				doctorId = service.providerId;
			}
		}

		const booking = new Booking({
			type: bookingType,
			serviceId,
			serviceName,
			servicePrice: servicePrice || 0,
			patientId,
			patientName: resolvedPatientName,
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
			clinicId,
			doctorId
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
			"checked-in",
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

		// Generate visit PIN when confirmed
		if (status === "confirmed" && !booking.visitPin) {
			booking.visitPin = Math.floor(1000 + Math.random() * 9000).toString();
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
 * @desc    Check-in a patient using PIN
 * @route   PUT /api/bookings/:id/check-in
 * @access  Private (Doctor)
 */
exports.checkInPatient = async (req, res) => {
	try {
		const { id } = req.params;
		const { pin } = req.body;

		if (!pin) {
			return res.status(400).json({
				success: false,
				message: "PIN is required",
			});
		}

		const booking = await Booking.findById(id);

		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		if (booking.status !== "confirmed") {
			return res.status(400).json({
				success: false,
				message: "Only confirmed bookings can be checked in",
			});
		}

		if (booking.visitPin !== pin) {
			return res.status(400).json({
				success: false,
				message: "Invalid PIN",
			});
		}

		booking.status = "checked-in";
		booking.checkedInAt = new Date();
		await booking.save();

		res.status(200).json({
			success: true,
			message: "Patient checked in successfully",
			booking: booking,
		});
	} catch (error) {
		console.error("❌ Error checking in patient:", error);
		res.status(500).json({
			success: false,
			message: "Error checking in patient",
			error: error.message,
		});
	}
};

/**
 * @desc    Get bookings for a doctor
 * @route   GET /api/bookings/doctor-appointments
 * @access  Private (Doctor)
 */
exports.getDoctorAppointments = async (req, res) => {
	try {
        // Find doctor profile for this user
        const Doctor = require("../models/Doctor");
        const doctorProfile = await Doctor.findOne({ user: req.user.id });
        
        if (!doctorProfile) {
             return res.status(404).json({ message: "Doctor profile not found" });
        }

		const bookings = await Booking.find({ doctorId: doctorProfile._id })
			.sort({ scheduledDate: 1, scheduledTime: 1 })
			.populate("patientId", "name email phone profilePictureUrl") // Populate patient user details
            .populate("clinicId", "name address")
            .populate("serviceId", "name durationMinutes");

		res.status(200).json({
			success: true,
			bookings: bookings,
		});
	} catch (error) {
		console.error("❌ Error fetching doctor bookings:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching bookings",
			error: error.message,
		});
	}
};

/**
 * @desc    Get booked time slots for a clinic on a date
 * @route   GET /api/bookings/slots
 * @access  Public
 */
exports.getBookedSlots = async (req, res) => {
	try {
		const { clinicId, date, doctorId } = req.query;

		if (!date) {
			return res.status(400).json({
				success: false,
				message: "Date is required",
			});
		}

		// Parse date to get start and end of day
		const queryDate = new Date(date);
		const startOfDay = new Date(queryDate.setHours(0, 0, 0, 0));
		const endOfDay = new Date(queryDate.setHours(23, 59, 59, 999));

		let query = {
			scheduledDate: { $gte: startOfDay, $lte: endOfDay },
			status: { $nin: ["cancelled", "no-show"] },
		};

		if (clinicId) {
			query.clinicId = clinicId;
		}
		if (doctorId) {
			query.doctorId = doctorId;
		}

		const bookings = await Booking.find(query).select("scheduledTime");

		const bookedSlots = bookings
			.map((b) => b.scheduledTime)
			.filter((t) => t);

		res.json({
			success: true,
			date: date,
			bookedSlots: bookedSlots,
		});
	} catch (error) {
		console.error("Error fetching booked slots:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching booked slots",
		});
	}
};
