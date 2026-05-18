const Device = require("../models/Device");
const { logEvents } = require("./logger");

// ─── Device Token Authentication Middleware ──────────────────────────────────
// ESP32 devices authenticate using a pre-shared API token.
// Token is sent in the `X-Device-Token` header.

const authenticateDevice = async (req, res, next) => {
	try {
		const token = req.headers["x-device-token"];

		if (!token) {
			console.warn(`[Device Auth] ⚠️ Missing token from ${req.ip}`);
			return res.status(401).json({
				success: false,
				message: "Device authentication required. Missing X-Device-Token header.",
			});
		}

		// Look up device by hashed token
		const device = await Device.findByToken(token);

		if (!device) {
			console.error(`[Device Auth] ❌ Invalid token attempt from ${req.ip}. Token starts with: ${token.substring(0, 6)}...`);
			logEvents(
				`Invalid device token attempt from IP: ${req.ip}`,
				"deviceAuthLog.log"
			);
			return res.status(403).json({
				success: false,
				message: "Invalid device token",
			});
		}

		// Attach device info to request
		req.device = device;
		req.deviceId = device.deviceId;

		// Update connectivity metadata
		device.lastSeenAt = new Date();
		device.ipAddress = req.ip;
		await device.save();

		next();
	} catch (error) {
		console.error(`[Device Auth] 🔥 System error: ${error.message}`);
		logEvents(
			`Device auth error: ${error.message}`,
			"deviceAuthLog.log"
		);

		return res.status(500).json({
			success: false,
			message: "Device authentication error",
		});
	}
};

// ─── Rate Limiter for Device Endpoints ───────────────────────────────────────
// Increased limit to 1.5 seconds to allow SOS + Vitals in sequence
const deviceRateLimits = new Map();

const deviceRateLimit = (req, res, next) => {
	const deviceId = req.device?.deviceId || req.ip;
	const now = Date.now();
	const minInterval = 1500; // 1.5 seconds (was 3s)

	const lastRequest = deviceRateLimits.get(deviceId);
	if (lastRequest && now - lastRequest < minInterval) {
		console.warn(`[Rate Limit] 🚦 Blocked ${deviceId} - too frequent`);
		return res.status(429).json({
			success: false,
			message: "Too many requests. Min interval: 1.5 seconds.",
		});
	}

	deviceRateLimits.set(deviceId, now);

	// Clean up old entries
	if (deviceRateLimits.size > 1000) {
		const cutoff = now - 60000;
		for (const [key, time] of deviceRateLimits) {
			if (time < cutoff) deviceRateLimits.delete(key);
		}
	}

	next();
};

module.exports = {
	authenticateDevice,
	deviceRateLimit,
};
