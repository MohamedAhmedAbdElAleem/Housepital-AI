const mongoose = require("mongoose");

const medicationLogSchema = new mongoose.Schema({
    patientId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    dependentId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Dependent"
    },
    medicineName: {
        type: String,
        required: true,
        trim: true
    },
    dosage: {
        type: String,
        required: true
    },
    scheduledTime: {
        type: Date,
        required: true
    },
    status: {
        type: String,
        enum: ["Pending", "Taken", "Missed", "Skipped"],
        default: "Pending"
    },
    takenAt: {
        type: Date
    },
    notes: {
        type: String
    }
}, { timestamps: true });

// Index for daily queries
medicationLogSchema.index({ patientId: 1, scheduledTime: 1 });

module.exports = mongoose.model("MedicationLog", medicationLogSchema);
