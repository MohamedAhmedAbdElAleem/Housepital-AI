const mongoose = require("mongoose");

const systemSettingsSchema = new mongoose.Schema(
    {
        // Platform Config
        commissionRate: {
            type: Number,
            default: 0.10, // 10%
        },
        minDestinationFee: {
            type: Number,
            default: 15,
        },
        maxDestinationFee: {
            type: Number,
            default: 200,
        },
        payoutSchedule: {
            type: String,
            enum: ["daily", "weekly", "monthly"],
            default: "weekly",
        },

        // Global Notification Toggles (for Admin Dashboard)
        adminNotifications: {
            newBookings: { type: Boolean, default: true },
            newVerifications: { type: Boolean, default: true },
            revenueAlerts: { type: Boolean, default: false },
        },

        // Platform State
        isMaintenanceMode: {
            type: Boolean,
            default: false,
        },

        lastUpdatedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
        }
    },
    { timestamps: true }
);

// Ensure only one settings document exists
systemSettingsSchema.statics.getSettings = async function() {
    let settings = await this.findOne();
    if (!settings) {
        settings = await this.create({});
    }
    return settings;
};

module.exports = mongoose.model("SystemSettings", systemSettingsSchema);
