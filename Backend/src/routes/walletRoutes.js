/**
 * Wallet Routes
 *
 * Protected routes require JWT authentication.
 * The PayMob callback endpoint is public but HMAC-verified.
 */

const express = require("express");
const router = express.Router();
const walletController = require("../controllers/walletController");
const { authenticateToken, authorizeRole } = require("../middleware/authMiddleware");

// ── Protected Routes (JWT required) ──────────────────────────

// Get wallet balance & status
router.get("/balance", authenticateToken, walletController.getBalance);

// Get transaction history (paginated)
router.get("/transactions", authenticateToken, walletController.getTransactions);

// Initiate PayMob recharge (nurses & doctors only)
router.post(
    "/recharge/initiate",
    authenticateToken,
    authorizeRole("nurse", "doctor"),
    walletController.initiateRecharge
);

// Check recharge status
router.get(
    "/recharge/status/:orderId",
    authenticateToken,
    walletController.getRechargeStatus
);

// ── Public Routes (HMAC-verified) ────────────────────────────

// PayMob webhook callback
router.post("/recharge/callback", walletController.rechargeCallback);

module.exports = router;
