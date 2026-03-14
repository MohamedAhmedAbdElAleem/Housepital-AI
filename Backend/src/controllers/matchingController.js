/**
 * Matching Controller
 * 
 * REST API handlers for the nurse-patient matching system.
 * All endpoints use the matchingService and pricingService for business logic.
 */

const MatchingRequest = require("../models/MatchingRequest");
const NurseOffer = require("../models/NurseOffer");
const Service = require("../models/Service");
const User = require("../models/User");
const {
    executeMatching,
    handleNurseResponse,
    handlePatientResponse,
    getPatientOffers,
    getNursePendingOffers,
    cancelMatchingRequest
} = require("../services/matchingService");
const { getPriceEstimate } = require("../services/pricingService");

/**
 * @desc    Create a matching request (patient requests a nurse)
 * @route   POST /api/matching/request
 * @access  Private (Customer)
 */
exports.createMatchingRequest = async (req, res) => {
    try {
        const userId = req.user?.id;
        if (!userId) {
            return res.status(401).json({ success: false, message: "Not authenticated" });
        }

        const {
            serviceId,
            latitude,
            longitude,
            address,
            nurseGenderPreference,
            timeOption,
            scheduledDate,
            scheduledTime,
            notes
        } = req.body;

        // Validate required fields
        if (!serviceId || latitude == null || longitude == null) {
            return res.status(400).json({
                success: false,
                message: "Missing required fields: serviceId, latitude, longitude"
            });
        }

        // Get service details
        const service = await Service.findById(serviceId);
        if (!service) {
            return res.status(404).json({ success: false, message: "Service not found" });
        }

        if (!service.isActive) {
            return res.status(400).json({ success: false, message: "This service is not currently active" });
        }

        // Create matching request
        const matchingRequest = new MatchingRequest({
            patientId: userId,
            serviceId: service._id,
            serviceName: service.name,
            serviceCategory: service.category,
            servicePrice: service.price,
            location: {
                type: "Point",
                coordinates: [longitude, latitude] // GeoJSON uses [lon, lat]
            },
            address: address || {},
            nurseGenderPreference: nurseGenderPreference || "any",
            timeOption: timeOption || "asap",
            scheduledDate: scheduledDate ? new Date(scheduledDate) : null,
            scheduledTime: scheduledTime || null,
            notes: notes || "",
            status: "searching"
        });

        await matchingRequest.save();

        console.log(`📋 New matching request ${matchingRequest._id} from patient ${userId}`);

        // Execute matching algorithm (get io from app)
        const io = req.app.get("io");
        const result = await executeMatching(matchingRequest._id, io);

        res.status(201).json({
            success: true,
            message: result.message,
            matchingRequest: {
                id: matchingRequest._id,
                status: matchingRequest.status,
                serviceName: matchingRequest.serviceName,
                servicePrice: matchingRequest.servicePrice,
                matchedCount: result.matchedCount,
                expiresAt: matchingRequest.expiresAt
            }
        });
    } catch (error) {
        console.error("❌ Error creating matching request:", error);
        res.status(500).json({
            success: false,
            message: "Error creating matching request",
            error: error.message
        });
    }
};

/**
 * @desc    Get matching request status and info
 * @route   GET /api/matching/request/:id
 * @access  Private (Customer)
 */
