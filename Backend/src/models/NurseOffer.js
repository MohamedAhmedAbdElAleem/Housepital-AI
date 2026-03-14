const mongoose = require("mongoose");

const nurseOfferSchema = new mongoose.Schema(
    {
        // Links
        matchingRequestId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "MatchingRequest",
            required: [true, "Matching request ID is required"],
            index: true
        },
        nurseId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Nurse",
            required: [true, "Nurse ID is required"],
            index: true
        },
        patientId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: [true, "Patient ID is required"]
        },

        // Nurse info snapshot (denormalized for fast reads by patient)
        nurseSnapshot: {
            name: { type: String },
            profilePictureUrl: { type: String },
            rating: { type: Number },
            totalRatings: { type: Number },
            yearsOfExperience: { type: Number },
            completedVisits: { type: Number },
            specialization: { type: String },
            gender: { type: String }
        },

        // Pricing breakdown
        servicePrice: {
            type: Number,
            required: true
        },
        distanceKm: {
            type: Number,
            required: true
        },
        destinationFee: {
            type: Number,
            required: true
        },
        totalPrice: {
            type: Number,
            required: true
            // totalPrice = servicePrice + destinationFee
        },
        platformFee: {
            type: Number,
            required: true
            // platformFee = totalPrice * 0.10  (10% admin commission)
        },
        nurseEarnings: {
            type: Number,
            required: true
            // nurseEarnings = totalPrice - platformFee
        },
        currency: {
            type: String,
            default: "EGP"
        },

        // ETA
        estimatedArrivalMinutes: {
            type: Number,
            required: true
        },

        // Matching score (from algorithm)
        matchScore: {
            type: Number,
            default: 0
        },

        // Nurse response
        nurseStatus: {
            type: String,
            enum: ["pending", "accepted", "declined", "expired"],
            default: "pending"
        },
        nurseRespondedAt: {
            type: Date
        },
        nurseExpiresAt: {
            type: Date,
            default: () => new Date(Date.now() + 60 * 1000) // 60 second window
        },

        // Patient response (only relevant after nurse accepts)
        patientStatus: {
            type: String,
            enum: ["pending", "accepted", "declined", "not_applicable"],
            default: "not_applicable"
        },
        patientRespondedAt: {
            type: Date
        },

        // Final result
        bookingId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Booking"
        }
    },
    { timestamps: true }
);

// Indexes
nurseOfferSchema.index({ nurseId: 1, nurseStatus: 1 });
nurseOfferSchema.index({ matchingRequestId: 1, nurseStatus: 1 });
nurseOfferSchema.index({ patientId: 1, patientStatus: 1 });
nurseOfferSchema.index({ nurseExpiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL for auto-cleanup

module.exports = mongoose.model("NurseOffer", nurseOfferSchema);
