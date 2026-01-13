const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const userSchema = new mongoose.Schema(
	{
		name: {
			type: String,
			required: [true, "Please provide a name"],
			trim: true,
			minlength: [2, "Name must be at least 2 characters"],
			maxlength: [50, "Name cannot exceed 50 characters"],
		},
		gender: {
			type: String,
			enum: ["male", "female"],
		},
		dateOfBirth: {
			type: Date,
		},
		profilePictureUrl: {
			type: String,
			trim: true,
		},
		email: {
			type: String,
			required: [true, "Please provide an email"],
			unique: true,
			lowercase: true,
			match: [
				/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
				"Please provide a valid email address",
			],
		},
		mobile: {
			type: String,
			required: [true, "Please provide a mobile number"],
			unique: true,
			match: [
				/^01[0125][0-9]{8}$/,
				"Please provide a valid Egyptian mobile number",
			],
		},
		password_hash: {
			type: String,
			required: [true, "Please provide a password"],
			minlength: [6, "Password must be at least 6 characters"],
			select: false, // Don't include password in queries by default
		},
		salt: {
			type: String,
			select: false, // Store salt for reference
		},
		hashingAlgorithm: {
			type: String,
			default: "bcrypt",
			select: false,
		},
		costFactor: {
			type: Number,
			default: 12, // bcrypt cost factor
			select: false,
		},
		isVerified: {
			type: Boolean,
			default: false,
		},
		role: {
			type: String,
			enum: ["customer", "nurse", "doctor", "admin"],
			default: "customer",
		},
		// Account Status & Verification
		status: {
			type: String,
			enum: ["pending", "approved", "rejected", "suspended"],
			default: "pending",
		},
		verificationStatus: {
			type: String,
			enum: ["unverified", "pending", "verified", "rejected"],
			default: "unverified",
		},
		idDocumentUrl: {
			type: String,
			trim: true,
		},
		approvedBy: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "User",
		},
		approvedAt: {
			type: Date,
		},
		rejectionReason: {
			type: String,
			trim: true,
		},
		// ID Document Images
		idFrontImageUrl: {
			type: String,
			trim: true,
		},
		idBackImageUrl: {
			type: String,
			trim: true,
		},
		// Medical Information
		medicalInfo: {
			bloodType: {
				type: String,
				enum: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", null],
				default: null,
			},
			chronicDiseases: [{
				type: String,
				trim: true,
			}],
			allergies: [{
				type: String,
				trim: true,
			}],
			otherConditions: {
				type: String,
				trim: true,
			},
			currentMedications: {
				type: String,
				trim: true,
			},
			hasNoChronicDiseases: {
				type: Boolean,
				default: false,
			},
			hasNoAllergies: {
				type: Boolean,
				default: false,
			},
			updatedAt: {
				type: Date,
			},
		},
		// Activity Tracking
		lastActiveAt: {
			type: Date,
			default: Date.now,
		},
		isOnline: {
			type: Boolean,
			default: false,
		},
		profileCompletedAt: {
			type: Date,
		},
		wallet: {
			type: Number,
			default: 0,
		},
		totalVisits: {
			type: Number,
			default: 0,
		},
		savedServices: {
			type: Number,
			default: 0,
		},
		resetOTP: {
			type: String,
			select: false,
		},
		otpExpires: {
			type: Date,
			select: false,
		},
		otpAttempts: {
			type: Number,
			default: 0,
			select: false,
		},
		addresses: [
			{
				label: {
					type: String,
					trim: true,
				},
				type: {
					type: String,
					enum: ["home", "work", "other"],
					default: "home",
				},
				street: {
					type: String,
					required: true,
				},
				area: {
					type: String,
					trim: true,
					default: "",
				},
				city: {
					type: String,
					required: true,
				},
				state: {
					type: String,
					required: true,
				},
				zipCode: String,
				isDefault: {
					type: Boolean,
					default: false,
				},
			},
		],
	},
	{
		timestamps: true,
	}
);

// Hash password before saving
userSchema.pre("save", async function (next) {
	if (!this.isModified("password_hash")) {
		return next();
	}

	try {
		// Generate salt and hash passwsord with bcrypt (cost factor 12)
		const salt = await bcrypt.genSalt(12);
		this.password_hash = await bcrypt.hash(this.password_hash, salt);
		this.salt = salt;
		this.hashingAlgorithm = "bcrypt";
		this.costFactor = 12;
		next();
	} catch (error) {
		next(error);
	}
});

// Method to compare password with stored hash
userSchema.methods.comparePassword = async function (enteredPassword) {
	return await bcrypt.compare(enteredPassword, this.password_hash);
};

// Prevent logging sensitive data
userSchema.methods.toJSON = function () {
	const userObj = this.toObject();
	delete userObj.password_hash;
	delete userObj.salt;
	delete userObj.hashingAlgorithm;
	delete userObj.costFactor;
	return userObj;
};

module.exports = mongoose.model("User", userSchema);
