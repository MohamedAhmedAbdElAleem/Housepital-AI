const jwt = require("jsonwebtoken");
const { setIO } = require("./notificationService");

/**
 * Initialize Socket.IO for real-time notifications
 * Each authenticated user joins a room: user_{userId}
 */
const initializeSocket = (server) => {
	const { Server } = require("socket.io");

	const io = new Server(server, {
		cors: {
			origin: "*",
			methods: ["GET", "POST"],
			credentials: true,
		},
		transports: ["websocket", "polling"],
	});

	// Share the io instance with notification service
	setIO(io);

	// Authentication middleware for socket connections
	io.use((socket, next) => {
		const token = socket.handshake.auth?.token || socket.handshake.query?.token;

		if (!token) {
			console.log("⚠️ Socket connection attempt without token");
			return next(new Error("Authentication required"));
		}

		try {
			const secretKey = process.env.JWT_SECRET_KEY || "housepital_secret_key_2024";
			const decoded = jwt.verify(token, secretKey);
			socket.userId = decoded.id;
			socket.userRole = decoded.role;
			socket.userEmail = decoded.email;
			next();
		} catch (error) {
			console.log("⚠️ Socket auth failed:", error.message);
			return next(new Error("Invalid token"));
		}
	});

	io.on("connection", (socket) => {
		const userId = socket.userId;
		console.log(`🔌 User connected: ${userId} (${socket.userRole})`);

		// Join user-specific room for targeted notifications
		socket.join(`user_${userId}`);

		// Join role-based room for broadcast notifications
		socket.join(`role_${socket.userRole}`);

		// Handle user marking notification as read via socket
		socket.on("mark_read", async (data) => {
			try {
				const Notification = require("../models/Notification");
				await Notification.findByIdAndUpdate(data.notificationId, {
					isRead: true,
					readAt: new Date(),
				});
				socket.emit("notification_read", { notificationId: data.notificationId });
			} catch (error) {
				console.error("Error marking notification read:", error);
			}
		});

		// Handle marking all as read
		socket.on("mark_all_read", async () => {
			try {
				const Notification = require("../models/Notification");
				await Notification.updateMany(
					{ userId, isRead: false },
					{ isRead: true, readAt: new Date() }
				);
				socket.emit("all_notifications_read");
			} catch (error) {
				console.error("Error marking all notifications read:", error);
			}
		});

		// Ping-pong for connection health
		socket.on("ping_server", () => {
			socket.emit("pong_server", { timestamp: Date.now() });
		});

		socket.on("disconnect", (reason) => {
			console.log(`🔌 User disconnected: ${userId} (${reason})`);
		});
	});

	console.log("🔌 Socket.IO initialized for real-time notifications");

	return io;
};

module.exports = { initializeSocket };
