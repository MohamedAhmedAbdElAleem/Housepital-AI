/**
 * Wallet Controller
 *
 * Handles all wallet-related API endpoints:
 * - Balance retrieval
 * - Transaction history
 * - PayMob recharge initiation (Card + Mobile Wallet)
 * - PayMob webhook callback handling
 * - Recharge status checking
 */

const User = require("../models/User");
const Transaction = require("../models/Transaction");
const walletService = require("../services/walletService");
const paymobService = require("../services/paymobService");

/**
 * @desc    Get wallet balance and status
 * @route   GET /api/wallet/balance
 * @access  Private
 */
exports.getBalance = async (req, res) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			return res.status(401).json({ success: false, message: "Not authenticated" });
		}

		const walletData = await walletService.getWalletBalance(userId);

		res.status(200).json({
			success: true,
			data: {
				balance: walletData.balance,
				walletBlocked: walletData.walletBlocked,
				walletBlockReason: walletData.walletBlockReason,
				role: walletData.role,
				threshold: walletService.WALLET_THRESHOLD,
				commissionRate:
					walletData.role === "nurse"
						? walletService.NURSE_COMMISSION_RATE
						: walletData.role === "doctor"
							? walletService.DOCTOR_COMMISSION_RATE
							: 0,
			},
		});
	} catch (error) {
		console.error("❌ Error fetching wallet balance:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching wallet balance",
			error: error.message,
		});
	}
};

/**
 * @desc    Get transaction history (paginated)
 * @route   GET /api/wallet/transactions?page=1&limit=20
 * @access  Private
 */
exports.getTransactions = async (req, res) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			return res.status(401).json({ success: false, message: "Not authenticated" });
		}

		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 20;

		const result = await walletService.getTransactionHistory(userId, page, limit);

		res.status(200).json({
			success: true,
			data: result,
		});
	} catch (error) {
		console.error("❌ Error fetching transactions:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching transaction history",
			error: error.message,
		});
	}
};

/**
 * @desc    Initiate PayMob wallet recharge (Nurses & Doctors only)
 * @route   POST /api/wallet/recharge/initiate
 * @body    { amount: number, paymentMethod: "card" | "wallet", walletPhoneNumber?: string }
 * @access  Private (Nurse/Doctor)
 */
exports.initiateRecharge = async (req, res) => {
	try {
		const userId = req.user?.id;
		const userRole = req.user?.role;

		if (!userId) {
			return res.status(401).json({ success: false, message: "Not authenticated" });
		}

		// Only nurses and doctors can recharge via PayMob
		if (!["nurse", "doctor"].includes(userRole)) {
			return res.status(403).json({
				success: false,
				message: "Only nurses and doctors can recharge their wallet via PayMob",
			});
		}

		const { amount, paymentMethod = "card", walletPhoneNumber } = req.body;

		// Validate amount
		if (!amount || typeof amount !== "number" || amount < 10) {
			return res.status(400).json({
				success: false,
				message: "Invalid recharge amount. Minimum is 10 EGP.",
			});
		}

		if (amount > 10000) {
			return res.status(400).json({
				success: false,
				message: "Maximum recharge amount is 10,000 EGP per transaction.",
			});
		}

		// Validate payment method
		if (!["card", "wallet"].includes(paymentMethod)) {
			return res.status(400).json({
				success: false,
				message: "Invalid payment method. Use 'card' or 'wallet'.",
			});
		}

		// For wallet payments, phone number is required
		if (paymentMethod === "wallet" && !walletPhoneNumber) {
			return res.status(400).json({
				success: false,
				message: "Wallet phone number is required for mobile wallet payments.",
			});
		}

		// Validate Egyptian phone number for wallet
		if (paymentMethod === "wallet" && walletPhoneNumber) {
			const phoneRegex = /^01[0125][0-9]{8}$/;
			if (!phoneRegex.test(walletPhoneNumber)) {
				return res.status(400).json({
					success: false,
					message: "Invalid Egyptian mobile number. Must be 11 digits starting with 01.",
				});
			}
		}

		// Get user info for billing
		const user = await User.findById(userId).select("name email mobile");
		if (!user) {
			return res.status(404).json({ success: false, message: "User not found" });
		}

		// Initiate PayMob payment
		const paymentData = await paymobService.initiatePayment({
			amount,
			userId,
			userInfo: {
				email: user.email,
				name: user.name,
				mobile: user.mobile,
			},
			paymentMethod,
			walletPhoneNumber,
		});

		// Create a pending transaction record
		await Transaction.create({
			type: "wallet_recharge",
			amount,
			currency: "EGP",
			direction: "credit",
			toUser: userId,
			status: "pending",
			paymentMethod: "paymob",
			paymobOrderId: paymentData.orderId.toString(),
			description: `Wallet recharge of ${amount} EGP via PayMob (${paymentMethod === "wallet" ? "Mobile Wallet" : "Card"})`,
		});

		const methodLabel = paymentMethod === "wallet" ? "Mobile Wallet" : "Card";
		console.log(`💳 PayMob ${methodLabel} recharge initiated: ${amount} EGP for user ${userId}, order ${paymentData.orderId}`);

		// Build response based on payment method
		const responseData = {
			paymentMethod,
			orderId: paymentData.orderId,
			amount,
		};

		if (paymentMethod === "card") {
			responseData.iframeUrl = paymentData.iframeUrl;
		} else {
			responseData.redirectUrl = paymentData.redirectUrl;
		}

		res.status(200).json({
			success: true,
			message: `Payment initiated successfully via ${methodLabel}`,
			data: responseData,
		});
	} catch (error) {
		console.error("❌ Error initiating recharge:", error);
		res.status(500).json({
			success: false,
			message: "Error initiating wallet recharge",
			error: error.message,
		});
	}
};

