const mongoose = require("mongoose");

const nurseSchema = new mongoose.Schema(
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
        skills: {
            type: [String],
            default: [],
            // e.g., ["wound_care", "iv_insertion", "elderly_care", "injections", "blood_draw"]
        },
        bio: {
            type: String,
            trim: true,
            maxlength: [500, "Bio cannot exceed 500 characters"]
        },
        certifications: {
            type: [String],
            default: []
        },
        gender: {
            type: String,
            enum: ["male", "female"],
            required: [true, "Gender is required for matching"]
        },
        // Document Verification
        nationalIdUrl: {
            type: String,
            trim: true
        },
        degreeUrl: {
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
        profileStatus: {
            type: String,
            enum: ["incomplete", "pending_review", "approved", "rejected"],
            default: "incomplete"
        },
        // Availability & Work Zone
        isOnline: {
            type: Boolean,
            default: false
        },
        lastOnlineAt: {
            type: Date
        },
        workZone: {
            center: {
                type: {
                    type: String,
                    enum: ["Point"],
                    default: "Point"
                },
                coordinates: {
                    type: [Number], // [longitude, latitude]
                    default: [0, 0]
                }
            },
            radiusKm: {
                type: Number,
                default: 10,
                min: [1, "Radius must be at least 1 km"],
                max: [50, "Radius cannot exceed 50 km"]
            }
        },
        currentLocation: {
            type: {
                type: String,
                enum: ["Point"],
                default: "Point"
            },
            coordinates: {
                type: [Number], // [longitude, latitude]
                default: [0, 0]
            }
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
        completedVisits: {
            type: Number,
            default: 0
        },
        cancelledVisits: {
            type: Number,
            default: 0
        },
        completionRate: {
            type: Number,
            default: 100, // percentage
            min: 0,
            max: 100
        },
        avgResponseTime: {
            type: Number, // in seconds
            default: 0
        },
        // Financial
        totalEarnings: {
            type: Number,
            default: 0
        },
        pendingBalance: {
            type: Number,
            default: 0
        },
        availableBalance: {
            type: Number,
            default: 0
        },
        bankAccount: {
            bankName: { type: String, trim: true },
            accountNumber: { type: String, trim: true },
            accountHolderName: { type: String, trim: true }
        },
        eWallet: {
            provider: { type: String, trim: true }, // e.g., "vodafone_cash", "fawry"
            number: { type: String, trim: true }
        },
        supervisingDoctors: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: "Doctor"
            }
        ]
    },
    { timestamps: true }
);

// Geospatial indexes for location-based queries
nurseSchema.index({ "workZone.center": "2dsphere" });
nurseSchema.index({ "currentLocation": "2dsphere" });

module.exports = mongoose.model("Nurse", nurseSchema);