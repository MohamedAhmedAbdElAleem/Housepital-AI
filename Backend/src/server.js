require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cookieParser = require("cookie-parser");
const cors = require("cors");
const { logger, logEvents } = require("./middleware/logger");
const errorHandler = require("./middleware/errorHandler");
const connectDB = require("./config/dbConn");

const app = express();
const PORT = process.env.PORT || 3500;

connectDB();

// CORS configuration to allow Flutter app connections
app.use(
	cors({
		origin: "*", // Allow all origins for development
		credentials: true,
		methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
		allowedHeaders: ["Content-Type", "Authorization"],
	})
);

app.use(logger);
app.use(express.json());
app.use(cookieParser());

app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/otp", require("./routes/otpRoutes"));
app.use("/api/user", require("./routes/userRoutes"));
app.use("/api/bookings", require("./routes/bookingRoutes"));

// Swagger Documentation
const swaggerDocs = require("./config/swagger");
swaggerDocs(app, PORT);

app.use((req, res) => res.status(404).json({ message: "404 Not Found" }));

app.use(errorHandler);

mongoose.connection.once("open", () => {
    console.log("Connected to MongoDB");
    const server = app.listen(PORT, "0.0.0.0", () => {
        console.log(`Server running on port ${PORT}`);
    });

    // Graceful Shutdown Logic
    const gracefulShutdown = () => {
        console.log("Received kill signal, shutting down gracefully");
        server.close(() => {
            console.log("Closed out remaining connections");
            mongoose.connection.close(false, () => {
                console.log("MongoDb connection closed");
                process.exit(0);
            });
        });
    };

    process.on("SIGTERM", gracefulShutdown);
    process.on("SIGINT", gracefulShutdown);

    // Handle Nodemon restart signal
    process.once("SIGUSR2", () => {
        console.log("Received SIGUSR2 (Nodemon restart)");
        server.close(() => {
             mongoose.connection.close(false, () => {
                console.log("MongoDb connection closed");
                process.kill(process.pid, "SIGUSR2");
            });
        });
    });
});

mongoose.connection.on("error", (err) =>
	logEvents(
		`${err.no}: ${err.code}\t${err.syscall}\t${err.hostname}`,
		"mongoErrLog.log"
	)
);
