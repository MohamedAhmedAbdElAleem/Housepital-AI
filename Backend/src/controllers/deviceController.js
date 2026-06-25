const Device = require("../models/Device");
const DeviceVitalsLog = require("../models/DeviceVitalsLog");
const Booking = require("../models/Booking");
const { getIO, sendNotification } = require("../services/notificationService");
const { logEvents } = require("../middleware/logger");
const { processVitals } = require("../services/deviceVitalsService");

// ═══════════════════════════════════════════════════════════════════════════════
//  DEVICE REGISTRATION & MANAGEMENT
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * POST /api/device/register
 * Register a new ESP32 device and generate its API token.
 * Only admins can register new devices.
 */
const registerDevice = async (req, res) => {
	try {
		const { deviceId, deviceName, macAddress, firmwareVersion } = req.body;

		if (!deviceId || !/^HOSP-NODE-\d{3,6}$/.test(deviceId)) {
			return res.status(400).json({
				success: false,
				message:
					"Invalid deviceId. Format: HOSP-NODE-XXX (3-6 digits)",
			});
		}

		// Check if device already exists
		const existing = await Device.findOne({ deviceId });
		if (existing) {
			return res.status(409).json({
				success: false,
				message: `Device ${deviceId} already registered`,
			});
		}

		// Generate secure token
		const rawToken = Device.generateDeviceToken();
		const tokenHash = Device.hashToken(rawToken);

		const device = new Device({
			deviceId,
			deviceName: deviceName || `Patient Monitor ${deviceId}`,
			deviceToken: rawToken,
			deviceTokenHash: tokenHash,
			macAddress,
			firmwareVersion: firmwareVersion || "1.0.0",
		});

		await device.save();

		// Return the raw token ONCE — must be saved on the ESP32
		res.status(201).json({
			success: true,
			message: "Device registered successfully",
			data: {
				deviceId: device.deviceId,
				deviceName: device.deviceName,
				// ⚠️ This token is shown only once! Store it in ESP32 flash.
				token: rawToken,
				macAddress: device.macAddress,
			},
		});

		console.log(`🔧 New device registered: ${deviceId}`);
	} catch (error) {
		logEvents(`Register device error: ${error.message}`, "deviceErrLog.log");
		res.status(500).json({
			success: false,
			message: "Failed to register device",
			error: error.message,
		});
	}
};

/**
 * PUT /api/device/:deviceId/assign
 * Assign a device to a booking + patient + nurse.
 * Called by nurse when starting a monitoring session.
 */
const assignDevice = async (req, res) => {
	try {
		const { deviceId } = req.params;
		const { bookingId, patientId } = req.body;

		const device = await Device.findOne({ deviceId });
		if (!device) {
			return res.status(404).json({
				success: false,
				message: "Device not found",
			});
		}

		if (device.status === "active" && device.assignedBooking) {
			return res.status(409).json({
				success: false,
				message: `Device is already assigned to booking ${device.assignedBooking}`,
			});
		}

		// Validate booking exists and is in-progress
		const booking = await Booking.findById(bookingId);
		if (!booking) {
			return res.status(404).json({
				success: false,
				message: "Booking not found",
			});
		}

		device.assignedBooking = bookingId;
		device.assignedPatient = patientId || booking.patientId;
		device.assignedNurse = booking.assignedNurse;
		device.assignedAt = new Date();
		device.status = "active";
		device.totalSessions += 1;
		await device.save();

		// Emit to Socket.IO so Flutter apps know the device is assigned
		const io = getIO();
		if (io) {
			io.to(`patient_${device.assignedPatient}`).emit(
				"device:assigned",
				{
					deviceId,
					bookingId,
					assignedAt: device.assignedAt,
				}
			);
		}

		res.json({
			success: true,
			message: "Device assigned successfully",
			data: {
				deviceId: device.deviceId,
				bookingId,
				patientId: device.assignedPatient,
				nurseId: device.assignedNurse,
				status: device.status,
			},
		});

		console.log(
			`📎 Device ${deviceId} assigned to booking ${bookingId}`
		);
	} catch (error) {
		logEvents(`Assign device error: ${error.message}`, "deviceErrLog.log");
		res.status(500).json({
			success: false,
			message: "Failed to assign device",
			error: error.message,
		});
	}
};

/**
 * PUT /api/device/:deviceId/release
 * Release a device back to the pool (end monitoring session).
 */
