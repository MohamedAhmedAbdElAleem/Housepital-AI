const mongoose = require("mongoose");

// ─── Device Vitals Log ───────────────────────────────────────────────────────
// Time-series log of every vital reading received from an ESP32 device.
// Used for charting, analytics, and auto-filling visit reports.

const deviceVitalsLogSchema = new mongoose.Schema(
	{
		// ── Links ────────────────────────────────────────────────────────────
		deviceId: {
			type: String,
			required: true,
			index: true,
		},
		bookingId: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "Booking",
			required: true,
			index: true,
		},
		patientId: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "User",
			required: true,
		},
		nurseId: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "Nurse",
		},

		// ── Vital Readings ───────────────────────────────────────────────────
		temperature: {
			type: Number,
			default: null,
		},
		heartRate: {
			type: Number,
			default: null,
		},
		oxygenSaturation: {
			type: Number,
			default: null,
		},

		// ── Classification (auto-computed) ───────────────────────────────────
		temperatureStatus: {
			type: String,
			enum: ["normal", "high", "low", "critical"],
			default: "normal",
		},
		heartRateStatus: {
			type: String,
			enum: ["normal", "high", "low", "critical"],
			default: "normal",
		},
		oxygenSaturationStatus: {
			type: String,
			enum: ["normal", "low", "critical"],
			default: "normal",
		},

		// ── Sensor State ─────────────────────────────────────────────────────
		fingerDetected: {
			type: Boolean,
			default: false,
		},
		sensorFault: {
			type: Boolean,
			default: false,
		},
		sos: {
			type: Boolean,
			default: false,
		},

		// ── Connection Info ──────────────────────────────────────────────────
		connectionType: {
			type: String,
			enum: ["wifi", "ble"],
			default: "wifi",
		},
		rssi: {
			type: Number, // WiFi signal strength (dBm)
			default: null,
		},

		// ── Device Timestamp ─────────────────────────────────────────────────
		deviceTimestamp: {
			type: Number, // millis() from ESP32
			default: null,
		},
		receivedAt: {
			type: Date,
			default: Date.now,
			index: true,
		},
	},
	{
		timestamps: false, // we use receivedAt instead
		// Optimize for time-series queries
		timeseries: undefined, // MongoDB Atlas time-series is optional
	}
);

// ─── Compound Indexes for Efficient Queries ──────────────────────────────────
// Fetch vitals for a specific booking, ordered by time
deviceVitalsLogSchema.index({ bookingId: 1, receivedAt: -1 });
// Fetch vitals for a specific patient across all bookings
deviceVitalsLogSchema.index({ patientId: 1, receivedAt: -1 });
// Find anomalous readings quickly
deviceVitalsLogSchema.index({ bookingId: 1, sos: 1, receivedAt: -1 });
// TTL index: auto-delete raw logs older than 90 days to save storage
deviceVitalsLogSchema.index(
	{ receivedAt: 1 },
	{ expireAfterSeconds: 90 * 24 * 60 * 60 }
);

// ─── Classification Helpers (reuse from VisitReport) ─────────────────────────
function classifyHeartRate(hr) {
	if (!hr) return "normal";
	if (hr < 40 || hr > 150) return "critical";
	if (hr < 60) return "low";
	if (hr > 100) return "high";
	return "normal";
}

function classifyTemperature(temp) {
	if (!temp) return "normal";
	if (temp < 35 || temp > 39.5) return "critical";
	if (temp < 36.1) return "low";
	if (temp > 37.5) return "high";
	return "normal";
}

function classifySpO2(spo2) {
	if (!spo2) return "normal";
	if (spo2 < 90) return "critical";
	if (spo2 < 95) return "low";
	return "normal";
}

// ─── Pre-save: auto-classify vitals ──────────────────────────────────────────
deviceVitalsLogSchema.pre("save", function (next) {
	if (this.temperature != null) {
		this.temperatureStatus = classifyTemperature(this.temperature);
	}
	if (this.heartRate != null) {
		this.heartRateStatus = classifyHeartRate(this.heartRate);
	}
	if (this.oxygenSaturation != null) {
		this.oxygenSaturationStatus = classifySpO2(this.oxygenSaturation);
	}
	next();
});

// ─── Static Helpers ──────────────────────────────────────────────────────────

/**
 * Get the latest N readings for a booking
 */
deviceVitalsLogSchema.statics.getLatestForBooking = function (
	bookingId,
	limit = 50
) {
	return this.find({ bookingId })
		.sort({ receivedAt: -1 })
		.limit(limit)
		.lean();
};

/**
 * Get vitals summary (averages + min/max) for a booking session
 */
deviceVitalsLogSchema.statics.getSessionSummary = function (bookingId) {
	return this.aggregate([
		{ $match: { bookingId: new mongoose.Types.ObjectId(bookingId) } },
		{
			$group: {
				_id: null,
				avgTemp: { $avg: "$temperature" },
				minTemp: { $min: "$temperature" },
				maxTemp: { $max: "$temperature" },
				avgHR: { $avg: "$heartRate" },
				minHR: { $min: "$heartRate" },
				maxHR: { $max: "$heartRate" },
				avgSpO2: { $avg: "$oxygenSaturation" },
				minSpO2: { $min: "$oxygenSaturation" },
				maxSpO2: { $max: "$oxygenSaturation" },
				totalReadings: { $sum: 1 },
				sosEvents: {
					$sum: { $cond: [{ $eq: ["$sos", true] }, 1, 0] },
				},
				faultEvents: {
					$sum: { $cond: [{ $eq: ["$sensorFault", true] }, 1, 0] },
				},
				firstReading: { $min: "$receivedAt" },
				lastReading: { $max: "$receivedAt" },
			},
		},
	]);
};

// Export classification helpers for use in controller
deviceVitalsLogSchema.statics.classifyHeartRate = classifyHeartRate;
deviceVitalsLogSchema.statics.classifyTemperature = classifyTemperature;
deviceVitalsLogSchema.statics.classifySpO2 = classifySpO2;

module.exports = mongoose.model("DeviceVitalsLog", deviceVitalsLogSchema);
