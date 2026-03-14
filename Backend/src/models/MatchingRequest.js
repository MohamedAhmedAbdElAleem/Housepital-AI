const mongoose = require("mongoose");

const matchingRequestSchema = new mongoose.Schema(
    {
        // Patient who is requesting
        patientId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: [true, "Patient ID is required"],
            index: true
        },

        // Service being requested
        serviceId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Service",
            required: [true, "Service ID is required"]
        },
        serviceName: {
            type: String,
            required: true
        },
        serviceCategory: {
            type: String,
            required: true
        },
        servicePrice: {
            type: Number,
            required: true
        },

        // Patient location (GeoJSON)
        location: {
            type: {
                type: String,
                enum: ["Point"],
                default: "Point"
            },
            coordinates: {
                type: [Number], // [longitude, latitude]
                required: [true, "Location coordinates are required"]
            }
        },

        // Address details
        address: {
            street: { type: String },
            area: { type: String },
            city: { type: String },
            state: { type: String }
        },

        // Preferences
        nurseGenderPreference: {
            type: String,
            enum: ["male", "female", "any"],
            default: "any"
        },

        // Time preference
        timeOption: {
            type: String,
            enum: ["asap", "schedule"],
            default: "asap"
        },
        scheduledDate: { type: Date },
        scheduledTime: { type: String },

        // Patient notes
        notes: {
            type: String,
            trim: true,
            default: ""
        },

        // Matching status
        status: {
            type: String,
            enum: [
                "searching",         // Looking for nurses
                "offers_pending",    // Offers sent to nurses, waiting for response
                "nurse_accepted",    // At least one nurse accepted, showing offers to patient
                "accepted",          // Patient accepted a nurse offer → booking created
                "expired",           // No nurses responded or timed out
                "cancelled",         // Patient cancelled the request
                "no_nurses_found"    // No eligible nurses found in area
            ],
            default: "searching"
        },

        // Matched nurses (found by algorithm)
        matchedNurses: [{
            nurseId: {
                type: mongoose.Schema.Types.ObjectId,
                ref: "Nurse"
            },
            score: { type: Number },
            distanceKm: { type: Number }
        }],

        // Search configuration used
        searchRadiusKm: {
            type: Number,
            default: 15
        },
        maxNurses: {
            type: Number,
            default: 5
        },

        // Timing
        searchStartedAt: {
            type: Date,
            default: Date.now
        },
        expiresAt: {
            type: Date,
            default: () => new Date(Date.now() + 10 * 60 * 1000) // 10 min expiry
        },

        // Result
        acceptedOfferId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "NurseOffer"
        },
        bookingId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Booking"
        }
    },
    { timestamps: true }
);

// Geospatial index for location-based queries
matchingRequestSchema.index({ location: "2dsphere" });
matchingRequestSchema.index({ status: 1, expiresAt: 1 });
matchingRequestSchema.index({ patientId: 1, status: 1 });

module.exports = mongoose.model("MatchingRequest", matchingRequestSchema);
