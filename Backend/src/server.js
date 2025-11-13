require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cookieParser = require("cookie-parser");
const { logger, logEvents } = require("./middleware/logger");
const errorHandler = require("./middleware/errorHandler");
const connectDB = require("./config/dbConn");

const app = express();
const PORT = process.env.PORT || 3500;

connectDB();

app.use(logger);
app.use(express.json());
app.use(cookieParser());

app.use("/api/auth", require("./routes/authRoutes"));

app.use((req, res) => res.status(404).json({ message: "404 Not Found" }));

app.use(errorHandler);

mongoose.connection.once("open", () => {
    console.log("Connected to MongoDB");
    app.listen(PORT, "0.0.0.0", () => console.log(`Server running on port ${PORT}`));
});

mongoose.connection.on("error", err =>
    logEvents(`${err.no}: ${err.code}\t${err.syscall}\t${err.hostname}`, "mongoErrLog.log")
);
