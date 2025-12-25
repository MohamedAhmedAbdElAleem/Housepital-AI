const mongoose = require("mongoose");

const workingHoursSchema = new mongoose.Schema({
    day: {
        type: String,
        enum: ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"],
        required: true
    },
    isOpen: {
        type: Boolean,
        default: true
    },
    openTime: {
        type: String, // "09:00"
        required: function() { return this.isOpen; }
    },
    closeTime: {
        type: String, // "17:00"
        required: function() { return this.isOpen; }
    },
    breakStart: String, // Optional break time
    breakEnd: String
}, { _id: false });

const clinicSchema = new mongoose.Schema(
    {
        doctor: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Doctor",
            required: [true, "Doctor ID is required"],
            index: true
        },
        name: {
            type: String,
            required: [true, "Clinic name is required"],
            trim: true,
            minlength: [3, "Clinic name must be at least 3 characters"],
            maxlength: [100, "Clinic name cannot exceed 100 characters"]
        },
        description: {
            type: String,
            trim: true,
            maxlength: [500, "Description cannot exceed 500 characters"]
        },
        // Address
        address: {
            street: {
                type: String,
                required: [true, "Street address is required"],
                trim: true
            },
            area: {
                type: String,
                trim: true
            },
            city: {
                type: String,
                required: [true, "City is required"],
                trim: true
            },
            state: {
                type: String,
                required: [true, "State is required"],
                trim: true
            },
            zipCode: String,
            landmark: String
        },
        location: {
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
        // Contact
        phone: {
            type: String,
            trim: true,
            match: [/^01[0125][0-9]{8}$/, "Invalid Egyptian mobile number"]
        },
        // Media
        images: [{
            type: String,
            trim: true
        }],
        // Working Hours
        workingHours: [workingHoursSchema],
        // Booking Settings
        slotDurationMinutes: {
            type: Number,
            default: 30,
            min: [10, "Slot duration must be at least 10 minutes"],
            max: [120, "Slot duration cannot exceed 120 minutes"]
        },
        maxPatientsPerSlot: {
            type: Number,
            default: 1,
            min: 1
        },
        // Verification
        verificationStatus: {
            type: String,
            enum: ["pending", "approved", "rejected"],
            default: "pending"
        },
        verificationDocuments: [{
            type: String,
            trim: true
        }],
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
        // Status
        isActive: {
            type: Boolean,
            default: true
        },
        // Metrics
        totalAppointments: {
            type: Number,
            default: 0
        },
        completedAppointments: {
            type: Number,
            default: 0
        }
    },
    { timestamps: true }
);

// Geospatial index for location-based queries
clinicSchema.index({ location: "2dsphere" });
clinicSchema.index({ doctor: 1, isActive: 1 });

module.exports = mongoose.model("Clinic", clinicSchema);
