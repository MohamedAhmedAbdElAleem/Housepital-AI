const express = require("express");
const router = express.Router();
const { authenticateToken } = require("../middleware/authMiddleware");
const {
	createBooking,
	getMyBookings,
	getBookingById,
	cancelBooking,
	updateBookingStatus,
	getNursePendingBookings,
	getNurseActiveBooking,
	acceptBooking,
	verifyPinAndStartVisit,
	completeVisit,
} = require("../controllers/bookingController");

// All booking routes require authentication
/**
 * @openapi
 * /api/bookings/create:
 *   post:
 *     tags:
 *       - Bookings
 *     summary: Create New Booking
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - serviceType
 *               - startDate
 *             properties:
 *               serviceType:
 *                 type: string
 *               startDate:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       201:
 *         description: Booking created
 */
router.post("/create", authenticateToken, createBooking);

/**
 * @openapi
 * /api/bookings/my-bookings:
 *   get:
 *     tags:
 *       - Bookings
 *     summary: Get My Bookings
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of bookings
 */
router.get("/my-bookings", authenticateToken, getMyBookings);

// ============ NURSE SPECIFIC ROUTES ============

/**
 * @openapi
 * /api/bookings/nurse/pending:
 *   get:
 *     tags:
 *       - Bookings (Nurse)
 *     summary: Get pending bookings for nurses
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of pending bookings
 */
router.get("/nurse/pending", authenticateToken, getNursePendingBookings);

/**
 * @openapi
 * /api/bookings/nurse/active:
 *   get:
 *     tags:
 *       - Bookings (Nurse)
 *     summary: Get nurse's active booking
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Active booking if any
 */
router.get("/nurse/active", authenticateToken, getNurseActiveBooking);

/**
 * @openapi
 * /api/bookings/{id}/accept:
 *   post:
 *     tags:
 *       - Bookings (Nurse)
 *     summary: Accept a booking
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Booking accepted
 */
router.post("/:id/accept", authenticateToken, acceptBooking);

/**
 * @openapi
 * /api/bookings/{id}/verify-pin:
 *   post:
 *     tags:
 *       - Bookings (Nurse)
 *     summary: Verify PIN and start visit
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - pin
 *             properties:
 *               pin:
 *                 type: string
 *     responses:
 *       200:
 *         description: Visit started
 */
router.post("/:id/verify-pin", authenticateToken, verifyPinAndStartVisit);

/**
 * @openapi
 * /api/bookings/{id}/complete:
 *   post:
 *     tags:
 *       - Bookings (Nurse)
 *     summary: Complete visit
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Visit completed
 */
router.post("/:id/complete", authenticateToken, completeVisit);

// ============ END NURSE ROUTES ============

/**
 * @openapi
 * /api/bookings/{id}:
 *   get:
 *     tags:
 *       - Bookings
 *     summary: Get Booking By ID
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Booking details
 *       404:
 *         description: Booking not found
 */
router.get("/:id", authenticateToken, getBookingById);

/**
 * @openapi
 * /api/bookings/{id}/cancel:
 *   put:
 *     tags:
 *       - Bookings
 *     summary: Cancel Booking
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Booking cancelled
 */
router.put("/:id/cancel", authenticateToken, cancelBooking);

/**
 * @openapi
 * /api/bookings/{id}/status:
 *   put:
 *     tags:
 *       - Bookings
 *     summary: Update Booking Status (Admin/Employee)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *     responses:
 *       200:
 *         description: Booking status updated
 */
router.put("/:id/status", authenticateToken, updateBookingStatus);

module.exports = router;
