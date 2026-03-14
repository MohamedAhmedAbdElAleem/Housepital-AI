const Notification = require("../models/Notification");

// In-memory map of userId → socket for real-time push
// This is managed by the socket.io setup in socketManager.js
let io = null;

/**
 * Set the Socket.IO instance (called from server.js)
 */
const setIO = (socketIO) => {
	io = socketIO;
};

/**
 * Get the Socket.IO instance
 */
const getIO = () => io;

/**
 * Create and send a notification to a user
 * - Saves to database
 * - Emits via Socket.IO if user is connected
 */
const sendNotification = async ({
	userId,
	title,
	body,
	titleAr,
	bodyAr,
	type,
	referenceId,
	referenceType,
	imageUrl,
	priority = "normal",
	metadata = {},
}) => {
	try {
		// 1. Save to database
		const notification = new Notification({
			userId,
			title,
			body,
			titleAr: titleAr || title,
			bodyAr: bodyAr || body,
			type,
			referenceId,
			referenceType,
			imageUrl,
			priority,
			metadata,
		});
		await notification.save();

		console.log(`🔔 Notification created for user ${userId}: ${title}`);

		// 2. Emit via Socket.IO for real-time delivery
		if (io) {
			io.to(`user_${userId}`).emit("notification", {
				id: notification._id,
				title: notification.title,
				body: notification.body,
				titleAr: notification.titleAr,
				bodyAr: notification.bodyAr,
				type: notification.type,
				referenceId: notification.referenceId,
				referenceType: notification.referenceType,
				imageUrl: notification.imageUrl,
				priority: notification.priority,
				metadata: notification.metadata,
				isRead: false,
				createdAt: notification.createdAt,
			});
			console.log(`📡 Real-time notification sent to user_${userId}`);
		}

		return notification;
	} catch (error) {
		console.error("❌ Error sending notification:", error);
		throw error;
	}
};

/**
 * Send notification to multiple users
 */
const sendBulkNotification = async (userIds, notificationData) => {
	const results = [];
	for (const userId of userIds) {
		try {
			const result = await sendNotification({ ...notificationData, userId });
			results.push(result);
		} catch (error) {
			console.error(`Failed to send notification to ${userId}:`, error);
		}
	}
	return results;
};

module.exports = {
	setIO,
	getIO,
	sendNotification,
	sendBulkNotification,
};
