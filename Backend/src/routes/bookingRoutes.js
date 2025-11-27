const express = require("express");
const router = express.Router();
const { authenticateToken } = require("../middleware/authMiddleware");
const {
	createBooking,
	getMyBookings,
	getBookingById,
	cancelBooking,
	updateBookingStatus,
} = require("../controllers/bookingController");

// All booking routes require authentication
router.post("/create", authenticateToken, createBooking);
router.get("/my-bookings", authenticateToken, getMyBookings);
router.get("/:id", authenticateToken, getBookingById);
router.put("/:id/cancel", authenticateToken, cancelBooking);
router.put("/:id/status", authenticateToken, updateBookingStatus);

module.exports = router;
