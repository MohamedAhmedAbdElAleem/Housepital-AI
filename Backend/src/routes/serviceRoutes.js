const express = require("express");
const router = express.Router();
const { authenticateToken } = require("../middleware/authMiddleware");
const {
	getServicesByClinic,
	getMyServices,
	createService,
	updateService,
	deleteService,
} = require("../controllers/serviceController");

// ── Public routes (no auth) ───────────────────────────────────────────────
router.get("/public/by-clinic/:clinicId", getServicesByClinic);

// ── Protected routes ──────────────────────────────────────────────────────
router.use(authenticateToken);

router.get("/my-services", getMyServices);
router.post("/", createService);
router.put("/:id", updateService);
router.delete("/:id", deleteService);

module.exports = router;