const releaseDevice = async (req, res) => {
	try {
		const { deviceId } = req.params;

		const device = await Device.findOne({ deviceId });
		if (!device) {
			return res.status(404).json({
				success: false,
				message: "Device not found",
			});
		}

		const previousBooking = device.assignedBooking;
		await device.release();

		// Emit release event
		const io = getIO();
		if (io && previousBooking) {
			io.to(`booking_${previousBooking}`).emit("device:released", {
				deviceId,
				bookingId: previousBooking,
			});
		}

		res.json({
			success: true,
			message: "Device released to pool",
			data: { deviceId, status: "idle" },
		});

		console.log(`📎 Device ${deviceId} released to pool`);
	} catch (error) {
		logEvents(`Release device error: ${error.message}`, "deviceErrLog.log");
		res.status(500).json({
			success: false,
			message: "Failed to release device",
			error: error.message,
		});
	}
};

// ═══════════════════════════════════════════════════════════════════════════════
//  VITALS DATA INGESTION (called by ESP32)
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * POST /api/device/vitals
 * Receive vital signs from an ESP32 device.
 * This is the main endpoint called every 5 seconds by Task_Cloud.
 */
const receiveVitals = async (req, res) => {
	try {
		const device = req.device; // set by authenticateDevice middleware
		const payload = req.body;

		const result = await processVitals(device, payload);

		res.json({
			success: true,
			message: "Vitals received",
			data: result,
		});
	} catch (error) {
		logEvents(
			`Receive vitals error: ${error.message}`,
			"deviceErrLog.log"
		);
		res.status(error.message.includes("Missing") ? 400 : 500).json({
			success: false,
			message: "Failed to process vitals",
			error: error.message,
		});
	}
};

/**
 * POST /api/device/sos
 * Receive SOS alert from ESP32 (separate from vitals for low-latency).
 */
const receiveSOS = async (req, res) => {
	try {
		const device = req.device;
		const { active = true } = req.body;

		if (!device.assignedBooking) {
			return res.status(400).json({
				success: false,
				message: "Device not assigned to a booking",
			});
		}

		device.status = active ? "sos" : "active";
		await device.save();

		// Log the SOS event
		const sosLog = new DeviceVitalsLog({
			deviceId: device.deviceId,
			bookingId: device.assignedBooking,
			patientId: device.assignedPatient,
			nurseId: device.assignedNurse,
			sos: active,
			...device.lastVitals,
			receivedAt: new Date(),
		});
		await sosLog.save();

		// Emit immediately via Socket.IO
		const io = getIO();
		if (io) {
			io.to(`booking_${device.assignedBooking}`).emit("vitals:sos", {
				deviceId: device.deviceId,
				bookingId: device.assignedBooking,
				active,
				timestamp: new Date(),
			});
		}

		// Send push notification
		if (active) {
			const recipients = [
				device.assignedNurse,
				device.assignedPatient,
			].filter(Boolean);

			for (const userId of recipients) {
				await sendNotification({
					userId,
					title: "🚨 SOS Emergency Alert!",
					body: `Emergency button pressed on device ${device.deviceId}. Immediate attention required!`,
					titleAr: "🚨 تنبيه طوارئ SOS!",
					bodyAr: `تم الضغط على زر الطوارئ على الجهاز ${device.deviceId}. يتطلب اهتمام فوري!`,
					type: "sos_alert",
					referenceId: device.assignedBooking,
					referenceType: "booking",
					priority: "urgent",
					metadata: { deviceId: device.deviceId, sos: active },
				});
			}
		}

		res.json({
			success: true,
			message: active
				? "SOS alert activated"
				: "SOS alert deactivated",
		});

		console.log(
			`🚨 SOS ${active ? "ACTIVATED" : "DEACTIVATED"}: Device ${device.deviceId}`
		);
	} catch (error) {
		logEvents(`SOS error: ${error.message}`, "deviceErrLog.log");
		res.status(500).json({
			success: false,
			message: "Failed to process SOS",
			error: error.message,
		});
	}
};

// ═══════════════════════════════════════════════════════════════════════════════
//  DATA RETRIEVAL (called by Flutter apps)
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * GET /api/device/:bookingId/live
 * Get the latest vitals for a booking (polling fallback for Socket.IO).
 */
