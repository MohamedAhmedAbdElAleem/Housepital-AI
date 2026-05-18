// ─── Firebase Cloud Messaging (FCM) Push Service ─────────────────────────────
// Handles sending push notifications to user devices via Firebase Admin SDK.
// Falls back gracefully if Firebase is not configured (dev environments).

let admin = null;
let isInitialized = false;

/**
 * Initialize Firebase Admin SDK
 * Requires FIREBASE_SERVICE_ACCOUNT_PATH env var pointing to the JSON key file,
 * or FIREBASE_SERVICE_ACCOUNT_JSON env var containing the JSON string directly.
 */
const initFirebase = () => {
	if (isInitialized) return true;

	try {
		admin = require("firebase-admin");

		const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
		const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;

		if (serviceAccountJson) {
			// Parse from env variable (useful for Docker/CI)
			const serviceAccount = JSON.parse(serviceAccountJson);
			admin.initializeApp({
				credential: admin.credential.cert(serviceAccount),
			});
			isInitialized = true;
			console.log("🔥 Firebase Admin SDK initialized (from env JSON)");
		} else if (serviceAccountPath) {
			// Load from file path
			const serviceAccount = require(serviceAccountPath);
			admin.initializeApp({
				credential: admin.credential.cert(serviceAccount),
			});
			isInitialized = true;
			console.log("🔥 Firebase Admin SDK initialized (from file)");
		} else {
			console.warn(
				"⚠️ Firebase not configured — set FIREBASE_SERVICE_ACCOUNT_PATH or FIREBASE_SERVICE_ACCOUNT_JSON"
			);
			return false;
		}

		return true;
	} catch (err) {
		console.error("❌ Firebase initialization failed:", err.message);
		return false;
	}
};

/**
 * Send a push notification to a specific user's devices
 * @param {string} userId - The user's MongoDB _id
 * @param {object} payload - { title, body, data, imageUrl }
 * @returns {object} { sent: number, failed: number, invalidTokens: string[] }
 */
const sendPushToUser = async (userId, { title, body, data = {}, imageUrl }) => {
	if (!isInitialized) {
		// Silently skip in dev mode without Firebase
		return { sent: 0, failed: 0, invalidTokens: [], skipped: true };
	}

	const User = require("../models/User");
	const user = await User.findById(userId).select("fcmTokens");

	if (!user || !user.fcmTokens || user.fcmTokens.length === 0) {
		return { sent: 0, failed: 0, invalidTokens: [], noTokens: true };
	}

	const tokens = user.fcmTokens.map((t) => t.token);
	const invalidTokens = [];
	let sent = 0;
	let failed = 0;

	// Build the message payload
	const message = {
		notification: {
			title,
			body,
			...(imageUrl && { imageUrl }),
		},
		data: {
			...Object.fromEntries(
				Object.entries(data).map(([k, v]) => [k, String(v)])
			),
			click_action: "FLUTTER_NOTIFICATION_CLICK",
		},
		android: {
			priority: "high",
			notification: {
				channelId: "housepital_alerts",
				sound: data.priority === "urgent" ? "critical_alert" : "default",
				priority: data.priority === "urgent" ? "max" : "default",
			},
		},
		apns: {
			payload: {
				aps: {
					sound: data.priority === "urgent" ? "critical_alert.wav" : "default",
					badge: 1,
					"content-available": 1,
				},
			},
		},
	};

	// Send to each token individually to track invalid ones
	for (const token of tokens) {
		try {
			await admin.messaging().send({ ...message, token });
			sent++;
		} catch (err) {
			failed++;
			// Token is invalid/expired — mark for removal
			if (
				err.code === "messaging/invalid-registration-token" ||
				err.code === "messaging/registration-token-not-registered"
			) {
				invalidTokens.push(token);
			} else {
				console.error(`⚠️ FCM send error for ${token.substring(0, 12)}...:`, err.code);
			}
		}
	}

	// Clean up invalid tokens
	if (invalidTokens.length > 0) {
		await User.updateOne(
			{ _id: userId },
			{ $pull: { fcmTokens: { token: { $in: invalidTokens } } } }
		);
		console.log(`🧹 Removed ${invalidTokens.length} invalid FCM tokens for user ${userId}`);
	}

	return { sent, failed, invalidTokens };
};

/**
 * Send push to multiple users
 */
const sendPushToUsers = async (userIds, payload) => {
	const results = [];
	for (const userId of userIds) {
		try {
			const result = await sendPushToUser(userId, payload);
			results.push({ userId, ...result });
		} catch (err) {
			results.push({ userId, error: err.message });
		}
	}
	return results;
};

module.exports = {
	initFirebase,
	sendPushToUser,
	sendPushToUsers,
};
