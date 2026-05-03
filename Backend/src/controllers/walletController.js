/**
 * Wallet Controller
 *
 * Handles all wallet-related API endpoints:
 * - Balance retrieval
 * - Transaction history
 * - Receipt-based wallet recharge (Instapay / Mobile Wallet)
 * - Admin receipt review (approve/reject)
 */

const User = require("../models/User");
const Transaction = require("../models/Transaction");
const Receipt = require("../models/Receipt");
const walletService = require("../services/walletService");
const cloudinaryService = require("../services/cloudinaryService");
const { sendNotification } = require("../services/notificationService");

// ============================================================
// PAYMENT INFO (Static)
// ============================================================
const PAYMENT_INFO = {
	instapay: {
		method: "instapay",
		label: "Instapay",
		phoneNumber: "01156762762",
		link: "https://ipn.eg/S/xiimodyn/instapay/2bEtgy",
		receiverName: "Mohamed Ahmed Abd El-Aleem",
	},
	mobile_wallet: {
		method: "mobile_wallet",
		label: "Mobile Wallet",
		phoneNumber: "01011422702",
		receiverName: "Mohamed Ahmed Abd El-Aleem",
	},
};

// ============================================================
// BALANCE & TRANSACTIONS (unchanged)
// ============================================================

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

// ============================================================
// PAYMENT INFO
// ============================================================

/**
 * @desc    Get available payment methods and their info
 * @route   GET /api/wallet/payment-info
 * @access  Private
 */
exports.getPaymentInfo = async (req, res) => {
	try {
		res.status(200).json({
			success: true,
			data: {
				methods: [PAYMENT_INFO.instapay, PAYMENT_INFO.mobile_wallet],
				instructions: {
					en: "Transfer the desired amount to one of the methods below, then upload your receipt.",
					ar: "حوّل المبلغ المطلوب على إحدى الطرق التالية، ثم ارفع إيصال التحويل.",
				},
			},
		});
	} catch (error) {
		console.error("❌ Error fetching payment info:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching payment info",
			error: error.message,
		});
	}
};

// ============================================================
// RECEIPT SUBMISSION (User)
// ============================================================

/**
 * @desc    Submit a recharge receipt
 * @route   POST /api/wallet/receipts/submit
 * @body    { amount: number, paymentMethod: "instapay" | "mobile_wallet", receiptBase64: string }
 * @access  Private (All authenticated users)
 */
exports.submitReceipt = async (req, res) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			return res.status(401).json({ success: false, message: "Not authenticated" });
		}

		const { amount, paymentMethod, receiptBase64 } = req.body;

		// Validate amount
		if (!amount || typeof amount !== "number" || amount < 10) {
			return res.status(400).json({
				success: false,
				message: "Invalid amount. Minimum recharge is 10 EGP.",
			});
		}

		if (amount > 50000) {
			return res.status(400).json({
				success: false,
				message: "Maximum recharge amount is 50,000 EGP per receipt.",
			});
		}

		// Validate payment method
		if (!["instapay", "mobile_wallet"].includes(paymentMethod)) {
			return res.status(400).json({
				success: false,
				message: "Invalid payment method. Use 'instapay' or 'mobile_wallet'.",
			});
		}

		// Validate receipt file
		if (!receiptBase64) {
			return res.status(400).json({
				success: false,
				message: "Receipt file is required. Please upload an image or PDF of your transfer receipt.",
			});
		}

		// Upload receipt to Cloudinary
		const uploadResult = await cloudinaryService.uploadFromBase64(receiptBase64, {
			folder: cloudinaryService.FOLDERS.RECEIPTS,
			resourceType: "auto",
		});

		if (!uploadResult.success) {
			return res.status(500).json({
				success: false,
				message: "Failed to upload receipt. Please try again.",
				error: uploadResult.error,
			});
		}

		// Create receipt record
		const receipt = await Receipt.create({
			userId,
			amount,
			paymentMethod,
			receiptUrl: uploadResult.url,
			receiptPublicId: uploadResult.publicId,
			status: "pending",
		});

		console.log(`📄 Receipt submitted: ${receipt._id} by user ${userId}, amount: ${amount} EGP via ${paymentMethod}`);

		res.status(201).json({
			success: true,
			message: "Receipt submitted successfully. It will be reviewed by our team shortly.",
			data: {
				receiptId: receipt._id,
				amount: receipt.amount,
				paymentMethod: receipt.paymentMethod,
				status: receipt.status,
				receiptUrl: receipt.receiptUrl,
				createdAt: receipt.createdAt,
			},
		});
	} catch (error) {
		console.error("❌ Error submitting receipt:", error);
		res.status(500).json({
			success: false,
			message: "Error submitting receipt",
			error: error.message,
		});
	}
};