const getLiveVitals = async (req, res) => {
	try {
		const { bookingId } = req.params;

		const device = await Device.findOne({ assignedBooking: bookingId });
		if (!device) {
			return res.status(404).json({
				success: false,
				message: "No device assigned to this booking",
			});
		}

		res.json({
			success: true,
			data: {
				deviceId: device.deviceId,
				status: device.status,
				isOnline: device.isOnline(),
				connectionType: device.connectionType,
				vitals: device.lastVitals,
				lastSeenAt: device.lastSeenAt,
			},
		});
	} catch (error) {
		res.status(500).json({
			success: false,
			message: "Failed to get live vitals",
			error: error.message,
		});
	}
};

/**
 * GET /api/device/:bookingId/history
 * Get vitals history for a booking session.
 */
const getVitalsHistory = async (req, res) => {
	try {
		const { bookingId } = req.params;
		const { limit = 100, from, to } = req.query;

		const query = { bookingId };
		if (from || to) {
			query.receivedAt = {};
			if (from) query.receivedAt.$gte = new Date(from);
			if (to) query.receivedAt.$lte = new Date(to);
		}

		const logs = await DeviceVitalsLog.find(query)
			.sort({ receivedAt: -1 })
			.limit(parseInt(limit))
			.lean();

		res.json({
			success: true,
			data: {
				bookingId,
				count: logs.length,
				vitals: logs,
			},
		});
	} catch (error) {
		res.status(500).json({
			success: false,
			message: "Failed to get vitals history",
			error: error.message,
		});
	}
};

/**
 * GET /api/device/:bookingId/summary
 * Get aggregated vitals summary for a booking session.
 */
const getVitalsSummary = async (req, res) => {
	try {
		const { bookingId } = req.params;

		const summary = await DeviceVitalsLog.getSessionSummary(bookingId);

		if (!summary || summary.length === 0) {
			return res.status(404).json({
				success: false,
				message: "No vitals data found for this booking",
			});
		}

		res.json({
			success: true,
			data: summary[0],
		});
	} catch (error) {
		res.status(500).json({
			success: false,
			message: "Failed to get vitals summary",
			error: error.message,
		});
	}
};

/**
 * GET /api/device/list
 * List all devices (for admin device management).
 */
const listDevices = async (req, res) => {
	try {
		const { status, page = 1, limit = 20 } = req.query;

		const query = {};
		if (status) query.status = status;

		const devices = await Device.find(query)
			.select("-deviceToken -deviceTokenHash")
			.sort({ lastSeenAt: -1 })
			.skip((page - 1) * limit)
			.limit(parseInt(limit))
			.populate("assignedNurse", "user")
			.populate("assignedPatient", "fullName email")
			.lean();

		const total = await Device.countDocuments(query);

		// Add online status
		const enriched = devices.map((d) => ({
			...d,
			isOnline:
				d.lastSeenAt &&
				new Date(d.lastSeenAt) >= new Date(Date.now() - 30000),
		}));

		res.json({
			success: true,
			data: {
				devices: enriched,
				pagination: {
					page: parseInt(page),
					limit: parseInt(limit),
					total,
					pages: Math.ceil(total / limit),
				},
			},
		});
	} catch (error) {
		res.status(500).json({
			success: false,
			message: "Failed to list devices",
			error: error.message,
		});
	}
};

/**
 * GET /api/device/:deviceId/info
 * Get detailed info about a specific device.
 */
const getDeviceInfo = async (req, res) => {
	try {
		const { deviceId } = req.params;

		const device = await Device.findOne({ deviceId })
			.select("-deviceToken -deviceTokenHash")
			.populate("assignedBooking", "status serviceName patientName")
			.populate("assignedPatient", "fullName email phone")
			.lean();

		if (!device) {
			return res.status(404).json({
				success: false,
				message: "Device not found",
			});
		}

		res.json({
			success: true,
			data: {
				...device,
				isOnline:
					device.lastSeenAt &&
					new Date(device.lastSeenAt) >=
						new Date(Date.now() - 30000),
			},
		});
	} catch (error) {
		res.status(500).json({
			success: false,
			message: "Failed to get device info",
			error: error.message,
		});
	}
};

module.exports = {
	registerDevice,
	assignDevice,
	releaseDevice,
	receiveVitals,
	receiveSOS,
	getLiveVitals,
	getVitalsHistory,
	getVitalsSummary,
	listDevices,
	getDeviceInfo,
};
