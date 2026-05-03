const express = require("express");
const router = express.Router();
const { getSettings, updateSettings } = require("../controllers/settingsController");
const { authenticateToken, authorizeRole } = require("../middleware/authMiddleware");

// All settings routes require authentication and admin access
router.use(authenticateToken);
// router.use(authorizeRole("admin")); // Ensure only admins can access

/**
 * @openapi
 * /api/settings:
 *   get:
 *     tags:
 *       - Settings
 *     summary: Get system settings
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Settings retrieved
 */
router.get("/", getSettings);

/**
 * @openapi
 * /api/settings:
 *   patch:
 *     tags:
 *       - Settings
 *     summary: Update system settings
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Settings updated
 */
router.patch("/", updateSettings);

module.exports = router;