exports.getMatchingRequestStatus = async (req, res) => {
    try {
        const userId = req.user?.id;
        const { id } = req.params;

        const matchingRequest = await MatchingRequest.findById(id)
            .populate("serviceId", "name category price")
            .populate("acceptedOfferId")
            .populate("bookingId");

        if (!matchingRequest) {
            return res.status(404).json({ success: false, message: "Matching request not found" });
        }

        if (matchingRequest.patientId.toString() !== userId) {
            return res.status(403).json({ success: false, message: "Not authorized" });
        }

        // Get offer counts
        const offerStats = await NurseOffer.aggregate([
            { $match: { matchingRequestId: matchingRequest._id } },
            {
                $group: {
                    _id: null,
                    total: { $sum: 1 },
                    nurseAccepted: {
                        $sum: { $cond: [{ $eq: ["$nurseStatus", "accepted"] }, 1, 0] }
                    },
                    nursePending: {
                        $sum: { $cond: [{ $eq: ["$nurseStatus", "pending"] }, 1, 0] }
                    },
                    nurseDeclined: {
                        $sum: { $cond: [{ $eq: ["$nurseStatus", "declined"] }, 1, 0] }
                    }
                }
            }
        ]);

        res.status(200).json({
            success: true,
            matchingRequest: {
                id: matchingRequest._id,
                status: matchingRequest.status,
                serviceName: matchingRequest.serviceName,
                servicePrice: matchingRequest.servicePrice,
                location: matchingRequest.address,
                nurseGenderPreference: matchingRequest.nurseGenderPreference,
                timeOption: matchingRequest.timeOption,
                searchRadiusKm: matchingRequest.searchRadiusKm,
                expiresAt: matchingRequest.expiresAt,
                createdAt: matchingRequest.createdAt,
                bookingId: matchingRequest.bookingId,
                offerStats: offerStats[0] || { total: 0, nurseAccepted: 0, nursePending: 0, nurseDeclined: 0 }
            }
        });
    } catch (error) {
        console.error("❌ Error getting matching request:", error);
        res.status(500).json({
            success: false,
            message: "Error fetching matching request",
            error: error.message
        });
    }
};

/**
 * @desc    Cancel a matching request
 * @route   PUT /api/matching/request/:id/cancel
 * @access  Private (Customer)
 */
exports.cancelRequest = async (req, res) => {
    try {
        const userId = req.user?.id;
        const { id } = req.params;
        const io = req.app.get("io");

        const result = await cancelMatchingRequest(id, userId, io);

        res.status(200).json({
            success: true,
            message: "Matching request cancelled",
            matchingRequest: {
                id: result._id,
                status: result.status
            }
        });
    } catch (error) {
        console.error("❌ Error cancelling matching request:", error);
        const statusCode = error.message.includes("Unauthorized") ? 403 :
            error.message.includes("not found") ? 404 : 400;
        res.status(statusCode).json({
            success: false,
            message: error.message
        });
    }
};

/**
 * @desc    Get pending offers for a nurse
 * @route   GET /api/matching/nurse-offers
 * @access  Private (Nurse)
 */
exports.getNurseOffers = async (req, res) => {
    try {
        const userId = req.user?.id;
        const offers = await getNursePendingOffers(userId);

        res.status(200).json({
            success: true,
            count: offers.length,
            offers
        });
    } catch (error) {
        console.error("❌ Error getting nurse offers:", error);
        res.status(500).json({
            success: false,
            message: "Error fetching nurse offers",
            error: error.message
        });
    }
};

/**
 * @desc    Nurse responds to an offer (accept/decline)
 * @route   PUT /api/matching/nurse-offers/:offerId/respond
 * @access  Private (Nurse)
 */
exports.nurseRespondToOffer = async (req, res) => {
    try {
        const userId = req.user?.id;
        const { offerId } = req.params;
        const { response } = req.body; // "accepted" or "declined"

        if (!["accepted", "declined"].includes(response)) {
            return res.status(400).json({
                success: false,
                message: "Response must be 'accepted' or 'declined'"
            });
        }

        const io = req.app.get("io");
        const offer = await handleNurseResponse(offerId, userId, response, io);

        res.status(200).json({
            success: true,
            message: `Offer ${response}`,
            offer: {
                id: offer._id,
                nurseStatus: offer.nurseStatus,
                nurseRespondedAt: offer.nurseRespondedAt
            }
        });
    } catch (error) {
        console.error("❌ Error responding to nurse offer:", error);
        const statusCode = error.message.includes("Unauthorized") ? 403 :
            error.message.includes("not found") ? 404 :
                error.message.includes("expired") ? 410 : 400;
        res.status(statusCode).json({
            success: false,
            message: error.message
        });
    }
};

