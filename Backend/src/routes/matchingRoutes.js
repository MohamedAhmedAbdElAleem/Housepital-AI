/**
 * Matching Routes
 * 
 * API routes for the nurse-patient matching system.
 * All routes require JWT authentication.
 */

const express = require("express");
const router = express.Router();
const { authenticateToken, authorizeRole } = require("../middleware/authMiddleware");
const {
    createMatchingRequest,
    getMatchingRequestStatus,
    cancelRequest,
    getNurseOffers,
    nurseRespondToOffer,
    getPatientVisibleOffers,
    patientRespondToOffer,
    getEstimate,
    getMyMatchingRequests
} = require("../controllers/matchingController");

// ============================================================
// PATIENT (Customer) ENDPOINTS
// ============================================================

/**
 * @openapi
 * /api/matching/request:
 *   post:
 *     tags:
 *       - Matching
 *     summary: Create a matching request (find nurses)
 *     description: |
 *       Patient creates a request for a nursing service at their location.
 *       The system runs the matching algorithm and sends offers to nearby nurses.
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - serviceId
 *               - latitude
 *               - longitude
 *             properties:
 *               serviceId:
 *                 type: string
 *                 description: MongoDB ID of the service
 *               latitude:
 *                 type: number
 *                 description: Patient's latitude
 *                 example: 30.0444
 *               longitude:
 *                 type: number
 *                 description: Patient's longitude
 *                 example: 31.2357
 *               address:
 *                 type: object
 *                 properties:
 *                   street:
 *                     type: string
 *                   area:
 *                     type: string
 *                   city:
 *                     type: string
 *                   state:
 *                     type: string
 *               nurseGenderPreference:
 *                 type: string
 *                 enum: [male, female, any]
 *                 default: any
 *               timeOption:
 *                 type: string
 *                 enum: [asap, schedule]
 *                 default: asap
 *               scheduledDate:
 *                 type: string
 *                 format: date-time
 *               scheduledTime:
 *                 type: string
 *               notes:
 *                 type: string
 *     responses:
 *       201:
 *         description: Matching request created, algorithm executed
 *       400:
 *         description: Missing required fields
 *       404:
 *         description: Service not found
 */
router.post("/request", authenticateToken, authorizeRole("customer"), createMatchingRequest);

/**
 * @openapi
 * /api/matching/my-requests:
 *   get:
 *     tags:
 *       - Matching
 *     summary: Get my active matching requests
 *     description: Returns all active (non-completed) matching requests for the logged-in patient.
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of active matching requests
 */
router.get("/my-requests", authenticateToken, authorizeRole("customer"), getMyMatchingRequests);

/**
 * @openapi
 * /api/matching/request/{id}:
 *   get:
 *     tags:
 *       - Matching
 *     summary: Get matching request status
 *     description: Get the current status, offer stats, and details of a matching request.
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Matching request ID
 *     responses:
 *       200:
 *         description: Matching request details and offer statistics
 *       404:
 *         description: Request not found
 */
router.get("/request/:id", authenticateToken, authorizeRole("customer"), getMatchingRequestStatus);

/**
 * @openapi
 * /api/matching/request/{id}/cancel:
 *   put:
 *     tags:
 *       - Matching
 *     summary: Cancel a matching request
 *     description: Cancels the matching request and all associated nurse offers.
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Matching request cancelled
 *       400:
 *         description: Cannot cancel (already accepted/expired)
 */
router.put("/request/:id/cancel", authenticateToken, authorizeRole("customer"), cancelRequest);

/**
 * @openapi
 * /api/matching/patient-offers/{requestId}:
 *   get:
 *     tags:
 *       - Matching
 *     summary: Get nurse offers visible to patient
 *     description: |
 *       Returns all nurse offers where the nurse has accepted the request.
 *       The patient can see: name, picture, rating, experience, completed visits, price, ETA.
 *       Up to 5 nurses max.
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: requestId
 *         required: true
 *         schema:
 *           type: string
 *         description: Matching request ID
 *     responses:
 *       200:
 *         description: List of nurse offers with nurse details and pricing
 */
router.get("/patient-offers/:requestId", authenticateToken, authorizeRole("customer"), getPatientVisibleOffers);

/**
 * @openapi
 * /api/matching/patient-offers/{offerId}/respond:
 *   put:
 *     tags:
 *       - Matching
 *     summary: Patient accepts or declines a nurse offer
 *     description: |
 *       When patient accepts, a Booking is created, the visit PIN is generated,
 *       and all other offers are automatically declined.
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: offerId
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
 *               - response
 *             properties:
 *               response:
 *                 type: string
 *                 enum: [accepted, declined]
 *     responses:
 *       200:
 *         description: Offer responded to. If accepted, includes booking info.
 */
router.put("/patient-offers/:offerId/respond", authenticateToken, authorizeRole("customer"), patientRespondToOffer);

/**
 * @openapi
 * /api/matching/price-estimate:
 *   post:
 *     tags:
 *       - Matching
 *     summary: Get price estimate before requesting
 *     description: Returns an estimated price range for a service based on estimated distance.
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - serviceId
 *             properties:
 *               serviceId:
 *                 type: string
 *               estimatedDistanceKm:
 *                 type: number
 *                 default: 5
 *     responses:
 *       200:
 *         description: Price estimate with range
 */
router.post("/price-estimate", authenticateToken, getEstimate);

// ============================================================
// NURSE ENDPOINTS
// ============================================================

/**
 * @openapi
 * /api/matching/nurse-offers:
 *   get:
 *     tags:
 *       - Matching
 *     summary: Get pending offers for the logged-in nurse
 *     description: |
 *       Returns all pending offers that the nurse hasn't responded to yet.
 *       Each offer includes patient info, rating, service details, pricing, and ETA.
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of pending offers with patient details and pricing
 */
router.get("/nurse-offers", authenticateToken, authorizeRole("nurse"), getNurseOffers);

/**
 * @openapi
 * /api/matching/nurse-offers/{offerId}/respond:
 *   put:
 *     tags:
 *       - Matching
 *     summary: Nurse accepts or declines an offer
 *     description: |
 *       Nurse responds to a pending offer. If accepted, the offer becomes
 *       visible to the patient who can then accept or decline.
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: offerId
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
 *               - response
 *             properties:
 *               response:
 *                 type: string
 *                 enum: [accepted, declined]
 *     responses:
 *       200:
 *         description: Offer responded to
 *       410:
 *         description: Offer expired
 */
router.put("/nurse-offers/:offerId/respond", authenticateToken, authorizeRole("nurse"), nurseRespondToOffer);

module.exports = router;
