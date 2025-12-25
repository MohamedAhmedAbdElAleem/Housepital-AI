const User = require("../models/User");
const Dependent = require("../models/Dependent");
const { logEvents } = require("../middleware/logger");
const jwt = require("jsonwebtoken");
const { createRedisClient } = require("../caching/redis");
const redis = createRedisClient();
const bcrypt = require("bcryptjs");

exports.updateInfo = async (req, res) => {
	try {
		const id = req.body.id;
		const data = req.body;

		const fields = Object.keys(User.schema.paths).filter(
			(f) => !["_id", "__v"].includes(f)
		);

		const updateData = {};
		for (const key in data) {
			if (fields.includes(key)) {
				updateData[key] = data[key];
			}
		}

		if ("password" in data) {
			const password = data.password;
			const salt = await bcrypt.genSalt(12);
			updateData.password_hash = await bcrypt.hash(password, salt);
			updateData.salt = salt;
			delete updateData.password;
		}

		const updatedUser = await User.findByIdAndUpdate(
			id,
			{ $set: updateData },
			{ new: true, runValidators: true }
		);

		return res.status(200).json(updatedUser);
	} catch (err) {
		console.error(err);
		return res.status(500).json({ error: "Something went wrong" });
	}
};

exports.getUserinfo = async (req, res) => {
	try {
		const id = req.body.id;
		if (!id) return res.status(400).json({ message: "No ID provided" });

		const user = await User.findById(id);

		if (!user) return res.status(404).json({ message: "User not found" });

		return res.status(200).json(user);
	} catch (err) {
		console.error(err);
		return res.status(500).json({ error: "Something went wrong" });
	}
};

/**
 * @desc    Update user profile (name, email, mobile)
 * @route   PUT /api/user/update-profile
 * @access  Private
 */
exports.updateProfile = async (req, res) => {
	try {
		const { name, email, mobile } = req.body;
		const userId = req.user.id;

		// Validate inputs
		if (!name || !email || !mobile) {
			return res.status(400).json({
				success: false,
				message: "Name, email, and mobile are required",
			});
		}

		// Convert email to lowercase
		const emailLowerCase = email.toLowerCase();

		// Check if email is already used by another user
		const existingUser = await User.findOne({
			email: emailLowerCase,
			_id: { $ne: userId },
		});

		if (existingUser) {
			return res.status(400).json({
				success: false,
				message: "Email is already in use by another account",
			});
		}

		// Check if mobile is already used by another user
		const existingMobile = await User.findOne({
			mobile: mobile,
			_id: { $ne: userId },
		});

		if (existingMobile) {
			return res.status(400).json({
				success: false,
				message: "Mobile number is already in use by another account",
			});
		}

		// Update user
		const user = await User.findByIdAndUpdate(
			userId,
			{
				name: name.trim(),
				email: emailLowerCase,
				mobile: mobile.trim(),
			},
			{ new: true, runValidators: true }
		);

		if (!user) {
			return res.status(404).json({
				success: false,
				message: "User not found",
			});
		}

		// Log the update
		logEvents(`User profile updated: ${user.email}`, "userLog.log");

		res.status(200).json({
			success: true,
			message: "Profile updated successfully",
			user: user.toJSON(),
		});
	} catch (error) {
		logEvents(`Update profile error: ${error.message}`, "userErrLog.log");

		res.status(500).json({
			success: false,
			message: error.message || "Error updating profile",
		});
	}
};

exports.getSingleDependent = async (req, res) => {
	const id = req.body._id || req.body.id;
	if (!id) return res.status(400).json({ message: "No ID provided" });

	const dependentId = req.body.dependentId;

	try {
		const dependentUser = await Dependent.findOne({
			responsibleUser: id,
			_id: dependentId,
		});
		if (!dependentUser)
			return res.status(404).json({ message: "This person is not found" });

		return res.status(200).json(dependentUser);
	} catch (err) {
		console.log(err);

		return res.status(500).json({ error: "An error occurred" });
	}
};

exports.addDependent = async (req, res) => {
	try {
		const userId = req.body._id || req.body.id;

		const {
			fullName,
			relationship,
			dateOfBirth,
			gender,
			mobile,
			chronicConditions,
			allergies,
			nationalId,
			birthCertificateId,
			responsibleUser,
		} = req.body;

		if (!nationalId && !birthCertificateId) {
			return res.status(400).json({
				message: "Either national ID or birth certificate ID is required",
			});
		}

		// Handle chronic conditions - convert comma-separated string to array if needed
		let chronicConditionsArray = [];
		if (chronicConditions) {
			if (typeof chronicConditions === "string") {
				chronicConditionsArray = chronicConditions
					.split(",")
					.map((c) => c.trim())
					.filter((c) => c);
			} else if (Array.isArray(chronicConditions)) {
				chronicConditionsArray = chronicConditions;
			}
		}

		// Handle allergies - convert comma-separated string to array if needed
		let allergiesArray = [];
		if (allergies) {
			if (typeof allergies === "string") {
				allergiesArray = allergies
					.split(",")
					.map((a) => a.trim())
					.filter((a) => a);
			} else if (Array.isArray(allergies)) {
				allergiesArray = allergies;
			}
		}

		const newDependent = new Dependent({
			fullName,
			relationship,
			dateOfBirth,
			gender,
			mobile,
			chronicConditions: chronicConditionsArray,
			allergies: allergiesArray,
			nationalId,
			birthCertificateId,
			responsibleUser,
		});

		await newDependent.save();

		return res.status(201).json({
			success: true,
			message: "Dependent added successfully",
			dependent: newDependent,
		});
	} catch (err) {
		console.error(err);
		return res.status(500).json({ error: err.message });
	}
};

exports.getAllDependents = async (req, res) => {
	const id = req.body._id || req.body.id;
	if (!id) return res.status(400).json("No ID provided");

	try {
		const dependents = await Dependent.find({ responsibleUser: id });

		return res.status(200).json(dependents);
	} catch (err) {
		console.log(err);
		return res
			.status(500)
			.json({ message: "An error occurred", error: err.message });
	}
};
