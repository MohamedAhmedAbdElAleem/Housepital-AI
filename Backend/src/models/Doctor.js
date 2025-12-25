const mongoose = require("mongoose");

const doctorSchema = new mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: [true, "User ID is required"],
            unique: true,
            index: true
        },
        // Professional Information
        licenseNumber: {
            type: String,
            required: [true, "License number is required"],
            unique: true,
            trim: true,
            minlength: [5, "License number must be at least 5 characters"],
            maxlength: [20, "License number cannot exceed 20 characters"]
        },
        specialization: {
            type: String,
            required: [true, "Specialization is required"],
            trim: true,
            minlength: [3, "Specialization must be at least 3 characters"],
            maxlength: [50, "Specialization cannot exceed 50 characters"]
        },
        yearsOfExperience: {
            type: Number,
            required: [true, "Years of experience is required"],
            min: [0, "Years of experience cannot be negative"],
            max: [60, "Years of experience seems too high"]
        },
        qualifications: {
            type: [String],
            default: []
        },
        bio: {
            type: String,
            trim: true,
            maxlength: [500, "Bio cannot exceed 500 characters"]
        },
        gender: {
            type: String,
            enum: ["male", "female"]
        },
        // Document Verification
        nationalIdUrl: {
            type: String,
            trim: true
        },
        licenseUrl: {
            type: String,
            trim: true
        },
        verificationStatus: {
            type: String,
            enum: ["pending", "approved", "rejected"],
            default: "pending"
        },
        verifiedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User"
        },
        verifiedAt: {
            type: Date
        },
        rejectionReason: {
            type: String,
            trim: true
        },
        // Booking Settings
        bookingMode: {
            type: String,
            enum: ["slots", "queue"],
            default: "slots"
        },
        minAdvanceBookingHours: {
            type: Number,
            default: 3,
            min: [0, "Minimum advance booking hours cannot be negative"]
        },
        rushBookingEnabled: {
            type: Boolean,
            default: false
        },
        rushBookingPremiumPercent: {
            type: Number,
            default: 25,
            min: [0, "Premium percentage cannot be negative"],
            max: [100, "Premium percentage cannot exceed 100"]
        },
        // Performance Metrics
        rating: {
            type: Number,
            default: 0,
            min: 0,
            max: 5
        },
        totalRatings: {
            type: Number,
            default: 0
        },
        completedAppointments: {
            type: Number,
            default: 0
        },
        cancelledAppointments: {
            type: Number,
            default: 0
        },
        reliabilityRate: {
            type: Number,
            default: 100, // percentage
            min: 0,
            max: 100
        },
        // Legacy field - now moved to Clinic model
        clinicAddress: {
            type: String,
            trim: true,
            maxlength: [200, "Clinic address cannot exceed 200 characters"]
        }
    },
    { timestamps: true }
);

module.exports = mongoose.model("Doctor", doctorSchema);