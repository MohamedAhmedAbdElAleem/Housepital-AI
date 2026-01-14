const express = require("express");
const router = express.Router();
const { authenticateToken, authorizeRole } = require("../middleware/authMiddleware");
const {
    addService,
    getMyServices,
    updateService,
    deleteService,
    getPublicServices
} = require("../controllers/serviceController");

// PUBLIC route (no auth needed)
router.get("/public", getPublicServices);

// Protected routes
router.use(authenticateToken);
router.use(authorizeRole("doctor")); // Only doctors for now

router.route("/")
    .post(addService);

router.route("/my-services")
    .get(getMyServices);

router.route("/:id")
    .put(updateService)
    .delete(deleteService);

module.exports = router;