/**
 * @desc    Get nurse offers visible to the patient (nurses who accepted)
 * @route   GET /api/matching/patient-offers/:requestId
 * @access  Private (Customer)
 */
exports.getPatientVisibleOffers = async (req, res) => {
    try {
        const userId = req.user?.id;
        const { requestId } = req.params;

        const offers = await getPatientOffers(requestId, userId);

        res.status(200).json({
            success: true,
            count: offers.length,
            offers
        });
    } catch (error) {
        console.error("❌ Error getting patient offers:", error);
        const statusCode = error.message.includes("Unauthorized") ? 403 :
            error.message.includes("not found") ? 404 : 500;
        res.status(statusCode).json({
            success: false,
            message: error.message
        });
    }
};

/**
 * @desc    Patient responds to a nurse offer (accept/decline)
 * @route   PUT /api/matching/patient-offers/:offerId/respond
 * @access  Private (Customer)
 */
exports.patientRespondToOffer = async (req, res) => {
    try {
        const userId = req.user?.id;
        const { offerId } = req.params;
        const { response } = req.body; // "accepted" or "declined"

        if (!["accepted", "declined"].includes(response)) {
            return res.status(400).json({
                success: false,
                message: "Response must be 'accepted' or 'declined'"
            });
        }

        const io = req.app.get("io");
        const result = await handlePatientResponse(offerId, userId, response, io);

        const responseData = {
            success: true,
            message: response === "accepted" ? "Nurse accepted! Booking created." : "Offer declined",
            offer: {
                id: result.offer._id,
                patientStatus: result.offer.patientStatus,
                patientRespondedAt: result.offer.patientRespondedAt
            }
        };

        if (result.booking) {
            responseData.booking = {
                id: result.booking._id,
                status: result.booking.status,
                assignedNurse: result.booking.assignedNurse,
                totalAmount: result.booking.totalAmount,
                visitPin: result.booking.visitPin
            };
        }

        res.status(200).json(responseData);
    } catch (error) {
        console.error("❌ Error responding to patient offer:", error);
        const statusCode = error.message.includes("Unauthorized") ? 403 :
            error.message.includes("not found") ? 404 : 400;
        res.status(statusCode).json({
            success: false,
            message: error.message
        });
    }
};

/**
 * @desc    Get a price estimate before creating a matching request
 * @route   POST /api/matching/price-estimate
 * @access  Private (Customer)
 */
exports.getEstimate = async (req, res) => {
    try {
        const { serviceId, estimatedDistanceKm } = req.body;

        if (!serviceId) {
            return res.status(400).json({
                success: false,
                message: "serviceId is required"
            });
        }

        const service = await Service.findById(serviceId);
        if (!service) {
            return res.status(404).json({ success: false, message: "Service not found" });
        }

        const estimate = getPriceEstimate(service.price, estimatedDistanceKm || 5);

        res.status(200).json({
            success: true,
            serviceName: service.name,
            serviceCategory: service.category,
            estimate
        });
    } catch (error) {
        console.error("❌ Error getting price estimate:", error);
        res.status(500).json({
            success: false,
            message: "Error calculating price estimate",
            error: error.message
        });
    }
};

/**
 * @desc    Get active matching requests for the logged-in patient
 * @route   GET /api/matching/my-requests
 * @access  Private (Customer)
 */
exports.getMyMatchingRequests = async (req, res) => {
    try {
        const userId = req.user?.id;

        const requests = await MatchingRequest.find({
            patientId: userId,
            status: { $in: ["searching", "offers_pending", "nurse_accepted"] }
        }).sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: requests.length,
            requests: requests.map(r => ({
                id: r._id,
                serviceName: r.serviceName,
                servicePrice: r.servicePrice,
                status: r.status,
                location: r.address,
                expiresAt: r.expiresAt,
                createdAt: r.createdAt
            }))
        });
    } catch (error) {
        console.error("❌ Error getting matching requests:", error);
        res.status(500).json({
            success: false,
            message: "Error fetching matching requests",
            error: error.message
        });
    }
};