// ============================================================
// MY RECEIPTS (User)
// ============================================================

/**
 * @desc    Get current user's receipt history
 * @route   GET /api/wallet/receipts/my?page=1&limit=20
 * @access  Private
 */
exports.getMyReceipts = async (req, res) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			return res.status(401).json({ success: false, message: "Not authenticated" });
		}

		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 20;
		const skip = (page - 1) * limit;

		const [receipts, total] = await Promise.all([
			Receipt.find({ userId })
				.sort({ createdAt: -1 })
				.skip(skip)
				.limit(limit)
				.lean(),
			Receipt.countDocuments({ userId }),
		]);

		res.status(200).json({
			success: true,
			data: {
				receipts,
				pagination: {
					total,
					page,
					pages: Math.ceil(total / limit),
				},
			},
		});
	} catch (error) {
		console.error("❌ Error fetching user receipts:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching receipts",
			error: error.message,
		});
	}
};

// ============================================================
// ADMIN: PENDING RECEIPTS
// ============================================================

/**
 * @desc    Get all pending receipts for admin review
 * @route   GET /api/wallet/receipts/pending
 * @access  Private (Admin)
 */
exports.getPendingReceipts = async (req, res) => {
	try {
		const receipts = await Receipt.find({ status: "pending" })
			.sort({ createdAt: 1 }) // oldest first (FIFO)
			.populate("userId", "name email mobile role profilePictureUrl")
			.lean();

		res.status(200).json({
			success: true,
			data: {
				receipts,
				total: receipts.length,
			},
		});
	} catch (error) {
		console.error("❌ Error fetching pending receipts:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching pending receipts",
			error: error.message,
		});
	}
};

// ============================================================
// ADMIN: ALL RECEIPTS
// ============================================================

/**
 * @desc    Get all receipts (paginated, filterable by status)
 * @route   GET /api/wallet/receipts/all?status=pending&page=1&limit=20
 * @access  Private (Admin)
 */
exports.getAllReceipts = async (req, res) => {
	try {
		const { status, page = 1, limit = 20 } = req.query;
		const query = {};

		if (status && ["pending", "approved", "rejected"].includes(status)) {
			query.status = status;
		}

		const skip = (parseInt(page) - 1) * parseInt(limit);

		const [receipts, total] = await Promise.all([
			Receipt.find(query)
				.sort({ createdAt: -1 })
				.skip(skip)
				.limit(parseInt(limit))
				.populate("userId", "name email mobile role profilePictureUrl")
				.populate("reviewedBy", "name email")
				.lean(),
			Receipt.countDocuments(query),
		]);

		res.status(200).json({
			success: true,
			data: {
				receipts,
				pagination: {
					total,
					page: parseInt(page),
					pages: Math.ceil(total / parseInt(limit)),
				},
			},
		});
	} catch (error) {
		console.error("❌ Error fetching all receipts:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching receipts",
			error: error.message,
		});
	}
};

// ============================================================
// ADMIN: REVIEW RECEIPT (Approve / Reject)
// ============================================================

/**
 * @desc    Admin reviews a receipt — approve (credits wallet) or reject (with reason)
 * @route   PUT /api/wallet/receipts/:id/review
 * @body    { action: "approve" | "reject", rejectionReason?: string }
 * @access  Private (Admin)
 */
