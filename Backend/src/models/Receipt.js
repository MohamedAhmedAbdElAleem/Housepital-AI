const mongoose = require("mongoose");

const receiptSchema = new mongoose.Schema(
	{
		// Who submitted the receipt
		userId: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "User",
			required: [true, "User ID is required"],
		},
		// Requested recharge amount (EGP)
		amount: {
			type: Number,
			required: [true, "Amount is required"],
			min: [10, "Minimum recharge amount is 10 EGP"],
		},
		// How the user transferred money
		paymentMethod: {
			type: String,
			enum: ["instapay", "mobile_wallet"],
			required: [true, "Payment method is required"],
		},
		// Uploaded receipt file (image or PDF)
		receiptUrl: {
			type: String,
			required: [true, "Receipt file is required"],
			trim: true,
		},
		receiptPublicId: {
			type: String,
			trim: true,
		},
		// Review status
		status: {
			type: String,
			enum: ["pending", "approved", "rejected"],
			default: "pending",
		},
		// Rejection reason (set by admin)
		rejectionReason: {
			type: String,
			trim: true,
			default: null,
		},
		// Admin who reviewed
		reviewedBy: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "User",
		},
		reviewedAt: {
			type: Date,
		},
		// Transaction created on approval
		transactionId: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "Transaction",
		},
	},
	{ timestamps: true }
);

// Indexes
receiptSchema.index({ userId: 1, createdAt: -1 });
receiptSchema.index({ status: 1, createdAt: -1 });

module.exports = mongoose.model("Receipt", receiptSchema);
