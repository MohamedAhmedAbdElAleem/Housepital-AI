/**
 * Wallet Routes
 *
 * Receipt-based wallet recharge system.
 * All routes require JWT authentication.
 * Admin routes additionally require the "admin" role.
 */

const express = require("express");
const router = express.Router();
const walletController = require("../controllers/walletController");
const { authenticateToken, authorizeRole } = require("../middleware/authMiddleware");

// ── User Routes (all authenticated users) ────────────────────

// Get wallet balance & status
router.get("/balance", authenticateToken, walletController.getBalance);

// Get transaction history (paginated)
router.get("/transactions", authenticateToken, walletController.getTransactions);

// Get payment info (Instapay / Mobile Wallet details)
router.get("/payment-info", authenticateToken, walletController.getPaymentInfo);

// Submit a recharge receipt
router.post("/receipts/submit", authenticateToken, walletController.submitReceipt);

// Get my receipts (history with statuses)
router.get("/receipts/my", authenticateToken, walletController.getMyReceipts);

// ── Admin Routes ─────────────────────────────────────────────

// Get all pending receipts (admin review queue)
router.get(
	"/receipts/pending",
	authenticateToken,
	authorizeRole("admin"),
	walletController.getPendingReceipts
);

// Get all receipts (paginated, filterable)
router.get(
	"/receipts/all",
	authenticateToken,
	authorizeRole("admin"),
	walletController.getAllReceipts
);

// Review a receipt (approve / reject)
router.put(
	"/receipts/:id/review",
	authenticateToken,
	authorizeRole("admin"),
	walletController.reviewReceipt
);

module.exports = router;
