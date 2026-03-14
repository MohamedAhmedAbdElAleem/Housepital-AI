const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema({
	// Who receives this notification
	userId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "User",
		required: true,
		index: true,
	},

	// Notification content
	title: {
		type: String,
		required: true,
		trim: true,
	},
	body: {
		type: String,
		required: true,
		trim: true,
	},
	titleAr: {
		type: String,
		trim: true,
	},
	bodyAr: {
		type: String,
		trim: true,
	},

	// Notification type for categorization & icon display
	type: {
		type: String,
		enum: [
			"booking_created",
			"booking_confirmed",
			"booking_assigned",
			"booking_in_progress",
			"booking_completed",
			"booking_cancelled",
			"nurse_arriving",
			"payment_received",
			"payment_reminder",
			"chat_message",
			"triage_result",
			"profile_verified",
			"profile_rejected",
			"appointment_reminder",
			"system",
			"promotion",
		],
		required: true,
	},

	// Related entity for deep linking
	referenceId: {
		type: mongoose.Schema.Types.ObjectId,
	},
	referenceType: {
		type: String,
		enum: ["booking", "chat", "user", "payment", "triage", "system"],
	},

	// Status
	isRead: {
		type: Boolean,
		default: false,
	},
	readAt: {
		type: Date,
	},

	// Optional image/icon
	imageUrl: {
		type: String,
		trim: true,
	},

	// Priority
	priority: {
		type: String,
		enum: ["low", "normal", "high", "urgent"],
		default: "normal",
	},

	// Metadata for extra data
	metadata: {
		type: mongoose.Schema.Types.Mixed,
		default: {},
	},

	createdAt: {
		type: Date,
		default: Date.now,
	},
});

// Indexes for efficient queries
notificationSchema.index({ userId: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ createdAt: 1 }, { expireAfterSeconds: 30 * 24 * 60 * 60 }); // Auto-delete after 30 days

module.exports = mongoose.model("Notification", notificationSchema);
