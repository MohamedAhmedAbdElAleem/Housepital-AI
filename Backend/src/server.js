const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });
const express = require("express");
const mongoose = require("mongoose");
const cookieParser = require("cookie-parser");
const cors = require("cors");
const http = require("http");
const { Server } = require("socket.io");
const jwt = require("jsonwebtoken");
const { logger, logEvents } = require("./middleware/logger");
const errorHandler = require("./middleware/errorHandler");
const connectDB = require("./config/dbConn");
const cloudinaryRoutes = require("./routes/cloudinaryRoutes");

const app = express();
const PORT = process.env.PORT || 3500;

// Create HTTP server for Socket.io
const server = http.createServer(app);

// Initialize Socket.io
const io = new Server(server, {
	cors: {
		origin: "*",
		methods: ["GET", "POST"],
		credentials: true,
	},
});

// Store io instance on app for use by controllers/services
app.set("io", io);

// Wire notification service with the same io instance
require("./services/notificationService").setIO(io);

// Socket.io JWT Authentication Middleware
io.use((socket, next) => {
	const token = socket.handshake.auth?.token || socket.handshake.query?.token;
	if (!token) {
		return next(new Error("Authentication required"));
	}

	try {
		const secretKey =
			process.env.JWT_SECRET_KEY || "housepital_secret_key_2024";
		const decoded = jwt.verify(token, secretKey);
		socket.userId = decoded.id;
		socket.userRole = decoded.role;
		next();
	} catch (err) {
		return next(new Error("Invalid token"));
	}
});

// Socket.io Connection Handler
io.on("connection", (socket) => {
	const { userId, userRole } = socket;
	console.log(`🔌 Socket connected: ${userId} (${userRole})`);

	// Join role-based rooms for targeted notifications
	if (userRole === "nurse") {
		socket.join(`nurse_${userId}`);
		socket.join("online_nurses"); // All nurses listen to new requests
	} else if (userRole === "customer") {
		socket.join(`patient_${userId}`);
	}

	// Nurse location update (real-time tracking)
	socket.on("nurse:update_location", async (data) => {
		try {
			const Nurse = require("./models/Nurse");
			await Nurse.findOneAndUpdate(
				{ user: userId },
				{
					currentLocation: {
						type: "Point",
						coordinates: [data.longitude, data.latitude],
					},
					isOnline: true,
					lastOnlineAt: new Date(),
				},
			);
		} catch (err) {
			console.error("Error updating nurse location:", err.message);
		}
	});

	// Nurse goes online/offline
	socket.on("nurse:set_online", async (isOnline) => {
		try {
			const Nurse = require("./models/Nurse");
			await Nurse.findOneAndUpdate(
				{ user: userId },
				{ isOnline, lastOnlineAt: new Date() },
			);
			console.log(
				`👩‍⚕️ Nurse ${userId} is now ${isOnline ? "online" : "offline"}`,
			);
		} catch (err) {
			console.error("Error toggling nurse online:", err.message);
		}
	});

	socket.on("disconnect", async () => {
		console.log(`🔌 Socket disconnected: ${userId}`);
		// Mark nurse as offline on disconnect
		if (userRole === "nurse") {
			try {
				const Nurse = require("./models/Nurse");
				await Nurse.findOneAndUpdate(
					{ user: userId },
					{ isOnline: false, lastOnlineAt: new Date() },
				);
			} catch (err) {
				console.error("Error marking nurse offline:", err.message);
			}
		}
	});
});

connectDB();

// CORS configuration to allow Flutter app connections
app.use(
	cors({
		origin: "*", // Allow all origins for development
		credentials: true,
		methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
		allowedHeaders: ["Content-Type", "Authorization"],
	}),
);

app.use(logger);
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));
app.use(cookieParser());

app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/otp", require("./routes/otpRoutes"));
app.use("/api/user", require("./routes/userRoutes"));
app.use("/api/profile", require("./routes/profileRoutes"));
app.use("/api/bookings", require("./routes/bookingRoutes"));
app.use("/api/admin/insights", require("./routes/insightsRoutes"));
app.use("/api/admin/powerbi", require("./routes/powerBiRoutes"));
app.use("/api/cloudinary", require("./routes/cloudinaryRoutes"));
app.use("/api/triage", require("./routes/triageRoutes"));
app.use("/api/doctors", require("./routes/doctorRoutes"));
app.use("/api/clinics", require("./routes/clinicRoutes"));
app.use("/api/matching", require("./routes/matchingRoutes"));
app.use("/api/notifications", require("./routes/notificationRoutes"));
app.use("/api/services", require("./routes/serviceRoutes"));
app.use("/api/nurse", require("./routes/nurseRoutes"));

// Serve static files (for ID document images)
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

// Swagger Documentation
const swaggerDocs = require("./config/swagger");
swaggerDocs(app, PORT);

app.use((req, res) => res.status(404).json({ message: "404 Not Found" }));

app.use(errorHandler);

mongoose.connection.once("open", () => {
	console.log("Connected to MongoDB");
	server.listen(PORT, "0.0.0.0", () => {
		console.log(`Server running on port ${PORT}`);
		console.log(`Socket.IO ready for real-time notifications`);
	});

	// Graceful Shutdown Logic
	const gracefulShutdown = async () => {
		console.log("Received kill signal, shutting down gracefully");
		server.close(async () => {
			console.log("Closed out remaining connections");
			await mongoose.connection.close();
			console.log("MongoDb connection closed");
			process.exit(0);
		});
	};

	process.on("SIGTERM", gracefulShutdown);
	process.on("SIGINT", gracefulShutdown);

	// Handle Nodemon restart signal
	process.once("SIGUSR2", async () => {
		console.log("Received SIGUSR2 (Nodemon restart)");
		server.close(async () => {
			await mongoose.connection.close();
			console.log("MongoDb connection closed");
			process.kill(process.pid, "SIGUSR2");
		});
	});
});

mongoose.connection.on("error", (err) =>
	logEvents(
		`${err.no}: ${err.code}\t${err.syscall}\t${err.hostname}`,
		"mongoErrLog.log",
	),
);