exports.reviewReceipt = async (req, res) => {
	try {
		const adminId = req.user?.id;
		const { id } = req.params;
		const { action, rejectionReason } = req.body;

		if (!adminId) {
			return res.status(401).json({ success: false, message: "Not authenticated" });
		}

		// Validate action
		if (!["approve", "reject"].includes(action)) {
			return res.status(400).json({
				success: false,
				message: "Invalid action. Use 'approve' or 'reject'.",
			});
		}

		// Rejection requires a reason
		if (action === "reject" && (!rejectionReason || rejectionReason.trim() === "")) {
			return res.status(400).json({
				success: false,
				message: "Rejection reason is required.",
			});
		}

		// Find the receipt
		const receipt = await Receipt.findById(id);
		if (!receipt) {
			return res.status(404).json({
				success: false,
				message: "Receipt not found",
			});
		}

		// Can only review pending receipts
		if (receipt.status !== "pending") {
			return res.status(400).json({
				success: false,
				message: `This receipt has already been ${receipt.status}. Cannot review again.`,
			});
		}

		if (action === "approve") {
			// ── APPROVE: Credit wallet ──────────────────────────────

			const walletResult = await walletService.adjustWallet({
				userId: receipt.userId.toString(),
				amount: receipt.amount,
				type: "receipt_recharge",
				description: `Wallet recharge of ${receipt.amount} EGP via ${receipt.paymentMethod === "instapay" ? "Instapay" : "Mobile Wallet"} (Receipt approved)`,
				paymentMethod: receipt.paymentMethod,
				receiptId: receipt._id,
			});

			// Update receipt
			receipt.status = "approved";
			receipt.reviewedBy = adminId;
			receipt.reviewedAt = new Date();
			receipt.transactionId = walletResult.transaction._id;
			await receipt.save();

			// Notify user
			try {
				await sendNotification({
					userId: receipt.userId.toString(),
					title: "Wallet Recharged! 💰",
					body: `Your wallet has been credited with ${receipt.amount} EGP. Your new balance is ${walletResult.newBalance} EGP.`,
					titleAr: "تم شحن المحفظة! 💰",
					bodyAr: `تم إضافة ${receipt.amount} جنيه لمحفظتك. رصيدك الجديد ${walletResult.newBalance} جنيه.`,
					type: "wallet_recharged",
					referenceId: receipt._id,
					referenceType: "receipt",
					priority: "high",
					metadata: {
						amount: receipt.amount,
						newBalance: walletResult.newBalance,
						paymentMethod: receipt.paymentMethod,
					},
				});
			} catch (notifError) {
				console.error("⚠️ Error sending approval notification:", notifError.message);
			}

			console.log(`✅ Receipt ${id} approved by admin ${adminId}. Credited ${receipt.amount} EGP to user ${receipt.userId}. New balance: ${walletResult.newBalance}`);

			res.status(200).json({
				success: true,
				message: `Receipt approved. ${receipt.amount} EGP credited to user's wallet.`,
				data: {
					receipt: {
						_id: receipt._id,
						status: receipt.status,
						amount: receipt.amount,
						reviewedAt: receipt.reviewedAt,
					},
					walletBalance: walletResult.newBalance,
					walletBlocked: walletResult.walletBlocked,
				},
			});
		} else {
			// ── REJECT: Save reason ─────────────────────────────────

			receipt.status = "rejected";
			receipt.rejectionReason = rejectionReason.trim();
			receipt.reviewedBy = adminId;
			receipt.reviewedAt = new Date();
			await receipt.save();

			// Notify user
			try {
				await sendNotification({
					userId: receipt.userId.toString(),
					title: "Receipt Rejected ❌",
					body: `Your recharge receipt for ${receipt.amount} EGP was rejected. Reason: ${rejectionReason.trim()}`,
					titleAr: "تم رفض الإيصال ❌",
					bodyAr: `تم رفض إيصال الشحن بقيمة ${receipt.amount} جنيه. السبب: ${rejectionReason.trim()}`,
					type: "receipt_rejected",
					referenceId: receipt._id,
					referenceType: "receipt",
					priority: "high",
					metadata: {
						amount: receipt.amount,
						rejectionReason: rejectionReason.trim(),
						paymentMethod: receipt.paymentMethod,
					},
				});
			} catch (notifError) {
				console.error("⚠️ Error sending rejection notification:", notifError.message);
			}

			console.log(`❌ Receipt ${id} rejected by admin ${adminId}. Reason: ${rejectionReason.trim()}`);

			res.status(200).json({
				success: true,
				message: "Receipt rejected.",
				data: {
					receipt: {
						_id: receipt._id,
						status: receipt.status,
						amount: receipt.amount,
						rejectionReason: receipt.rejectionReason,
						reviewedAt: receipt.reviewedAt,
					},
				},
			});
		}
	} catch (error) {
		console.error("❌ Error reviewing receipt:", error);
		res.status(500).json({
			success: false,
			message: "Error reviewing receipt",
			error: error.message,
		});
	}
};
