const express = require("express");
const router = express.Router();
const {
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
} = require("../controllers/deviceController");
const { authenticateToken, authorizeRole } = require("../middleware/authMiddleware");
const { authenticateDevice, deviceRateLimit } = require("../middleware/deviceAuth");

// ═══════════════════════════════════════════════════════════════════════════════
//  ESP32 DEVICE ENDPOINTS (authenticated via X-Device-Token header)
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * @openapi
 * /api/device/vitals:
 *   post:
 *     tags:
 *       - Device
 *     summary: Receive vital signs from ESP32 device
 */
router.post("/vitals", authenticateDevice, deviceRateLimit, receiveVitals);

/**
 * @openapi
 * /api/device/sos:
 *   post:
 *     tags:
 *       - Device
 *     summary: Receive SOS alert from ESP32
 */
router.post("/sos", authenticateDevice, receiveSOS);

// ═══════════════════════════════════════════════════════════════════════════════
//  ADMIN / NURSE ENDPOINTS (authenticated via JWT Bearer token)
// ═══════════════════════════════════════════════════════════════════════════════

/**
 * @openapi
 * /api/device/register:
 *   post:
 *     tags:
 *       - Device
 *     summary: Register a new ESP32 device (admin only)
 */
router.post("/register", authenticateToken, authorizeRole("admin"), registerDevice);

/**
 * @openapi
 * /api/device/list:
 *   get:
 *     tags:
 *       - Device
 *     summary: List all registered devices (admin/nurse)
 */
router.get(
	"/list",
	authenticateToken,
	authorizeRole("admin", "nurse"),
	listDevices
);

/**
 * @openapi
 * /api/device/{deviceId}/assign:
 *   put:
 *     tags:
 *       - Device
 *     summary: Assign device to a booking (nurse/admin)
 */
router.put(
	"/:deviceId/assign",
	authenticateToken,
	authorizeRole("nurse", "admin"),
	assignDevice
);

/**
 * @openapi
 * /api/device/{deviceId}/release:
 *   put:
 *     tags:
 *       - Device
 *     summary: Release device back to pool (nurse/admin)
 */
router.put(
	"/:deviceId/release",
	authenticateToken,
	authorizeRole("nurse", "admin"),
	releaseDevice
);

/**
 * @openapi
 * /api/device/{deviceId}/info:
 *   get:
 *     tags:
 *       - Device
 *     summary: Get detailed device info
 */
router.get("/:deviceId/info", authenticateToken, getDeviceInfo);

/**
 * @openapi
 * /api/device/{bookingId}/live:
 *   get:
 *     tags:
 *       - Device
 *     summary: Get latest vitals for a booking (polling fallback)
 */
router.get("/:bookingId/live", authenticateToken, getLiveVitals);

/**
 * @openapi
 * /api/device/{bookingId}/history:
 *   get:
 *     tags:
 *       - Device
 *     summary: Get vitals history for a booking
 */
router.get("/:bookingId/history", authenticateToken, getVitalsHistory);

/**
 * @openapi
 * /api/device/{bookingId}/summary:
 *   get:
 *     tags:
 *       - Device
 *     summary: Get aggregated vitals summary for a booking session
 */
router.get("/:bookingId/summary", authenticateToken, getVitalsSummary);

module.exports = router;
