const mongoose = require("mongoose");
const crypto = require("crypto");

// ─── Device Schema ───────────────────────────────────────────────────────────
// Represents a physical ESP32 patient monitor device.
// Devices are pooled — nurses carry them and assign them to patients per visit.

const deviceSchema = new mongoose.Schema(
	{
		// ── Identity ─────────────────────────────────────────────────────────
		deviceId: {
			type: String,
			unique: true,
			required: true,
			trim: true,
			match: /^HOSP-NODE-\d{3,6}$/,
			// e.g. "HOSP-NODE-001"
		},
		deviceName: {
			type: String,
			trim: true,
			default: function () {
				return `Patient Monitor ${this.deviceId}`;
			},
		},
		deviceToken: {
			type: String,
			required: true,
			select: false, // never returned in queries by default
		},
		deviceTokenHash: {
			type: String,
			required: true,
			index: true,
		},
		firmwareVersion: {
			type: String,
			default: "1.0.0",
		},

		// ── Assignment (pool model) ──────────────────────────────────────────
		assignedBooking: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "Booking",
			default: null,
		},
		assignedNurse: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "Nurse",
			default: null,
		},
		assignedPatient: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "User",
			default: null,
		},
		assignedAt: {
			type: Date,
			default: null,
		},

		// ── Status ───────────────────────────────────────────────────────────
		status: {
			type: String,
			enum: ["idle", "active", "sos", "offline", "fault"],
			default: "idle",
			index: true,
		},
		connectionType: {
			type: String,
			enum: ["wifi", "ble", "none"],
			default: "none",
		},

		// ── Last Known Vitals (cached for quick access) ──────────────────────
		lastVitals: {
			temperature: { type: Number, default: null },
			heartRate: { type: Number, default: null },
			oxygenSaturation: { type: Number, default: null },
			fingerDetected: { type: Boolean, default: false },
			sensorFault: { type: Boolean, default: false },
			receivedAt: { type: Date, default: null },
		},

		// ── Connectivity ─────────────────────────────────────────────────────
		lastSeenAt: {
			type: Date,
			default: null,
		},
		ipAddress: {
			type: String,
			default: null,
		},
		macAddress: {
			type: String,
			trim: true,
			match: /^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$/,
		},

		// ── Statistics ───────────────────────────────────────────────────────
		totalSessions: {
			type: Number,
			default: 0,
		},
		totalReadings: {
			type: Number,
			default: 0,
		},
		lastMaintenanceAt: {
			type: Date,
			default: null,
		},
	},
	{ timestamps: true }
);

// ─── Indexes ─────────────────────────────────────────────────────────────────
deviceSchema.index({ status: 1, lastSeenAt: -1 });
deviceSchema.index({ assignedBooking: 1 });
deviceSchema.index({ assignedNurse: 1 });

// ─── Static: Generate a secure device token ──────────────────────────────────
deviceSchema.statics.generateDeviceToken = function () {
	return crypto.randomBytes(32).toString("hex");
};

// ─── Static: Hash a token for storage/lookup ─────────────────────────────────
deviceSchema.statics.hashToken = function (token) {
	return crypto.createHash("sha256").update(token).digest("hex");
};

// ─── Static: Find device by raw token ────────────────────────────────────────
deviceSchema.statics.findByToken = async function (token) {
	const hash = this.hashToken(token);
	return this.findOne({ deviceTokenHash: hash });
};

// ─── Instance: Check if device is considered online (seen in last 30s) ───────
deviceSchema.methods.isOnline = function () {
	if (!this.lastSeenAt) return false;
	const thirtySecondsAgo = new Date(Date.now() - 30 * 1000);
	return this.lastSeenAt >= thirtySecondsAgo;
};

// ─── Instance: Release assignment (return to pool) ───────────────────────────
deviceSchema.methods.release = async function () {
	this.assignedBooking = null;
	this.assignedNurse = null;
	this.assignedPatient = null;
	this.assignedAt = null;
	this.status = "idle";
	this.lastVitals = {
		temperature: null,
		heartRate: null,
		oxygenSaturation: null,
		fingerDetected: false,
		sensorFault: false,
		receivedAt: null,
	};
	return this.save();
};

module.exports = mongoose.model("Device", deviceSchema);
