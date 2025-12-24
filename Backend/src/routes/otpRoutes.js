const express = require("express");
const { requestOTP, verifyOTP, resendOTP, resetPassword } = require("../controllers/otpController.js");

const router = express.Router();

// OTP endpoints
router.post("/request", requestOTP);
router.post("/verify", verifyOTP);
router.post("/resend", resendOTP);
router.patch("/reset-password", resetPassword);

module.exports = router;