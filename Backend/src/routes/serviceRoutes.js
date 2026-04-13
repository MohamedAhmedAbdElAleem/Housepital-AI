const express = require("express");
const router = express.Router();
const { authenticateToken, authorizeRole } = require("../middleware/authMiddleware");
const {
	getPublicHomeNursingServices,
	getAdminHomeNursingServices,
	getHomeNursingProviders,
	createAdminHomeNursingService,
	updateAdminHomeNursingService,
	archiveAdminHomeNursingService,
	getServicesByClinic,
	getMyServices,
	createService,
	updateService,
	deleteService,
} = require("../controllers/serviceController");

// ── Public routes (no auth) ───────────────────────────────────────────────
router.get("/public/home-nursing", getPublicHomeNursingServices);
router.get("/public/by-clinic/:clinicId", getServicesByClinic);

// ── Protected routes ──────────────────────────────────────────────────────
router.use(authenticateToken);

// ── Admin service catalog management ──────────────────────────────────────
router.get("/admin/home-nursing", authorizeRole("admin"), getAdminHomeNursingServices);
router.get(
	"/admin/home-nursing/providers",
	authorizeRole("admin"),
	getHomeNursingProviders
);
router.post(
	"/admin/home-nursing",
	authorizeRole("admin"),
	createAdminHomeNursingService
);
router.put(
	"/admin/home-nursing/:id",
	authorizeRole("admin"),
	updateAdminHomeNursingService
);
router.delete(
	"/admin/home-nursing/:id",
	authorizeRole("admin"),
	archiveAdminHomeNursingService
);

router.get("/my-services", getMyServices);
router.post("/", createService);
router.put("/:id", updateService);
router.delete("/:id", deleteService);

module.exports = router;
