const mongoose = require("mongoose");

const serviceSchema = new mongoose.Schema(
    {
        // Service Basic Info
        name: {
            type: String,
            required: [true, "Service name is required"],
            trim: true,
            minlength: [3, "Service name must be at least 3 characters"],
            maxlength: [100, "Service name cannot exceed 100 characters"]
        },
        nameAr: {
            type: String,
            trim: true,
            maxlength: [100, "Arabic name cannot exceed 100 characters"]
        },
        description: {
            type: String,
            trim: true,
            maxlength: [500, "Description cannot exceed 500 characters"]
        },
        descriptionAr: {
            type: String,
            trim: true,
            maxlength: [500, "Arabic description cannot exceed 500 characters"]
        },
        // Service Type
        type: {
            type: String,
            enum: ["home_nursing", "clinic"],
            required: [true, "Service type is required"]
        },
        category: {
            type: String,
            required: [true, "Category is required"],
            trim: true
            // e.g., "wound_care", "injections", "elderly_care", "general_checkup"
        },
        // Provider
        providerId: {
            type: mongoose.Schema.Types.ObjectId,
            refPath: "providerModel",
            required: [true, "Provider ID is required"]
        },
        providerModel: {
            type: String,
            enum: ["Nurse", "Doctor"],
            required: true
        },
        // For doctor services - which clinics offer this service
        clinics: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: "Clinic"
        }],
        // Pricing
        price: {
            type: Number,
            required: [true, "Price is required"],
            min: [0, "Price cannot be negative"]
        },
        currency: {
            type: String,
            default: "EGP"
        },
        // Duration
        durationMinutes: {
            type: Number,
            required: [true, "Duration is required"],
            min: [5, "Duration must be at least 5 minutes"],
            max: [480, "Duration cannot exceed 8 hours"]
        },
        // Tools/Equipment
        requiresTools: {
            type: Boolean,
            default: false
        },
        toolsList: [{
            name: String,
            estimatedCost: Number
        }],
        estimatedToolsDeposit: {
            type: Number,
            default: 0
        },
        // Prescription
        requiresPrescription: {
            type: Boolean,
            default: false
        },
        // Status
        isActive: {
            type: Boolean,
            default: true
        },
        // Metrics
        totalBookings: {
            type: Number,
            default: 0
        },
        completedBookings: {
            type: Number,
            default: 0
        },
        avgRating: {
            type: Number,
            default: 0,
            min: 0,
            max: 5
        }
    },
    { timestamps: true }
);

// Indexes
serviceSchema.index({ type: 1, category: 1, isActive: 1 });
serviceSchema.index({ providerId: 1, providerModel: 1 });
serviceSchema.index({ name: "text", nameAr: "text" });

module.exports = mongoose.model("Service", serviceSchema);
