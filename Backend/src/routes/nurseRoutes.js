const express = require('express');
const router = express.Router();
const {
    getNurseProfile,
    updateNurseProfile,
    submitProfileForReview,
    getProfileStatus,
    getPendingNurses,
    verifyNurse
} = require('../controllers/nurseController');
const { authenticateToken } = require('../middleware/authMiddleware');

/**
 * @openapi
 * /api/nurse/profile:
 *   get:
 *     tags:
 *       - Nurse
 *     summary: Get nurse profile
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Nurse profile retrieved successfully
 *       404:
 *         description: Profile not found
 */
router.get('/profile', authenticateToken, getNurseProfile);

/**
 * @openapi
 * /api/nurse/profile:
 *   post:
 *     tags:
 *       - Nurse
 *     summary: Create or update nurse profile
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               licenseNumber:
 *                 type: string
 *               specialization:
 *                 type: string
 *               yearsOfExperience:
 *                 type: number
 *               skills:
 *                 type: array
 *                 items:
 *                   type: string
 *               bio:
 *                 type: string
 *               gender:
 *                 type: string
 *                 enum: [male, female]
 *               nationalIdUrl:
 *                 type: string
 *               degreeUrl:
 *                 type: string
 *               licenseUrl:
 *                 type: string
 *               bankAccount:
 *                 type: object
 *               eWallet:
 *                 type: object
 *     responses:
 *       200:
 *         description: Profile updated successfully
 */
router.post('/profile', authenticateToken, updateNurseProfile);

/**
 * @openapi
 * /api/nurse/profile/submit:
 *   post:
 *     tags:
 *       - Nurse
 *     summary: Submit profile for admin review
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile submitted successfully
 *       400:
 *         description: Profile incomplete
 */
router.post('/profile/submit', authenticateToken, submitProfileForReview);

/**
 * @openapi
 * /api/nurse/profile/status:
 *   get:
 *     tags:
 *       - Nurse
 *     summary: Get profile completion status
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile status retrieved
 */
router.get('/profile/status', authenticateToken, getProfileStatus);

/**
 * @openapi
 * /api/nurse/pending:
 *   get:
 *     tags:
 *       - Nurse
 *     summary: Get all pending nurses for admin review
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Pending nurses list
 */
router.get('/pending', authenticateToken, getPendingNurses);

/**
 * @openapi
 * /api/nurse/{nurseId}/verify:
 *   put:
 *     tags:
 *       - Nurse
 *     summary: Approve or reject a nurse (admin only)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: nurseId
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
 *               action:
 *                 type: string
 *                 enum: [approve, reject]
 *               rejectionReason:
 *                 type: string
 *     responses:
 *       200:
 *         description: Nurse verification updated
 */
router.put('/:nurseId/verify', authenticateToken, verifyNurse);

module.exports = router;

