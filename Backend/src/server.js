/**
 * Express server setup - Combined version
 * Supports both testing (in-memory) and production (MongoDB)
 */

require("dotenv").config();
const express = require("express");
const cookieParser = require("cookie-parser");
const cors = require("cors");
const { logger, logEvents } = require("./middleware/logger");
const errorHandler = require("./middleware/errorHandler");

const app = express();

// CORS configuration
app.use(cors({
    origin: '*',
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// Middleware
app.use(logger);
app.use(express.json());
app.use(cookieParser());

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy', timestamp: new Date() });
});

// Routes
app.use('/api/users', require('./routes/userRoutes'));

// Conditionally load MongoDB routes if in production
if (process.env.NODE_ENV !== 'test') {
    try {
        const mongoose = require("mongoose");
        const connectDB = require("./config/dbConn");

        // Connect to MongoDB
        connectDB();

        // Additional production routes
        app.use("/api/auth", require("./routes/authRoutes"));
        app.use("/api/otp", require("./routes/otpRoutes"));

        // MongoDB connection handlers
        mongoose.connection.once("open", () => {
            console.log("Connected to MongoDB");
            const PORT = process.env.PORT || 3500;
            app.listen(PORT, "0.0.0.0", () => console.log(`Server running on port ${PORT}`));
        });

        mongoose.connection.on("error", err =>
            logEvents(`${err.no}: ${err.code}\t${err.syscall}\t${err.hostname}`, "mongoErrLog.log")
        );
    } catch (err) {
        console.log("MongoDB setup skipped (test mode or missing dependencies)");
    }
}

// 404 handler
app.use((req, res) => res.status(404).json({ message: "404 Not Found" }));

// Error handling
app.use(errorHandler);

module.exports = app;