/**
 * @desc    PayMob webhook callback handler
 * @route   POST /api/wallet/recharge/callback
 * @access  Public (verified via HMAC)
 */
exports.rechargeCallback = async (req, res) => {
	try {
		const data = req.body.obj;
		const hmac = req.query.hmac;

		console.log("📥 PayMob callback received:", JSON.stringify(req.body).substring(0, 500));

		// Verify HMAC signature
		if (!paymobService.verifyHMAC(data, hmac)) {
			console.error("❌ PayMob HMAC verification failed!");
			return res.status(403).json({ success: false, message: "Invalid HMAC signature" });
		}

		const paymobOrderId = (data.order?.id || data.order)?.toString();
		const isSuccess = data.success === true || data.success === "true";
		const amountCents = data.amount_cents;
		const amountEGP = amountCents / 100;

		// Idempotency check: find the pending transaction for this order
		const existingTransaction = await Transaction.findOne({ paymobOrderId });

		if (!existingTransaction) {
			console.error(`❌ No pending transaction found for PayMob order: ${paymobOrderId}`);
			return res.status(404).json({ success: false, message: "Transaction not found" });
		}

		// Skip if already processed (idempotency)
		if (existingTransaction.status === "completed" || existingTransaction.status === "failed") {
			console.log(`⚠️ Transaction already processed for order ${paymobOrderId}, skipping`);
			return res.status(200).json({ success: true, message: "Already processed" });
		}

		if (isSuccess) {
			// Payment successful — credit wallet
			const userId = existingTransaction.toUser;

			// Update the pending transaction
			existingTransaction.status = "completed";
			existingTransaction.paymentReference = data.id?.toString();
			existingTransaction.processedAt = new Date();
			await existingTransaction.save();

			// Credit the wallet atomically
			const updatedUser = await User.findByIdAndUpdate(
				userId,
				{ $inc: { wallet: amountEGP } },
				{ new: true, select: "wallet walletBlocked" }
			);

			// Update balanceAfter
			existingTransaction.balanceAfter = updatedUser.wallet;
			await existingTransaction.save();

			// Check if wallet should be unblocked
			await walletService.checkAndEnforceThreshold(userId, updatedUser.wallet);

			console.log(`✅ PayMob recharge successful: ${amountEGP} EGP for user ${userId}. New balance: ${updatedUser.wallet}`);
		} else {
			// Payment failed
			existingTransaction.status = "failed";
			existingTransaction.notes = `PayMob error: ${data.data?.message || "Payment failed"}`;
			existingTransaction.processedAt = new Date();
			await existingTransaction.save();

			console.log(`❌ PayMob recharge failed for order ${paymobOrderId}`);
		}

		// PayMob expects a 200 response
		res.status(200).json({ success: true });
	} catch (error) {
		console.error("❌ Error processing PayMob callback:", error);
		// Still return 200 to prevent PayMob from retrying
		res.status(200).json({ success: false, message: "Callback processing error" });
	}
};

/**
 * @desc    Check recharge status by PayMob order ID
 * @route   GET /api/wallet/recharge/status/:orderId
 * @access  Private
 */
exports.getRechargeStatus = async (req, res) => {
	try {
		const userId = req.user?.id;
		const { orderId } = req.params;

		if (!userId) {
			return res.status(401).json({ success: false, message: "Not authenticated" });
		}

		const transaction = await Transaction.findOne({
			paymobOrderId: orderId,
			toUser: userId,
		});

		if (!transaction) {
			return res.status(404).json({
				success: false,
				message: "Recharge transaction not found",
			});
		}

		// Also return updated wallet balance
		const user = await User.findById(userId).select("wallet walletBlocked");

		res.status(200).json({
			success: true,
			data: {
				status: transaction.status,
				amount: transaction.amount,
				createdAt: transaction.createdAt,
				processedAt: transaction.processedAt,
				currentBalance: user?.wallet || 0,
				walletBlocked: user?.walletBlocked || false,
			},
		});
	} catch (error) {
		console.error("❌ Error checking recharge status:", error);
		res.status(500).json({
			success: false,
			message: "Error checking recharge status",
			error: error.message,
		});
	}
};
