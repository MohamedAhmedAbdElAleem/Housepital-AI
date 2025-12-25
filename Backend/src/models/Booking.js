const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema({
	// Service Information
	serviceId: {
		type: String,
		required: true,
	},
	serviceName: {
		type: String,
		required: true,
	},
	servicePrice: {
		type: Number,
		required: true,
	},

	// Patient Information
	patientId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "User",
		required: true,
	},
	patientName: {
		type: String,
		required: true,
	},
	isForSelf: {
		type: Boolean,
		default: false,
	},

	// User who created the booking
	userId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "User",
		required: true,
	},

	// Medical Tools
	hasMedicalTools: {
		type: Boolean,
		default: false,
	},

	// Visit Details
	timeOption: {
		type: String,
		enum: ["asap", "schedule"],
		required: true,
	},
	scheduledDate: {
		type: Date,
	},
	scheduledTime: {
		type: String,
	},

	// Service Location
	addressId: {
		type: String,
	},

	// Nurse Gender Preference
	nurseGenderPreference: {
		type: String,
		enum: ["male", "female"],
	},

	// Additional Information
	notes: {
		type: String,
		default: "",
	},
	prescriptionUrl: {
		type: String,
	},

	// Booking Status
	status: {
		type: String,
		enum: [
			"pending",
			"confirmed",
			"assigned",
			"in-progress",
			"completed",
			"cancelled",
		],
		default: "pending",
	},

	// Assigned Nurse
	assignedNurse: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "User",
	},

	// Payment
	paymentStatus: {
		type: String,
		enum: ["pending", "paid", "refunded"],
		default: "pending",
	},
	paymentMethod: {
		type: String,
	},

	// Timestamps
	createdAt: {
		type: Date,
		default: Date.now,
	},
	updatedAt: {
		type: Date,
		default: Date.now,
	},
});

// Update the updatedAt field before saving
bookingSchema.pre("save", function (next) {
	this.updatedAt = Date.now();
	next();
});

module.exports = mongoose.model("Booking", bookingSchema);
