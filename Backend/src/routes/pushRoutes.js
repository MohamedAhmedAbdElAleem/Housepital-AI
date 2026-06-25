const express = require("express");
const router = express.Router();
const { authenticateToken } = require("../middleware/authMiddleware");
const User = require("../models/User");

// ─── FCM Token Management ────────────────────────────────────────────────────

/**
 * @desc    Register or update FCM token for push notifications
 * @route   POST /api/push/register
 * @access  Private
 */
router.post("/register", authenticateToken, async (req, res) => {
	try {
		const userId = req.user?.id;
		const { token, device } = req.body;

		if (!token) {
			return res
				.status(400)
				.json({ success: false, message: "FCM token is required" });
		}

		const user = await User.findById(userId);
		if (!user) {
			return res
				.status(404)
				.json({ success: false, message: "User not found" });
		}

		// Check if token already exists for this user
		const existingIndex = user.fcmTokens.findIndex((t) => t.token === token);

		if (existingIndex >= 0) {
			// Update existing token's timestamp
			user.fcmTokens[existingIndex].updatedAt = new Date();
			user.fcmTokens[existingIndex].device = device || "unknown";
		} else {
			// Add new token (limit to 5 devices per user)
			if (user.fcmTokens.length >= 5) {
				// Remove oldest token
				user.fcmTokens.sort((a, b) => a.updatedAt - b.updatedAt);
				user.fcmTokens.shift();
			}
			user.fcmTokens.push({
				token,
				device: device || "unknown",
				updatedAt: new Date(),
			});
		}

		await user.save();

		console.log(
			`📱 FCM token registered for user ${userId} (${device || "unknown"})`
		);

		res.json({ success: true, message: "FCM token registered" });
	} catch (error) {
		console.error("❌ Error registering FCM token:", error);
		res
			.status(500)
			.json({ success: false, message: "Error registering token" });
	}
});

/**
 * @desc    Remove FCM token (on logout)
 * @route   DELETE /api/push/unregister
 * @access  Private
 */
router.delete("/unregister", authenticateToken, async (req, res) => {
	try {
		const userId = req.user?.id;
		const { token } = req.body;

		if (!token) {
			return res
				.status(400)
				.json({ success: false, message: "FCM token is required" });
		}

		await User.updateOne(
			{ _id: userId },
			{ $pull: { fcmTokens: { token } } }
		);

		console.log(`📱 FCM token unregistered for user ${userId}`);

		res.json({ success: true, message: "FCM token unregistered" });
	} catch (error) {
		console.error("❌ Error unregistering FCM token:", error);
		res
			.status(500)
			.json({ success: false, message: "Error unregistering token" });
	}
});

module.exports = router;
