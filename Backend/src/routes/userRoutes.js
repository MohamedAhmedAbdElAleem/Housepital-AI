const express = require("express");
const router = express.Router();
const {
	register,
	login,
	getCurrentUser,
} = require("../controllers/authController");
const { updateUserValidator } = require("../middleware/validation");
const {
	updateInfo,
	getUserinfo,
	updateProfile,
	getSingleDependent,
	addDependent,
	getAllDependents,
} = require("../controllers/userController");
const { authenticateToken } = require("../middleware/authMiddleware");

router.patch("/updateInfo", updateUserValidator, updateInfo);
router.get("/getUserInfo", getUserinfo);
router.put("/update-profile", authenticateToken, updateProfile);
router.get("/getSingleDependent", getSingleDependent);
router.post("/addDependent", addDependent);
// Support both GET and POST for getAllDependents (body contains user ID)
router.get("/getAllDependents", getAllDependents);
router.post("/getAllDependents", getAllDependents);

// Address routes
router.get("/addresses/:userId", authenticateToken, async (req, res) => {
	try {
		const User = require("../models/User");
		const user = await User.findById(req.params.userId).select("addresses");
		if (!user) {
			return res.status(404).json({ message: "User not found" });
		}
		res.json({ addresses: user.addresses || [] });
	} catch (error) {
		res.status(500).json({ message: error.message });
	}
});

router.post("/addresses", authenticateToken, async (req, res) => {
	try {
		const User = require("../models/User");
		const {
			userId,
			label,
			type,
			street,
			area,
			city,
			state,
			zipCode,
			isDefault,
		} = req.body;

		const user = await User.findById(userId);
		if (!user) {
			return res.status(404).json({ message: "User not found" });
		}

		// If setting as default, unset other defaults
		if (isDefault) {
			user.addresses.forEach((addr) => (addr.isDefault = false));
		}

		user.addresses.push({
			label: label || "",
			type: type || "home",
			street,
			area,
			city,
			state,
			zipCode,
			isDefault: isDefault || false,
		});

		await user.save();
		res.status(201).json({
			message: "Address added successfully",
			addresses: user.addresses,
		});
	} catch (error) {
		res.status(500).json({ message: error.message });
	}
});

router.put("/addresses/:addressId", authenticateToken, async (req, res) => {
	try {
		const User = require("../models/User");
		const {
			userId,
			label,
			type,
			street,
			area,
			city,
			state,
			zipCode,
			isDefault,
		} = req.body;

		const user = await User.findById(userId);
		if (!user) {
			return res.status(404).json({ message: "User not found" });
		}

		const address = user.addresses.id(req.params.addressId);
		if (!address) {
			return res.status(404).json({ message: "Address not found" });
		}

		// If setting as default, unset other defaults
		if (isDefault) {
			user.addresses.forEach((addr) => {
				if (addr._id.toString() !== req.params.addressId) {
					addr.isDefault = false;
				}
			});
		}

		address.label = label !== undefined ? label : address.label;
		address.type = type || address.type;
		address.street = street || address.street;
		address.area = area || address.area;
		address.city = city || address.city;
		address.state = state || address.state;
		address.zipCode = zipCode || address.zipCode;
		address.isDefault = isDefault;

		await user.save();
		res.json({
			message: "Address updated successfully",
			addresses: user.addresses,
		});
	} catch (error) {
		res.status(500).json({ message: error.message });
	}
});

router.delete("/addresses/:addressId", authenticateToken, async (req, res) => {
	try {
		const User = require("../models/User");
		const userId = req.body.userId || req.query.userId;

		const user = await User.findById(userId);
		if (!user) {
			return res.status(404).json({ message: "User not found" });
		}

		user.addresses.pull(req.params.addressId);
		await user.save();

		res.json({
			message: "Address deleted successfully",
			addresses: user.addresses,
		});
	} catch (error) {
		res.status(500).json({ message: error.message });
	}
});

// Dependent routes
router.put("/dependent/:dependentId", authenticateToken, async (req, res) => {
	try {
		const User = require("../models/User");
		const Dependent = require("../models/dependent");
		const {
			fullName,
			relationship,
			gender,
			dateOfBirth,
			chronicConditions,
			allergies,
			mobile,
			nationalId,
			birthCertificateId,
		} = req.body;

		const dependent = await Dependent.findById(req.params.dependentId);
		if (!dependent) {
			return res.status(404).json({ message: "Dependent not found" });
		}

		dependent.fullName = fullName || dependent.fullName;
		dependent.relationship = relationship || dependent.relationship;
		dependent.gender = gender || dependent.gender;
		dependent.dateOfBirth = dateOfBirth || dependent.dateOfBirth;

		// Handle chronic conditions - convert comma-separated string to array if needed
		if (chronicConditions !== undefined) {
			if (typeof chronicConditions === "string") {
				dependent.chronicConditions = chronicConditions
					.split(",")
					.map((c) => c.trim())
					.filter((c) => c);
			} else if (Array.isArray(chronicConditions)) {
				dependent.chronicConditions = chronicConditions;
			}
		}

		// Handle allergies - convert comma-separated string to array if needed
		if (allergies !== undefined) {
			if (typeof allergies === "string") {
				dependent.allergies = allergies
					.split(",")
					.map((a) => a.trim())
					.filter((a) => a);
			} else if (Array.isArray(allergies)) {
				dependent.allergies = allergies;
			}
		}

		if (mobile !== undefined) dependent.mobile = mobile;
		if (nationalId !== undefined) dependent.nationalId = nationalId;
		if (birthCertificateId !== undefined)
			dependent.birthCertificateId = birthCertificateId;

		await dependent.save();
		res.json({ message: "Dependent updated successfully", dependent });
	} catch (error) {
		res.status(500).json({ message: error.message });
	}
});

router.delete(
	"/dependent/:dependentId",
	authenticateToken,
	async (req, res) => {
		try {
			const Dependent = require("../models/dependent");

			const dependent = await Dependent.findByIdAndDelete(
				req.params.dependentId
			);
			if (!dependent) {
				return res.status(404).json({ message: "Dependent not found" });
			}

			res.json({ message: "Dependent deleted successfully" });
		} catch (error) {
			res.status(500).json({ message: error.message });
		}
	}
);

module.exports = router;
