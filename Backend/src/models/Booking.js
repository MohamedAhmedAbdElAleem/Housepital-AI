const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema({
	// Booking Type
	type: {
		type: String,
		enum: ["home_nursing", "clinic_appointment"],
		required: true,
		default: "home_nursing"
	},

	// Service Information
	serviceId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "Service"
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
	dependentId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "Dependent"
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

	// Medical Tools (for home nursing)
	hasMedicalTools: {
		type: Boolean,
		default: false,
	},
	toolsProvidedByNurse: {
		type: Boolean,
		default: false
	},
	toolsDeposit: {
		type: Number,
		default: 0
	},
	actualToolsCost: {
		type: Number,
		default: 0
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
	isRushBooking: {
		type: Boolean,
		default: false
	},
	rushPremiumAmount: {
		type: Number,
		default: 0
	},

	// Service Location (for home nursing)
	addressId: {
		type: String,
	},
	address: {
		street: String,
		area: String,
		city: String,
		state: String,
		coordinates: {
			type: {
				type: String,
				enum: ["Point"]
			},
			coordinates: [Number] // [longitude, latitude]
		}
	},

	// Clinic Information (for clinic appointments)
	clinicId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "Clinic"
	},
	doctorId: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "Doctor"
	},

	// Nurse Gender Preference
	nurseGenderPreference: {
		type: String,
		enum: ["male", "female", "any"],
		default: "any"
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
			"searching",      // looking for nurse/confirming
			"confirmed",
			"assigned",
			"in-progress",
			"completed",
			"cancelled",
			"no-show"
		],
		default: "pending",
	},

	// Assigned Provider
	assignedNurse: {
		type: mongoose.Schema.Types.ObjectId,
		ref: "Nurse",
	},

	// Matching Process (for home nursing)
	matchingAttempts: {
		type: Number,
		default: 0
	},
	nurseResponseTime: {
		type: Number, // in seconds
		default: 0
	},

	// Visit Security & Tracking
	visitPin: {
		type: String,
		minlength: 4,
		maxlength: 4
	},
	visitQrCode: {
		type: String
	},
	checkedInAt: {
		type: Date
	},
	visitStartedAt: {
		type: Date
	},
	visitEndedAt: {
		type: Date
	},
	visitReport: {
		type: String,
		trim: true
	},

	// Cancellation Details
	cancelledBy: {
		type: String,
		enum: ["customer", "nurse", "doctor", "system", "admin"]
	},
	cancelledAt: {
		type: Date
	},
	cancellationReason: {
		type: String,
		trim: true
	},
	cancellationFee: {
		type: Number,
		default: 0
	},
	refundAmount: {
		type: Number,
		default: 0
	},

	// Ratings
	customerRating: {
		type: Number,
		min: 1,
		max: 5
	},
	customerReview: {
		type: String,
		trim: true
	},
	providerRating: {
		type: Number,
		min: 1,
		max: 5
	},
	providerReview: {
		type: String,
		trim: true
	},

	// Payment
	totalAmount: {
		type: Number,
		default: 0
	},
	paymentStatus: {
		type: String,
		enum: ["pending", "partial", "paid", "refunded"],
		default: "pending",
	},
	paymentMethod: {
		type: String,
		enum: ["cash", "card", "wallet", "fawry"]
	},
	paidAt: {
		type: Date
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

// Indexes for efficient queries
bookingSchema.index({ userId: 1, status: 1 });
bookingSchema.index({ assignedNurse: 1, status: 1 });
bookingSchema.index({ doctorId: 1, status: 1 });
bookingSchema.index({ clinicId: 1, scheduledDate: 1 });
bookingSchema.index({ type: 1, status: 1 });
bookingSchema.index({ createdAt: -1 });

// Update the updatedAt field before saving
bookingSchema.pre("save", function (next) {
	this.updatedAt = Date.now();
	next();
});

module.exports = mongoose.model("Booking", bookingSchema);
