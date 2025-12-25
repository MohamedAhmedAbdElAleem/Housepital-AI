const User = require("../models/User");
const Dependent = require("../models/dependent");
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
		const { name, mobile } = req.body;
		const userId = req.user.id;

		// Build update object - only include fields that were provided
		const updateData = {};

		if (name && name.trim()) {
			updateData.name = name.trim();
		}

		if (mobile && mobile.trim()) {
			// Normalize mobile - remove spaces and special chars
			const normalizedMobile = mobile.trim().replace(/[\s-]/g, '');

			// Check if mobile is already used by another user
			const existingMobile = await User.findOne({
				mobile: normalizedMobile,
				_id: { $ne: userId },
			});

			if (existingMobile) {
				return res.status(400).json({
					success: false,
					message: "Mobile number is already in use by another account",
				});
			}

			updateData.mobile = normalizedMobile;
		}

		// If nothing to update
		if (Object.keys(updateData).length === 0) {
			return res.status(400).json({
				success: false,
				message: "No valid fields to update",
			});
		}

		// Update user without validators for partial updates
		const user = await User.findByIdAndUpdate(
			userId,
			{ $set: updateData },
			{ new: true }
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

exports.updateDependent = async (req, res) => {
	try {
		const { id, ...updateData } = req.body;

		if (!id) {
			return res.status(400).json({
				success: false,
				message: "Dependent ID is required",
			});
		}

		// Handle chronic conditions and allergies arrays
		if (updateData.chronicConditions && typeof updateData.chronicConditions === "string") {
			updateData.chronicConditions = updateData.chronicConditions
				.split(",")
				.map((c) => c.trim())
				.filter((c) => c);
		}

		if (updateData.allergies && typeof updateData.allergies === "string") {
			updateData.allergies = updateData.allergies
				.split(",")
				.map((a) => a.trim())
				.filter((a) => a);
		}

		const updatedDependent = await Dependent.findByIdAndUpdate(
			id,
			updateData,
			{ new: true, runValidators: true }
		);

		if (!updatedDependent) {
			return res.status(404).json({
				success: false,
				message: "Dependent not found",
			});
		}

		return res.status(200).json({
			success: true,
			message: "Dependent updated successfully",
			dependent: updatedDependent,
		});
	} catch (err) {
		console.error("Update Dependent Error:", err);
		return res.status(500).json({
			success: false,
			message: "An error occurred",
			error: err.message,
		});
	}
};

exports.deleteDependent = async (req, res) => {
	try {
		const id = req.query.id || req.body.id;

		if (!id) {
			return res.status(400).json({
				success: false,
				message: "Dependent ID is required",
			});
		}

		const deletedDependent = await Dependent.findByIdAndDelete(id);

		if (!deletedDependent) {
			return res.status(404).json({
				success: false,
				message: "Dependent not found",
			});
		}

		return res.status(200).json({
			success: true,
			message: "Dependent deleted successfully",
		});
	} catch (err) {
		console.error("Delete Dependent Error:", err);
		return res.status(500).json({
			success: false,
			message: "An error occurred",
			error: err.message,
		});
	}
};

