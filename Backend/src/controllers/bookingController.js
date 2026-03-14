const Booking = require("../models/Booking");
const User = require("../models/User");
const { sendNotification, getIO } = require("../services/notificationService");
const Doctor = require("../models/Doctor");

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
			type, // 'home_nursing' | 'clinic_appointment'
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
			// clinic_appointment specific
			clinicId,
			doctorId,
			addressId,
			address,
			nurseGenderPreference,
		} = req.body;

		const bookingType = type || "home_nursing";

		// Validate required fields
		if (!serviceId || !serviceName || !patientId || !timeOption) {
			return res.status(400).json({
				success: false,
				message: "Missing required fields",
			});
		}

		// Clinic appointments must always have a date; time only required for 'schedule' mode
		if (bookingType === "clinic_appointment" && !scheduledDate) {
			return res.status(400).json({
				success: false,
				message: "Clinic appointments require a scheduled date",
			});
		}
		if (
			bookingType === "clinic_appointment" &&
			timeOption !== "queue" &&
			!scheduledTime
		) {
			return res.status(400).json({
				success: false,
				message: "Clinic slot appointments require a scheduled time",
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

		// Queue bookings are auto-confirmed (no doctor approval needed)
		const initialStatus =
			bookingType === "clinic_appointment" && timeOption === "queue"
				? "confirmed"
				: "pending";

		// Create booking
		let finalAddress = address || {};
		if (addressId && Object.keys(finalAddress).length === 0) {
			const userDoc = await User.findById(userId);
			if (userDoc) {
				const foundAddr = userDoc.addresses.id(addressId);
				if (foundAddr) {
					finalAddress = {
						street: foundAddr.street,
						area: foundAddr.area,
						city: foundAddr.city,
						state: foundAddr.state,
						coordinates: foundAddr.coordinates,
					};
				}
			}
		}

		const booking = new Booking({
			type: bookingType,
			serviceId,
			serviceName,
			servicePrice: servicePrice || 0,
			patientId,
			patientName,
			isForSelf: isForSelf || false,
			userId,
			hasMedicalTools: hasMedicalTools || false,
			timeOption:
				bookingType === "clinic_appointment"
					? timeOption === "queue"
						? "queue"
						: "schedule"
					: timeOption,
			scheduledDate: scheduledDate ? new Date(scheduledDate) : null,
			scheduledTime,
			addressId: addressId || "",
			address: finalAddress,
			nurseGenderPreference: nurseGenderPreference || "any",
			notes: notes || "",
			prescriptionUrl: prescriptionUrl || "",
			status: initialStatus,
			paymentStatus: "pending",
			// clinic specific
			...(clinicId && { clinicId }),
			...(doctorId && { doctorId }),
		});

		await booking.save();

		console.log("✅ Booking created successfully:", booking._id);

		// Send notification to user
		await sendNotification({
			userId: userId,
			title: "Booking Confirmed! 🎉",
			body: `Your ${serviceName} booking has been created successfully. We're finding the best nurse for you.`,
			titleAr: "تم تأكيد الحجز! 🎉",
			bodyAr: `تم إنشاء حجز ${serviceName} بنجاح. نحن نبحث عن أفضل ممرض/ة لك.`,
			type: "booking_created",
			referenceId: booking._id,
			referenceType: "booking",
			priority: "high",
			metadata: { serviceName, status: "pending" },
		});
		const io = getIO();
		if (io) {
			const populatedBooking = await Booking.findById(booking._id).populate(
				"userId",
				"name email mobile address",
			);
			io.to("online_nurses").emit("new_booking_request", populatedBooking);
		}
		res.status(201).json({
			success: true,
			message: "Booking created successfully",
			booking: await Booking.findById(booking._id).populate(
				"userId",
				"name email mobile address",
			),
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
 * @desc    Get all clinic appointments for the authenticated doctor
 * @route   GET /api/bookings/doctor-appointments
 * @access  Private (Doctor)
 */
exports.getDoctorAppointments = async (req, res) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			return res
				.status(401)
				.json({ success: false, message: "Not authenticated" });
		}

		// The booking stores Doctor._id (not User._id), so look up the Doctor record first
		const doctor = await Doctor.findOne({ user: userId });
		if (!doctor) {
			return res.status(200).json({ success: true, bookings: [] });
		}

		const bookings = await Booking.find({
			doctorId: doctor._id,
			type: "clinic_appointment",
		})
			.populate("clinicId", "name address")
			.sort({ createdAt: -1 });

		res.status(200).json({ success: true, bookings });
	} catch (error) {
		console.error("❌ Error fetching doctor appointments:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching appointments",
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
			.populate("assignedNurse", "name email mobile")
			.populate("clinicId", "name address")
			.populate({
				path: "doctorId",
				select: "specialization user",
				populate: { path: "user", select: "name" },
			});

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
			"name email mobile",
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

		// Send cancellation notification
		await sendNotification({
			userId: booking.userId.toString(),
			title: "Booking Cancelled",
			body: `Your ${booking.serviceName} booking has been cancelled.`,
			titleAr: "تم إلغاء الحجز",
			bodyAr: `تم إلغاء حجز ${booking.serviceName} الخاص بك.`,
			type: "booking_cancelled",
			referenceId: booking._id,
			referenceType: "booking",
			priority: "normal",
			metadata: { serviceName: booking.serviceName, status: "cancelled" },
		});

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
			"on-the-way",
			"arrived",
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

		// Send status change notification
		const statusMessages = {
			confirmed: {
				title: "Booking Confirmed ✅",
				body: `Your ${booking.serviceName} booking has been confirmed!`,
				titleAr: "تم تأكيد الحجز ✅",
				bodyAr: `تم تأكيد حجز ${booking.serviceName} الخاص بك!`,
				type: "booking_confirmed",
			},
			assigned: {
				title: "Nurse Assigned 👩‍⚕️",
				body: `A nurse has been assigned to your ${booking.serviceName} booking.`,
				titleAr: "تم تعيين ممرض/ة 👩‍⚕️",
				bodyAr: `تم تعيين ممرض/ة لحجز ${booking.serviceName} الخاص بك.`,
				type: "booking_assigned",
			},
			"in-progress": {
				title: "Service Started 🏥",
				body: `Your ${booking.serviceName} service is now in progress.`,
				titleAr: "بدأت الخدمة 🏥",
				bodyAr: `خدمة ${booking.serviceName} جارية الآن.`,
				type: "booking_in_progress",
			},
			completed: {
				title: "Service Completed 🎉",
				body: `Your ${booking.serviceName} service has been completed. Please rate your experience!`,
				titleAr: "اكتملت الخدمة 🎉",
				bodyAr: `اكتملت خدمة ${booking.serviceName}. يرجى تقييم تجربتك!`,
				type: "booking_completed",
			},
			cancelled: {
				title: "Booking Cancelled ❌",
				body: `Your ${booking.serviceName} booking has been cancelled.`,
				titleAr: "تم إلغاء الحجز ❌",
				bodyAr: `تم إلغاء حجز ${booking.serviceName}.`,
				type: "booking_cancelled",
			},
		};

		const msg = statusMessages[status];
		if (msg) {
			await sendNotification({
				userId: booking.userId.toString(),
				title: msg.title,
				body: msg.body,
				titleAr: msg.titleAr,
				bodyAr: msg.bodyAr,
				type: msg.type,
				referenceId: booking._id,
				referenceType: "booking",
				priority:
					status === "in-progress" || status === "assigned" ? "high" : "normal",
				metadata: { serviceName: booking.serviceName, status },
			});
		}

		res.status(200).json({
			success: true,
			message: "Booking status updated successfully",
			booking: await Booking.findById(booking._id).populate(
				"userId",
				"name email mobile address",
			),
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
			type: "home_nursing",
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
			status: { $in: ["assigned", "in-progress"] },
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
		const populatedBooking = await Booking.findById(booking._id).populate(
			"userId",
			"name email mobile",
		);

		console.log(
			`✅ Booking ${id} accepted by nurse ${nurseProfile._id}, PIN: ${booking.visitPin}`,
		);

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

// Update nurse location during tracking
exports.updateNurseLocation = async (req, res) => {
	try {
		const { id } = req.params;
		const { latitude, longitude } = req.body;

		const booking = await Booking.findById(id);
		if (!booking) {
			return res
				.status(404)
				.json({ success: false, message: "Booking not found" });
		}

		booking.nurseLocation = {
			latitude,
			longitude,
			lastUpdated: new Date(),
		};
		await booking.save();

		// If socket available, emit to a room specific to this booking or user
		if (req.app.get("io")) {
			req.app.get("io").emit("nurse_location_update", {
				bookingId: id,
				location: booking.nurseLocation,
			});
		}

		res.json({
			success: true,
			message: "Location updated successfully",
			location: booking.nurseLocation,
		});
	} catch (error) {
		console.error("Error updating location:", error);
		res.status(500).json({ success: false, message: error.message });
	}
};

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
