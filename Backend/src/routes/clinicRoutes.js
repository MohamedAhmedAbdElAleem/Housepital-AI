const express = require("express");
const router = express.Router();
const { authenticateToken } = require("../middleware/authMiddleware");
const {
	addClinic,
	getMyClinics,
	updateClinic,
	deleteClinic,
	getAllClinicsPublic,
	getClinicByIdPublic,
	getPendingClinics,
	verifyClinic,
} = require("../controllers/clinicController");

// ── Public routes (no auth) ───────────────────────────────────────────────
router.get("/public", getAllClinicsPublic);
router.get("/public/:id", getClinicByIdPublic);

// ── Protected routes ──────────────────────────────────────────────────────
router.use(authenticateToken);

router.post("/", addClinic);
router.get("/my-clinics", getMyClinics);
router.get("/pending", getPendingClinics);
router.put("/:id/verify", verifyClinic);
router.put("/:id", updateClinic);
router.delete("/:id", deleteClinic);

module.exports = router;
