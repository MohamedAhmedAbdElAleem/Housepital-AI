const Booking = require("../models/Booking");
const User = require("../models/User");
const { sendNotification, getIO } = require("../services/notificationService");
const Doctor = require("../models/Doctor");
const walletService = require("../services/walletService");

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

		// Check if patient's wallet is blocked
		const patientBlocked = await walletService.isWalletBlocked(userId);
		if (patientBlocked) {
			return res.status(403).json({
				success: false,
				message: "Your account is restricted due to outstanding wallet balance. Please contact support.",
				walletBlocked: true,
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

		// Generate 4-digit PIN for clinic appointments (patients show this at reception)
		const visitPin = bookingType === "clinic_appointment"
			? Math.floor(1000 + Math.random() * 9000).toString()
			: undefined;

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
			...(visitPin && { visitPin }),
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
			.populate("patientId", "name email mobile gender dateOfBirth medicalInfo")
			.populate("dependentId", "fullName gender dateOfBirth chronicConditions allergies relationship")
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
			.populate({
				path: "assignedNurse",
				select: "user rating totalRatings",
				populate: { path: "user", select: "name mobile" },
			})
			.populate("clinicId", "name address")
			.populate({
				path: "doctorId",
				select: "specialization user",
				populate: { path: "user", select: "name" },
			});

		// Enrich bookings with nurseName, nurseRating, nursePhone
		const enriched = bookings.map((b) => {
			const obj = b.toObject();
			if (obj.assignedNurse && obj.assignedNurse.user) {
				obj.nurseName = obj.assignedNurse.user.name || "Nurse";
				obj.nursePhone = obj.assignedNurse.user.mobile || null;
				obj.nurseRating = obj.assignedNurse.rating || 0;
			}
			return obj;
		});

		res.status(200).json({
			success: true,
			bookings: enriched,
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

		const booking = await Booking.findById(id).populate({
			path: "assignedNurse",
			select: "user rating totalRatings",
			populate: { path: "user", select: "name mobile" },
		});

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

		// Enrich with nurseName, nurseRating, nursePhone
		const obj = booking.toObject();
		if (obj.assignedNurse && obj.assignedNurse.user) {
			obj.nurseName = obj.assignedNurse.user.name || "Nurse";
			obj.nursePhone = obj.assignedNurse.user.mobile || null;
			obj.nurseRating = obj.assignedNurse.rating || 0;
		}

		res.status(200).json({
			success: true,
			booking: obj,
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
			status: { $in: ["confirmed", "assigned", "on-the-way", "arrived", "in-progress"] },
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

		// Check if nurse's wallet is blocked
		const nurseBlocked = await walletService.isWalletBlocked(req.user?.id);
		if (nurseBlocked) {
			return res.status(403).json({
				success: false,
				message: "Your account is restricted due to outstanding wallet balance. Please recharge your wallet.",
				walletBlocked: true,
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
		const Doctor = require("../models/Doctor");

		if (!pin || pin.length !== 4) {
			return res.status(400).json({
				success: false,
				message: "Valid 4-digit PIN required",
			});
		}

		const nurseProfile = await Nurse.findOne({ user: req.user?.id });
		const doctorProfile = await Doctor.findOne({ user: req.user?.id });

		if (!nurseProfile && !doctorProfile) {
			return res.status(404).json({
				success: false,
				message: "Profile not found (must be nurse or doctor)",
			});
		}

		const booking = await Booking.findById(id);

		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		// Authorization check based on booking type
		if (booking.type === "clinic_appointment") {
			if (!doctorProfile) {
				return res.status(403).json({
					success: false,
					message: "Only doctors can start clinic appointments",
				});
			}
			if (booking.doctorId?.toString() !== doctorProfile._id.toString()) {
				return res.status(403).json({
					success: false,
					message: "Not authorized for this booking",
				});
			}
		} else {
			// Nursing booking
			if (!nurseProfile) {
				return res.status(403).json({
					success: false,
					message: "Only nurses can start home nursing visits",
				});
			}
			if (booking.assignedNurse?.toString() !== nurseProfile._id.toString()) {
				return res.status(403).json({
					success: false,
					message: "Not authorized for this booking",
				});
			}

			// Prevent starting a second visit while one is already in-progress
			const existingInProgress = await Booking.findOne({
				assignedNurse: nurseProfile._id,
				status: "in-progress",
				_id: { $ne: id },
			});
			if (existingInProgress) {
				return res.status(400).json({
					success: false,
					message: "You already have a visit in progress. Please complete it first.",
				});
			}
		}

		// Fallback: If visitPin is not set, generate it on the fly (for old/seeded bookings)
		if (!booking.visitPin) {
			booking.visitPin = Math.floor(1000 + Math.random() * 9000).toString();
			await booking.save();
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

		// Re-fetch with populated details
		const populatedBooking = await Booking.findById(booking._id)
			.populate("userId", "name email mobile")
			.populate("patientId", "name email mobile medicalInfo gender dateOfBirth")
			.populate("dependentId", "fullName gender dateOfBirth chronicConditions allergies relationship");

		console.log(`✅ Visit/Appointment started for booking ${id}`);

		res.status(200).json({
			success: true,
			message: "Visit started successfully",
			booking: populatedBooking,
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

		// Emit to the specific patient who made this booking
		if (req.app.get("io") && booking.userId) {
			req.app.get("io").to(`patient_${booking.userId}`).emit("nurse_location_update", {
				bookingId: id,
				latitude,
				longitude,
				lastUpdated: new Date(),
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
		booking.paymentStatus = "paid";
		booking.paidAt = new Date();
		await booking.save();

		// Deduct nurse commission (15%) from wallet
		try {
			const nurseUser = await Nurse.findById(nurseProfile._id).select("user");
			const totalAmount = booking.totalAmount || booking.servicePrice || 0;
			if (totalAmount > 0 && nurseUser) {
				const commissionResult = await walletService.deductNurseCommission(
					nurseUser.user.toString(),
					totalAmount,
					booking._id.toString()
				);
				console.log(`💰 Nurse commission deducted. New balance: ${commissionResult.newBalance}`);
			}
		} catch (commissionError) {
			console.error("⚠️ Error deducting nurse commission (visit still completed):", commissionError.message);
		}

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

/**
 * @desc    Complete a clinic appointment and deduct doctor commission
 * @route   POST /api/bookings/:id/complete-appointment
 * @access  Private (Doctor)
 */
exports.completeAppointment = async (req, res) => {
	try {
		const { id } = req.params;
		const userId = req.user?.id;

		// Find the doctor profile
		const doctor = await Doctor.findOne({ user: userId });
		if (!doctor) {
			return res.status(404).json({
				success: false,
				message: "Doctor profile not found",
			});
		}

		const booking = await Booking.findById(id);
		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		// Verify this booking belongs to this doctor
		if (booking.doctorId?.toString() !== doctor._id.toString()) {
			return res.status(403).json({
				success: false,
				message: "Not authorized for this appointment",
			});
		}

		if (booking.type !== "clinic_appointment") {
			return res.status(400).json({
				success: false,
				message: "This is not a clinic appointment",
			});
		}

		// Mark as completed
		booking.status = "completed";
		booking.visitEndedAt = new Date();
		booking.paymentStatus = "paid";
		booking.paidAt = new Date();
		await booking.save();

		// Deduct doctor commission (10%) from wallet
		try {
			const totalAmount = booking.totalAmount || booking.servicePrice || 0;
			if (totalAmount > 0) {
				const commissionResult = await walletService.deductDoctorCommission(
					userId,
					totalAmount,
					booking._id.toString()
				);
				console.log(`💰 Doctor commission deducted. New balance: ${commissionResult.newBalance}`);
			}
		} catch (commissionError) {
			console.error("⚠️ Error deducting doctor commission (appointment still completed):", commissionError.message);
		}

		// Send notification to patient
		await sendNotification({
			userId: booking.userId.toString(),
			title: "Appointment Completed 🎉",
			body: `Your ${booking.serviceName} appointment has been completed. Please rate your experience!`,
			titleAr: "اكتملت الزيارة 🎉",
			bodyAr: `اكتملت زيارة ${booking.serviceName}. يرجى تقييم تجربتك!`,
			type: "booking_completed",
			referenceId: booking._id,
			referenceType: "booking",
			priority: "normal",
			metadata: { serviceName: booking.serviceName, status: "completed" },
		});

		console.log(`✅ Appointment completed for booking ${id}`);

		res.status(200).json({
			success: true,
			message: "Appointment completed successfully",
			booking: booking,
		});
	} catch (error) {
		console.error("❌ Error completing appointment:", error);
		res.status(500).json({
			success: false,
			message: "Error completing appointment",
			error: error.message,
		});
	}
};

/**
 * @desc    Get nurse's booking history (last 10 completed/cancelled)
 * @route   GET /api/bookings/nurse/history
 * @access  Private (Nurse)
 */
exports.getNurseBookingHistory = async (req, res) => {
	try {
		const Nurse = require("../models/Nurse");
		const nurseProfile = await Nurse.findOne({ user: req.user?.id });

		if (!nurseProfile) {
			return res.status(404).json({
				success: false,
				message: "Nurse profile not found",
			});
		}

		const bookings = await Booking.find({
			assignedNurse: nurseProfile._id,
			status: { $in: ["completed", "cancelled"] },
		})
			.sort({ updatedAt: -1 })
			.limit(10)
			.populate("userId", "name email mobile");

		console.log(`✅ Found ${bookings.length} history bookings for nurse ${nurseProfile._id}`);

		res.status(200).json({
			success: true,
			bookings: bookings,
		});
	} catch (error) {
		console.error("❌ Error fetching nurse history:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching booking history",
			error: error.message,
		});
	}
};

// ============ RATING ============

/**
 * Rate a completed booking (patient rates nurse)
 * POST /bookings/:id/rate
 */
exports.rateBooking = async (req, res) => {
	try {
		const { id } = req.params;
		const { rating, review } = req.body;
		const Rating = require("../models/Rating");
		const Nurse = require("../models/Nurse");

		if (!rating || rating < 1 || rating > 5) {
			return res.status(400).json({
				success: false,
				message: "Rating must be between 1 and 5",
			});
		}

		const booking = await Booking.findById(id);
		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		// Verify user owns this booking
		if (booking.userId.toString() !== req.user.id) {
			return res.status(403).json({
				success: false,
				message: "Not authorized to rate this booking",
			});
		}

		if (booking.status !== "completed") {
			return res.status(400).json({
				success: false,
				message: "Can only rate completed bookings",
			});
		}

		// Check if already rated
		if (booking.customerRating) {
			return res.status(400).json({
				success: false,
				message: "You have already rated this booking",
			});
		}

		// Get nurse user ID for the Rating document
		const nurseProfile = await Nurse.findById(booking.assignedNurse).select("user");
		if (!nurseProfile) {
			return res.status(404).json({
				success: false,
				message: "Nurse profile not found",
			});
		}

		// Create Rating document
		await Rating.create({
			bookingId: booking._id,
			raterUserId: req.user.id,
			raterRole: "customer",
			ratedUserId: nurseProfile.user,
			ratedRole: "nurse",
			overallRating: rating,
			review: review || "",
		});

		// Update booking
		booking.customerRating = rating;
		booking.customerReview = review || "";
		await booking.save();

		// Recalculate nurse average rating
		const { avgRating, totalRatings } = await Rating.calculateAverageRating(nurseProfile.user);

		// Update nurse profile with new average
		await Nurse.findByIdAndUpdate(booking.assignedNurse, {
			rating: avgRating,
			totalRatings: totalRatings,
		});

		console.log(`⭐ Booking ${id} rated ${rating}/5 by patient. Nurse avg: ${avgRating}`);

		res.status(200).json({
			success: true,
			message: "Rating submitted successfully",
			booking: booking,
			nurseAvgRating: avgRating,
			nurseTotalRatings: totalRatings,
		});
	} catch (error) {
		// Handle duplicate rating (unique index on bookingId + raterRole)
		if (error.code === 11000) {
			return res.status(400).json({
				success: false,
				message: "You have already rated this booking",
			});
		}
		console.error("❌ Error rating booking:", error);
		res.status(500).json({
			success: false,
			message: "Error submitting rating",
			error: error.message,
		});
	}
};

// ============ ADMIN ============

/**
 * @desc    Get all bookings for admin
 * @route   GET /api/bookings/admin/all
 * @access  Private (Admin)
 */
exports.getAllBookingsAdmin = async (req, res) => {
	try {
		const { status, type, page = 1, limit = 20 } = req.query;
		const query = {};

		if (status) query.status = status;
		if (type) query.type = type;

		const skip = (parseInt(page) - 1) * parseInt(limit);

		const bookings = await Booking.find(query)
			.sort({ createdAt: -1 })
			.skip(skip)
			.limit(parseInt(limit))
			.populate("userId", "name email mobile")
			.populate({
				path: "assignedNurse",
				select: "specialization user",
				populate: { path: "user", select: "name mobile" },
			})
			.populate("clinicId", "name address")
			.populate({
				path: "doctorId",
				select: "specialization user",
				populate: { path: "user", select: "name mobile" },
			});

		const total = await Booking.countDocuments(query);

		res.status(200).json({
			success: true,
			bookings,
			pagination: {
				total,
				page: parseInt(page),
				pages: Math.ceil(total / parseInt(limit)),
			},
		});
	} catch (error) {
		console.error("❌ Error fetching all bookings (Admin):", error);
		res.status(500).json({
			success: false,
			message: "Error fetching bookings",
			error: error.message,
		});
	}
};

