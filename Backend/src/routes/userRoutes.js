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
	updateDependent,
	deleteDependent,
} = require("../controllers/userController");
const { authenticateToken } = require("../middleware/authMiddleware");

/**
 * @openapi
 * /api/user/updateInfo:
 *   patch:
 *     tags:
 *       - User
 *     summary: Update User Info
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: User info updated
 */
router.patch("/updateInfo", updateUserValidator, updateInfo);

/**
 * @openapi
 * /api/user/getUserInfo:
 *   get:
 *     tags:
 *       - User
 *     summary: Get User Info
 *     responses:
 *       200:
 *         description: User info retrieved
 */
router.get("/getUserInfo", getUserinfo);

/**
 * @openapi
 * /api/user/update-profile:
 *   put:
 *     tags:
 *       - User
 *     summary: Update User Profile
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               phone:
 *                 type: string
 *     responses:
 *       200:
 *         description: Profile updated
 */
router.put("/update-profile", authenticateToken, updateProfile);

/**
 * @openapi
 * /api/user/getSingleDependent:
 *   get:
 *     tags:
 *       - Dependents
 *     summary: Get Single Dependent
 *     parameters:
 *       - in: query
 *         name: dependentId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Dependent details
 */
router.get("/getSingleDependent", getSingleDependent);

/**
 * @openapi
 * /api/user/addDependent:
 *   post:
 *     tags:
 *       - Dependents
 *     summary: Add Dependent
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - fullName
 *               - relationship
 *             properties:
 *               fullName:
 *                 type: string
 *               relationship:
 *                 type: string
 *               dateOfBirth:
 *                 type: string
 *                 format: date
 *     responses:
 *       200:
 *         description: Dependent added
 */
router.post("/addDependent", addDependent);

/**
 * @openapi
 * /api/user/updateDependent:
 *   put:
 *     tags:
 *       - Dependents
 *     summary: Update Dependent (Legacy)
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - dependentId
 *             properties:
 *               dependentId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Dependent updated
 */
router.put("/updateDependent", updateDependent);

/**
 * @openapi
 * /api/user/deleteDependent:
 *   delete:
 *     tags:
 *       - Dependents
 *     summary: Delete Dependent (Legacy)
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - dependentId
 *             properties:
 *               dependentId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Dependent deleted
 */
router.delete("/deleteDependent", deleteDependent);

/**
 * @openapi
 * /api/user/getAllDependents:
 *   get:
 *     tags:
 *       - Dependents
 *     summary: Get All Dependents
 *     parameters:
 *       - in: query
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of dependents
 */
router.get("/getAllDependents", getAllDependents);
router.post("/getAllDependents", getAllDependents);

// Address routes
/**
 * @openapi
 * /api/user/addresses/{userId}:
 *   get:
 *     tags:
 *       - Addresses
 *     summary: Get User Addresses
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of addresses
 *       404:
 *         description: User not found
 */
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

/**
 * @openapi
 * /api/user/addresses:
 *   post:
 *     tags:
 *       - Addresses
 *     summary: Add New Address
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - street
 *               - city
 *               - state
 *               - zipCode
 *             properties:
 *               userId:
 *                 type: string
 *               label:
 *                 type: string
 *               street:
 *                 type: string
 *               city:
 *                 type: string
 *               state:
 *                 type: string
 *               zipCode:
 *                 type: string
 *               isDefault:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Address added
 */
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

		await user.save({ validateBeforeSave: false });
		res.status(201).json({
			message: "Address added successfully",
			addresses: user.addresses,
		});
	} catch (error) {
		res.status(500).json({ message: error.message });
	}
});

/**
 * @openapi
 * /api/user/addresses/{addressId}:
 *   put:
 *     tags:
 *       - Addresses
 *     summary: Update Address
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: addressId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *             properties:
 *               userId:
 *                 type: string
 *               street:
 *                 type: string
 *               city:
 *                 type: string
 *     responses:
 *       200:
 *         description: Address updated
 */
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

		await user.save({ validateBeforeSave: false });
		res.json({
			message: "Address updated successfully",
			addresses: user.addresses,
		});
	} catch (error) {
		res.status(500).json({ message: error.message });
	}
});

/**
 * @openapi
 * /api/user/addresses/{addressId}:
 *   delete:
 *     tags:
 *       - Addresses
 *     summary: Delete Address
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: addressId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *             properties:
 *               userId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Address deleted
 */
router.delete("/addresses/:addressId", authenticateToken, async (req, res) => {
	try {
		const User = require("../models/User");
		const userId = req.body.userId || req.query.userId;

		const user = await User.findById(userId);
		if (!user) {
			return res.status(404).json({ message: "User not found" });
		}

		user.addresses.pull(req.params.addressId);
		await user.save({ validateBeforeSave: false });

		res.json({
			message: "Address deleted successfully",
			addresses: user.addresses,
		});
	} catch (error) {
		res.status(500).json({ message: error.message });
	}
});

// Dependent routes
/**
 * @openapi
 * /api/user/dependent/{dependentId}:
 *   put:
 *     tags:
 *       - Dependents
 *     summary: Update Specific Dependent
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: dependentId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               fullName:
 *                 type: string
 *               mobile:
 *                 type: string
 *     responses:
 *       200:
 *         description: Dependent updated
 */
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

/**
 * @openapi
 * /api/user/dependent/{dependentId}:
 *   delete:
 *     tags:
 *       - Dependents
 *     summary: Delete Specific Dependent
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: dependentId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Dependent deleted
 */
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
