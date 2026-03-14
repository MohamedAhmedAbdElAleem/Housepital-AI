const Notification = require("../models/Notification");

/**
 * @desc    Get all notifications for the authenticated user
 * @route   GET /api/notifications
 * @access  Private
 */
exports.getNotifications = async (req, res) => {
	try {
		const userId = req.user?.id;
		const page = parseInt(req.query.page) || 1;
		const limit = parseInt(req.query.limit) || 30;
		const skip = (page - 1) * limit;

		const [notifications, total, unreadCount] = await Promise.all([
			Notification.find({ userId })
				.sort({ createdAt: -1 })
				.skip(skip)
				.limit(limit)
				.lean(),
			Notification.countDocuments({ userId }),
			Notification.countDocuments({ userId, isRead: false }),
		]);

		res.status(200).json({
			success: true,
			notifications,
			unreadCount,
			pagination: {
				page,
				limit,
				total,
				pages: Math.ceil(total / limit),
			},
		});
	} catch (error) {
		console.error("❌ Error fetching notifications:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching notifications",
			error: error.message,
		});
	}
};

/**
 * @desc    Get unread notification count
 * @route   GET /api/notifications/unread-count
 * @access  Private
 */
exports.getUnreadCount = async (req, res) => {
	try {
		const userId = req.user?.id;
		const count = await Notification.countDocuments({ userId, isRead: false });

		res.status(200).json({
			success: true,
			unreadCount: count,
		});
	} catch (error) {
		console.error("❌ Error fetching unread count:", error);
		res.status(500).json({
			success: false,
			message: "Error fetching unread count",
			error: error.message,
		});
	}
};

/**
 * @desc    Mark a notification as read
 * @route   PUT /api/notifications/:id/read
 * @access  Private
 */
exports.markAsRead = async (req, res) => {
	try {
		const { id } = req.params;
		const userId = req.user?.id;

		const notification = await Notification.findOneAndUpdate(
			{ _id: id, userId },
			{ isRead: true, readAt: new Date() },
			{ new: true }
		);

		if (!notification) {
			return res.status(404).json({
				success: false,
				message: "Notification not found",
			});
		}

		res.status(200).json({
			success: true,
			notification,
		});
	} catch (error) {
		console.error("❌ Error marking notification as read:", error);
		res.status(500).json({
			success: false,
			message: "Error marking notification as read",
			error: error.message,
		});
	}
};

/**
 * @desc    Mark all notifications as read
 * @route   PUT /api/notifications/read-all
 * @access  Private
 */
exports.markAllAsRead = async (req, res) => {
	try {
		const userId = req.user?.id;

		await Notification.updateMany(
			{ userId, isRead: false },
			{ isRead: true, readAt: new Date() }
		);

		res.status(200).json({
			success: true,
			message: "All notifications marked as read",
		});
	} catch (error) {
		console.error("❌ Error marking all as read:", error);
		res.status(500).json({
			success: false,
			message: "Error marking all notifications as read",
			error: error.message,
		});
	}
};

/**
 * @desc    Delete a notification
 * @route   DELETE /api/notifications/:id
 * @access  Private
 */
exports.deleteNotification = async (req, res) => {
	try {
		const { id } = req.params;
		const userId = req.user?.id;

		const notification = await Notification.findOneAndDelete({ _id: id, userId });

		if (!notification) {
			return res.status(404).json({
				success: false,
				message: "Notification not found",
			});
		}

		res.status(200).json({
			success: true,
			message: "Notification deleted",
		});
	} catch (error) {
		console.error("❌ Error deleting notification:", error);
		res.status(500).json({
			success: false,
			message: "Error deleting notification",
			error: error.message,
		});
	}
};

/**
 * @desc    Delete all notifications for user
 * @route   DELETE /api/notifications/clear-all
 * @access  Private
 */
exports.clearAllNotifications = async (req, res) => {
	try {
		const userId = req.user?.id;
		await Notification.deleteMany({ userId });

		res.status(200).json({
			success: true,
			message: "All notifications cleared",
		});
	} catch (error) {
		console.error("❌ Error clearing notifications:", error);
		res.status(500).json({
			success: false,
			message: "Error clearing notifications",
			error: error.message,
		});
	}
};
