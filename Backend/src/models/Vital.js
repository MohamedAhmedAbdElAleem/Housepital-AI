const mongoose = require("mongoose");

const vitalSchema = new mongoose.Schema({
    patientId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User", // Can be a User or Dependent (if we link dependents to User collection properly)
        required: true
    },
    // If we want to link explicitly to Dependent model as well
    dependentId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Dependent"
    },
    type: {
        type: String,
        required: true,
        enum: ["Blood Pressure", "Blood Sugar", "Heart Rate", "Temperature", "Oxygen Saturation", "Weight"]
    },
    value: {
        type: String, // String to handle "120/80" for BP
        required: true
    },
    unit: {
        type: String,
        required: true
    },
    status: {
        type: String,
        enum: ["Normal", "High", "Low", "Critical"],
        default: "Normal"
    },
    measuredAt: {
        type: Date,
        default: Date.now
    },
    notes: {
        type: String,
        trim: true
    }
}, { timestamps: true });

// Index for getting recent vitals
vitalSchema.index({ patientId: 1, type: 1, measuredAt: -1 });

module.exports = mongoose.model("Vital", vitalSchema);
