const express = require("express");
const { requestOTP, verifyOTP, resendOTP, resetPassword, verifyAccount } = require("../controllers/otpController.js");

const router = express.Router();

// OTP endpoints
/**
 * @openapi
 * /api/otp/request:
 *   post:
 *     tags:
 *       - OTP
 *     summary: Request an OTP
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: OTP sent successfully
 */
router.post("/request", requestOTP);

/**
 * @openapi
 * /api/otp/verify:
 *   post:
 *     tags:
 *       - OTP
 *     summary: Verify OTP
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - otp
 *             properties:
 *               email:
 *                 type: string
 *               otp:
 *                 type: string
 *     responses:
 *       200:
 *         description: OTP verified successfully
 */
router.post("/verify", verifyOTP);

/**
 * @openapi
 * /api/otp/resend:
 *   post:
 *     tags:
 *       - OTP
 *     summary: Resend OTP
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: OTP resent successfully
 */
router.post("/resend", resendOTP);

/**
 * @openapi
 * /api/otp/reset-password:
 *   patch:
 *     tags:
 *       - OTP
 *     summary: Reset Password using OTP
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - otp
 *               - newPassword
 *             properties:
 *               email:
 *                 type: string
 *               otp:
 *                 type: string
 *               newPassword:
 *                 type: string
 *     responses:
 *       200:
 *         description: Password reset successfully
 */
router.patch("/reset-password", resetPassword);

/**
 * @openapi
 * /api/otp/verify-account:
 *   post:
 *     tags:
 *       - OTP
 *     summary: Verify Account (Alternative)
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - otp
 *             properties:
 *               email:
 *                 type: string
 *               otp:
 *                 type: string
 *     responses:
 *       200:
 *         description: Account verified successfully
 */
router.post("/verify-account", verifyAccount);

module.exports = router;