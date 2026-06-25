const DeviceVitalsLog = require("../models/DeviceVitalsLog");
const Vital = require("../models/Vital");
const { sendNotification, getIO } = require("./notificationService");
const { logEvents } = require("../middleware/logger");

/**
 * Processes incoming vitals from any source (HTTP or WebSocket)
 */
const processVitals = async (device, payload) => {
	const {
		vitals,
		sos = false,
		connectionType = "wifi",
		rssi,
		deviceTimestamp,
	} = payload;

	if (!vitals) {
		throw new Error("Missing vitals data");
	}

	const { temperature, heartRate, oxygenSaturation, fingerDetected, sensorFault } = vitals;

	if (!device.assignedBooking) {
		throw new Error("Device is not assigned to a booking.");
	}

	// ── 1. Log to time-series collection ─────────────────────────────
	const vitalsLog = new DeviceVitalsLog({
		deviceId: device.deviceId,
		bookingId: device.assignedBooking,
		patientId: device.assignedPatient,
		nurseId: device.assignedNurse,
		temperature,
		heartRate,
		oxygenSaturation,
		fingerDetected: fingerDetected ?? false,
		sensorFault: sensorFault ?? false,
		sos,
		connectionType,
		rssi,
		deviceTimestamp,
		receivedAt: new Date(),
	});
	await vitalsLog.save();

	// ── 2. Update device cached vitals ───────────────────────────────
	device.lastVitals = {
		temperature,
		heartRate,
		oxygenSaturation,
		fingerDetected: fingerDetected ?? false,
		sensorFault: sensorFault ?? false,
		receivedAt: new Date(),
	};
	device.status = sos ? "sos" : sensorFault ? "fault" : "active";
	device.connectionType = connectionType;
	device.totalReadings += 1;
	await device.save();

	// ── 3. Save to Vital model (for patient medical records) ─────────
	if (fingerDetected && !sensorFault) {
		const vitalsToSave = [];

		if (temperature != null && temperature >= 0 && temperature <= 100) {
			vitalsToSave.push({
				patientId: device.assignedPatient,
				type: "Temperature",
				value: String(temperature.toFixed(1)),
				unit: "°C",
				status: vitalsLog.temperatureStatus,
				measuredAt: new Date(),
				notes: `Auto-recorded by device ${device.deviceId}`,
			});
		}
		if (heartRate != null && heartRate >= 40 && heartRate <= 150) {
			vitalsToSave.push({
				patientId: device.assignedPatient,
				type: "Heart Rate",
				value: String(heartRate),
				unit: "bpm",
				status: vitalsLog.heartRateStatus,
				measuredAt: new Date(),
				notes: `Auto-recorded by device ${device.deviceId}`,
			});
		}
		if (
			oxygenSaturation != null &&
			oxygenSaturation >= 80 &&
			oxygenSaturation <= 100
		) {
			vitalsToSave.push({
				patientId: device.assignedPatient,
				type: "Oxygen Saturation",
				value: String(oxygenSaturation),
				unit: "%",
				status: vitalsLog.oxygenSaturationStatus,
				measuredAt: new Date(),
				notes: `Auto-recorded by device ${device.deviceId}`,
			});
		}

		if (vitalsToSave.length > 0) {
			await Vital.insertMany(vitalsToSave);
		}
	}

	// ── 4. Emit real-time to Socket.IO ───────────────────────────────
	const io = getIO();
	if (io) {
		const updatePayload = {
			deviceId: device.deviceId,
			bookingId: device.assignedBooking,
			vitals: {
				temperature,
				heartRate,
				oxygenSaturation,
				fingerDetected,
				sensorFault,
			},
			classification: {
				temperatureStatus: vitalsLog.temperatureStatus,
				heartRateStatus: vitalsLog.heartRateStatus,
				oxygenSaturationStatus: vitalsLog.oxygenSaturationStatus,
			},
			sos,
			connectionType,
			timestamp: new Date(),
		};

		io.to(`booking_${device.assignedBooking}`).emit("vitals:update", updatePayload);

		if (device.assignedNurse) {
			io.to(`nurse_${device.assignedNurse}`).emit("vitals:update", updatePayload);
		}
		if (device.assignedPatient) {
			io.to(`patient_${device.assignedPatient}`).emit("vitals:update", updatePayload);
		}
	}

	// ── 5. Critical Alert Logic ──────────────────────────────────────
	const alerts = [];
	if (sos) {
		alerts.push("🚨 SOS ALERT activated by patient!");
	}
	if (vitalsLog.heartRateStatus === "critical" && heartRate != null) {
		alerts.push(`❤️ CRITICAL Heart Rate: ${heartRate} bpm`);
	}
	if (vitalsLog.oxygenSaturationStatus === "critical" && oxygenSaturation != null) {
		alerts.push(`🫁 CRITICAL Oxygen Saturation: ${oxygenSaturation}%`);
	}
	if (vitalsLog.temperatureStatus === "critical" && temperature != null) {
		alerts.push(`🌡️ CRITICAL Temperature: ${temperature}°C`);
	}

	if (alerts.length > 0) {
		const alertMessage = alerts.join(" | ");
		console.log(`🚨 [CRITICAL] Device ${device.deviceId}: ${alertMessage}`);

		try {
			const notificationPromises = [];
			
			if (device.assignedNurse) {
				notificationPromises.push(sendNotification({
					userId: device.assignedNurse,
					title: "⚠️ Critical Vitals Alert",
					body: alertMessage,
					titleAr: "⚠️ تنبيه مؤشرات حيوية حرجة",
					bodyAr: alertMessage,
					type: "critical_vitals",
					referenceId: device.assignedBooking,
					referenceType: "booking",
					priority: "urgent",
					metadata: {
						deviceId: device.deviceId,
						vitals: { temperature, heartRate, oxygenSaturation },
						sos,
					},
				}));
			}

			if (device.assignedPatient) {
				notificationPromises.push(sendNotification({
					userId: device.assignedPatient,
					title: "⚠️ Health Alert",
					body: alertMessage,
					titleAr: "⚠️ تنبيه صحي",
					bodyAr: alertMessage,
					type: "critical_vitals",
					referenceId: device.assignedBooking,
					referenceType: "booking",
					priority: "urgent",
					metadata: {
						deviceId: device.deviceId,
						vitals: { temperature, heartRate, oxygenSaturation },
						sos,
					},
				}));
			}

			await Promise.all(notificationPromises);
		} catch (notifError) {
			console.error(`❌ Error sending notification: ${notifError.message}`);
			logEvents(`Notification error for ${device.deviceId}: ${notifError.message}`, "deviceErrLog.log");
		}

		if (io) {
			io.to(`booking_${device.assignedBooking}`).emit("vitals:critical", {
				deviceId: device.deviceId,
				bookingId: device.assignedBooking,
				alerts,
				vitals: { temperature, heartRate, oxygenSaturation },
				sos,
				timestamp: new Date(),
			});
		}
	}

	return {
		logId: vitalsLog._id,
		classification: {
			temperatureStatus: vitalsLog.temperatureStatus,
			heartRateStatus: vitalsLog.heartRateStatus,
			oxygenSaturationStatus: vitalsLog.oxygenSaturationStatus,
		},
		alertsTriggered: alerts.length,
	};
};

module.exports = { processVitals };
