/**
 * Matching Service for Housepital
 * 
 * Core matching algorithm that connects patients with the best available nurses.
 * Uses a weighted multi-factor scoring system with geospatial pre-filtering.
 * 
 * Algorithm: Weighted Multi-Factor Scoring with Geospatial Filtering
 * ─────────────────────────────────────────────────────────────────────
 * Phase 1: Geospatial filter (MongoDB $geoNear) — find nurses within radius
 * Phase 2: Weighted scoring — rank by distance, rating, experience, etc.
 * Phase 3: Sort & limit — return top N nurses
 * Phase 4: Create offers — generate NurseOffer documents with pricing
 */

const Nurse = require("../models/Nurse");
const User = require("../models/User");
const Service = require("../models/Service");
const MatchingRequest = require("../models/MatchingRequest");
const NurseOffer = require("../models/NurseOffer");
const Booking = require("../models/Booking");
const Transaction = require("../models/Transaction");
const {
    calculatePriceBreakdown,
    calculateDistanceKm
} = require("./pricingService");

// ============================================================
// MATCHING CONFIGURATION
// ============================================================
const MATCHING_CONFIG = {
    // Default search radius in kilometers
    DEFAULT_RADIUS_KM: 15,

    // Maximum nurses to show to the patient
    MAX_NURSES_TO_MATCH: 5,

    // Nurse offer expiry time in seconds
    NURSE_OFFER_EXPIRY_SECONDS: 60,

    // Scoring weights (must sum to 1.0)
    WEIGHTS: {
        DISTANCE: 0.35,       // Closer nurses score higher
        RATING: 0.25,         // Higher-rated nurses score higher
        EXPERIENCE: 0.15,     // More experienced nurses score higher
        COMPLETION_RATE: 0.15, // Reliable nurses score higher
        RESPONSE_TIME: 0.10   // Faster-responding nurses score higher
    },

    // Normalization constants
    MAX_EXPERIENCE_YEARS: 10,   // Cap for experience normalization
    MAX_RESPONSE_TIME_SEC: 600  // 10 min cap for response time normalization
};

// ============================================================
// PHASE 1: GEOSPATIAL FILTER
// ============================================================

/**
 * Find nurses within a radius of the patient's location using MongoDB geospatial queries.
 * Filters by: online status, verification, gender preference, and service skills.
 * 
 * @param {Object} params
 * @param {number[]} params.coordinates - [longitude, latitude] of patient
 * @param {number} params.radiusKm - Search radius in km
 * @param {string} params.genderPreference - "male", "female", or "any"
 * @param {string} params.serviceCategory - Category of the requested service
 * @param {string[]} params.excludeNurseIds - Nurse IDs to exclude (already declined, etc.)
 * @returns {Promise<Array>} Array of nurse documents with distance info
 */
async function findNearbyNurses({ coordinates, radiusKm, genderPreference, serviceCategory, excludeNurseIds = [] }) {
    const radiusMeters = radiusKm * 1000;

    // Build match conditions
    const matchConditions = {
        isOnline: true,
        verificationStatus: "approved"
    };

    // Gender filter
    if (genderPreference && genderPreference !== "any") {
        matchConditions.gender = genderPreference;
    }

    // Exclude specific nurses
    if (excludeNurseIds.length > 0) {
        matchConditions._id = { $nin: excludeNurseIds };
    }

    // Use MongoDB $geoNear aggregation for distance-sorted results
    const pipeline = [
        {
            $geoNear: {
                near: {
                    type: "Point",
                    coordinates: coordinates // [longitude, latitude]
                },
                distanceField: "calculatedDistanceMeters",
                maxDistance: radiusMeters,
                spherical: true,
                query: matchConditions
            }
        },
        {
            $addFields: {
                calculatedDistanceKm: {
                    $divide: ["$calculatedDistanceMeters", 1000]
                }
            }
        }
    ];

    // If service category is provided, filter nurses with matching skills
    if (serviceCategory) {
        pipeline.push({
            $match: {
                $or: [
                    { skills: serviceCategory },
                    { skills: { $size: 0 } } // Include nurses with no specific skills listed (generalists)
                ]
            }
        });
    }

    // Populate user info
    pipeline.push(
        {
            $lookup: {
                from: "users",
                localField: "user",
                foreignField: "_id",
                as: "userInfo"
            }
        },
        {
            $unwind: "$userInfo"
        },
        {
            $match: {
                "userInfo.status": "approved"
            }
        }
    );

    const nurses = await Nurse.aggregate(pipeline);
    return nurses;
}

// ============================================================
// PHASE 2: WEIGHTED SCORING
// ============================================================

/**
 * Calculate a composite score for a nurse candidate.
 * 
 * @param {Object} nurse - Nurse document (with calculatedDistanceKm from geoNear)
 * @param {number} maxRadiusKm - Maximum search radius for distance normalization
 * @returns {number} Composite score between 0 and 1
 */
function calculateNurseScore(nurse, maxRadiusKm) {
    const W = MATCHING_CONFIG.WEIGHTS;

    // Distance score: closer = higher (1.0 at 0km, 0.0 at maxRadius)
    const distanceScore = 1 - Math.min(nurse.calculatedDistanceKm / maxRadiusKm, 1);

    // Rating score: 0-5 normalized to 0-1
    const ratingScore = (nurse.rating || 0) / 5;

    // Experience score: capped at MAX_EXPERIENCE_YEARS
    const experienceScore = Math.min(
        (nurse.yearsOfExperience || 0) / MATCHING_CONFIG.MAX_EXPERIENCE_YEARS,
        1
    );

    // Completion rate score: 0-100 normalized to 0-1
    const completionScore = (nurse.completionRate || 100) / 100;

    // Response time score: faster = higher (inverted, capped at MAX_RESPONSE_TIME_SEC)
    const responseScore = 1 - Math.min(
        (nurse.avgResponseTime || 0) / MATCHING_CONFIG.MAX_RESPONSE_TIME_SEC,
        1
    );

    // Weighted composite
    const compositeScore =
        (distanceScore * W.DISTANCE) +
        (ratingScore * W.RATING) +
        (experienceScore * W.EXPERIENCE) +
        (completionScore * W.COMPLETION_RATE) +
        (responseScore * W.RESPONSE_TIME);

    return Math.round(compositeScore * 10000) / 10000; // 4 decimal precision
}

// ============================================================
// PHASE 3: SORT & SELECT TOP N
// ============================================================

/**
 * Score and rank nurses, returning the top N.
 * 
 * @param {Array} nurses - Array of nurse documents from geospatial query
 * @param {number} maxRadiusKm - Search radius for scoring
 * @param {number} limit - Maximum number of nurses to return
 * @returns {Array} Top N nurses sorted by score (descending)
 */
function rankNurses(nurses, maxRadiusKm, limit) {
    // Score each nurse
    const scoredNurses = nurses.map(nurse => ({
        ...nurse,
        matchScore: calculateNurseScore(nurse, maxRadiusKm)
    }));

    // Sort by score descending
    scoredNurses.sort((a, b) => b.matchScore - a.matchScore);

    // Return top N
    return scoredNurses.slice(0, limit);
}

// ============================================================
// PHASE 4: CREATE OFFERS
// ============================================================

/**
 * Create NurseOffer documents for matched nurses.
 * 
 * @param {Object} matchingRequest - The matching request document
 * @param {Array} rankedNurses - Top nurses from the ranking phase
 * @returns {Promise<Array>} Created NurseOffer documents
 */
async function createNurseOffers(matchingRequest, rankedNurses) {
    const offers = [];

    for (const nurse of rankedNurses) {
        // Calculate pricing for this specific nurse-patient pair
        const nurseCoords = nurse.currentLocation?.coordinates || [0, 0];
        const patientCoords = matchingRequest.location.coordinates;

        const pricing = calculatePriceBreakdown({
            servicePrice: matchingRequest.servicePrice,
            nurseLatitude: nurseCoords[1],   // GeoJSON: [lon, lat]
            nurseLongitude: nurseCoords[0],
            patientLatitude: patientCoords[1],
            patientLongitude: patientCoords[0]
        });

        const offer = new NurseOffer({
            matchingRequestId: matchingRequest._id,
            nurseId: nurse._id,
            patientId: matchingRequest.patientId,

            // Nurse info snapshot
            nurseSnapshot: {
                name: nurse.userInfo?.name || "Nurse",
                profilePictureUrl: nurse.userInfo?.profilePictureUrl || "",
                rating: nurse.rating || 0,
                totalRatings: nurse.totalRatings || 0,
                yearsOfExperience: nurse.yearsOfExperience || 0,
                completedVisits: nurse.completedVisits || 0,
                specialization: nurse.specialization || "",
                gender: nurse.gender || ""
            },

            // Pricing
            servicePrice: pricing.servicePrice,
            distanceKm: pricing.distanceKm,
            destinationFee: pricing.destinationFee,
            totalPrice: pricing.totalPrice,
            platformFee: pricing.platformFee,
            nurseEarnings: pricing.nurseEarnings,

            // ETA
            estimatedArrivalMinutes: pricing.estimatedArrivalMinutes,

            // Score
            matchScore: nurse.matchScore,

            // Status
            nurseStatus: "pending",
            patientStatus: "not_applicable",

            // Expiry (60 seconds for nurse to respond)
            nurseExpiresAt: new Date(Date.now() + MATCHING_CONFIG.NURSE_OFFER_EXPIRY_SECONDS * 1000)
        });

        await offer.save();
        offers.push(offer);
    }

    return offers;
}

// ============================================================
// MAIN MATCHING FLOW
// ============================================================

/**
 * Execute the full matching algorithm for a patient's request.
 * 
 * @param {string} matchingRequestId - ID of the MatchingRequest document
 * @param {Object} io - Socket.io instance (optional, for real-time notifications)
 * @returns {Promise<Object>} Result with matched nurses and offers
 */
async function executeMatching(matchingRequestId, io = null) {
    const matchingRequest = await MatchingRequest.findById(matchingRequestId);

    if (!matchingRequest) {
        throw new Error("Matching request not found");
    }

    if (matchingRequest.status !== "searching") {
        throw new Error(`Cannot execute matching for request in status: ${matchingRequest.status}`);
    }

    const radiusKm = matchingRequest.searchRadiusKm || MATCHING_CONFIG.DEFAULT_RADIUS_KM;
    const maxNurses = matchingRequest.maxNurses || MATCHING_CONFIG.MAX_NURSES_TO_MATCH;

    console.log(`🔍 Starting matching for request ${matchingRequestId}`);
    console.log(`   📍 Location: [${matchingRequest.location.coordinates}]`);
    console.log(`   📏 Radius: ${radiusKm}km | Max nurses: ${maxNurses}`);

    // ── Phase 1: Find nearby nurses ──
    const nearbyNurses = await findNearbyNurses({
        coordinates: matchingRequest.location.coordinates,
        radiusKm,
        genderPreference: matchingRequest.nurseGenderPreference,
        serviceCategory: matchingRequest.serviceCategory,
        excludeNurseIds: []
    });

    console.log(`   👩‍⚕️ Found ${nearbyNurses.length} nearby nurses`);

    if (nearbyNurses.length === 0) {
        matchingRequest.status = "no_nurses_found";
        await matchingRequest.save();

        // Notify patient via Socket.io
        if (io) {
            io.to(`patient_${matchingRequest.patientId}`).emit("matching:no_nurses_found", {
                matchingRequestId: matchingRequest._id,
                message: "No nurses are currently available in your area. Please try again later."
            });
        }

        return {
            success: false,
            message: "No nurses found in your area",
            matchedCount: 0,
            offers: []
        };
    }

    // ── Phase 2 & 3: Score and rank nurses ──
    const rankedNurses = rankNurses(nearbyNurses, radiusKm, maxNurses);

    console.log(`   🏆 Top ${rankedNurses.length} nurses selected:`);
    rankedNurses.forEach((n, i) => {
        console.log(`      ${i + 1}. ${n.userInfo?.name || 'N/A'} — Score: ${n.matchScore} | Distance: ${n.calculatedDistanceKm?.toFixed(2)}km | Rating: ${n.rating}`);
    });

    // ── Phase 4: Create offers ──
    const offers = await createNurseOffers(matchingRequest, rankedNurses);

    // Update matching request
    matchingRequest.status = "offers_pending";
    matchingRequest.matchedNurses = rankedNurses.map(n => ({
        nurseId: n._id,
        score: n.matchScore,
        distanceKm: n.calculatedDistanceKm
    }));
    await matchingRequest.save();

    // ── Notify nurses via Socket.io ──
    if (io) {
        for (const offer of offers) {
            io.to(`nurse_${offer.nurseId}`).emit("matching:new_offer", {
                offerId: offer._id,
                matchingRequestId: matchingRequest._id,
                patientName: (await User.findById(matchingRequest.patientId))?.name || "Patient",
                serviceName: matchingRequest.serviceName,
                serviceCategory: matchingRequest.serviceCategory,
                location: matchingRequest.address,
                distanceKm: offer.distanceKm,
                totalPrice: offer.totalPrice,
                nurseEarnings: offer.nurseEarnings,
                estimatedArrivalMinutes: offer.estimatedArrivalMinutes,
                expiresAt: offer.nurseExpiresAt
            });
        }
    }

    console.log(`   ✅ ${offers.length} offers created and dispatched`);

    return {
        success: true,
        message: `${offers.length} nurse(s) found and notified`,
        matchedCount: offers.length,
        offers: offers.map(o => o._id)
    };
}

// ============================================================
// NURSE RESPONSE HANDLING
// ============================================================

/**
 * Handle nurse's response to an offer (accept or decline).
 * 
 * @param {string} offerId - NurseOffer ID
 * @param {string} nurseUserId - User ID of the nurse (for auth)
 * @param {string} response - "accepted" or "declined"
 * @param {Object} io - Socket.io instance (optional)
 * @returns {Promise<Object>} Updated offer
 */
async function handleNurseResponse(offerId, nurseUserId, response, io = null) {
    const offer = await NurseOffer.findById(offerId);

    if (!offer) {
        throw new Error("Offer not found");
    }

    // Verify the nurse owns this offer
    const nurse = await Nurse.findById(offer.nurseId);
    if (!nurse || nurse.user.toString() !== nurseUserId) {
        throw new Error("Unauthorized: This offer does not belong to you");
    }

    // Check if offer has expired
    if (offer.nurseStatus !== "pending") {
        throw new Error(`Cannot respond to offer in status: ${offer.nurseStatus}`);
    }

    if (new Date() > offer.nurseExpiresAt) {
        offer.nurseStatus = "expired";
        await offer.save();
        throw new Error("This offer has expired");
    }

    // Update offer
    offer.nurseStatus = response; // "accepted" or "declined"
    offer.nurseRespondedAt = new Date();

    if (response === "accepted") {
        // Make this offer visible to the patient
        offer.patientStatus = "pending";
    }

    await offer.save();

    // Update matching request status
    const matchingRequest = await MatchingRequest.findById(offer.matchingRequestId);
    if (matchingRequest && response === "accepted") {
        // Check if at least one nurse has accepted
        const acceptedOffers = await NurseOffer.find({
            matchingRequestId: matchingRequest._id,
            nurseStatus: "accepted"
        });

        if (acceptedOffers.length > 0 && matchingRequest.status === "offers_pending") {
            matchingRequest.status = "nurse_accepted";
            await matchingRequest.save();
        }

        // Notify patient about new nurse offer
        if (io) {
            io.to(`patient_${offer.patientId}`).emit("matching:nurse_offer_available", {
                matchingRequestId: matchingRequest._id,
                offerId: offer._id,
                nurseSnapshot: offer.nurseSnapshot,
                totalPrice: offer.totalPrice,
                destinationFee: offer.destinationFee,
                estimatedArrivalMinutes: offer.estimatedArrivalMinutes,
                distanceKm: offer.distanceKm
            });
        }
    }

    // Update nurse's average response time
    if (nurse && offer.createdAt) {
        const responseTimeSec = Math.round((new Date() - offer.createdAt) / 1000);
        const totalResponses = nurse.completedVisits + nurse.cancelledVisits + 1;
        nurse.avgResponseTime = Math.round(
            ((nurse.avgResponseTime || 0) * (totalResponses - 1) + responseTimeSec) / totalResponses
        );
        await nurse.save();
    }

    return offer;
}

// ============================================================
// PATIENT RESPONSE HANDLING
// ============================================================

/**
 * Handle patient's response to a nurse offer (accept or decline).
 * When patient accepts, a Booking is created.
 * 
 * @param {string} offerId - NurseOffer ID
 * @param {string} patientUserId - User ID of the patient (for auth)
 * @param {string} response - "accepted" or "declined"
 * @param {Object} io - Socket.io instance (optional)
 * @returns {Promise<Object>} Updated offer with booking info if accepted
 */
async function handlePatientResponse(offerId, patientUserId, response, io = null) {
    const offer = await NurseOffer.findById(offerId);

    if (!offer) {
        throw new Error("Offer not found");
    }

    // Verify the patient owns this offer
    if (offer.patientId.toString() !== patientUserId) {
        throw new Error("Unauthorized: This offer does not belong to you");
    }

    // Check status
    if (offer.nurseStatus !== "accepted") {
        throw new Error("This nurse has not accepted the offer yet");
    }

    if (offer.patientStatus !== "pending") {
        throw new Error(`Cannot respond to offer in status: ${offer.patientStatus}`);
    }

    // Update offer
    offer.patientStatus = response; // "accepted" or "declined"
    offer.patientRespondedAt = new Date();

    let booking = null;

    if (response === "accepted") {
        // ── Create a Booking ──
        const matchingRequest = await MatchingRequest.findById(offer.matchingRequestId);

        // Generate a 4-digit visit PIN
        const visitPin = String(Math.floor(1000 + Math.random() * 9000));

        booking = new Booking({
            type: "home_nursing",
            serviceId: matchingRequest.serviceId,
            serviceName: matchingRequest.serviceName,
            servicePrice: offer.servicePrice,
            patientId: offer.patientId,
            patientName: (await User.findById(offer.patientId))?.name || "Patient",
            userId: offer.patientId,
            timeOption: matchingRequest.timeOption,
            scheduledDate: matchingRequest.scheduledDate,
            scheduledTime: matchingRequest.scheduledTime,
            nurseGenderPreference: matchingRequest.nurseGenderPreference,
            notes: matchingRequest.notes,
            address: matchingRequest.address,
            status: "confirmed",
            assignedNurse: offer.nurseId,
            matchingAttempts: 1,
            visitPin,

            // Pricing fields
            totalAmount: offer.totalPrice,
            distanceKm: offer.distanceKm,
            destinationFee: offer.destinationFee,
            platformFee: offer.platformFee,

            // Link back
            matchingRequestId: matchingRequest._id,
            nurseOfferId: offer._id,

            paymentStatus: "pending"
        });

        await booking.save();

        // Update offer with booking reference
        offer.bookingId = booking._id;

        // Update matching request
        matchingRequest.status = "accepted";
        matchingRequest.acceptedOfferId = offer._id;
        matchingRequest.bookingId = booking._id;
        await matchingRequest.save();

        // Decline all other pending offers for this request
        await NurseOffer.updateMany(
            {
                matchingRequestId: matchingRequest._id,
                _id: { $ne: offer._id },
                nurseStatus: { $in: ["pending", "accepted"] }
            },
            {
                $set: {
                    patientStatus: "declined",
                    patientRespondedAt: new Date()
                }
            }
        );

        // Create platform fee transaction
        const platformTransaction = new Transaction({
            type: "platform_fee",
            amount: offer.platformFee,
            currency: "EGP",
            direction: "credit",
            fromUser: offer.patientId,
            bookingId: booking._id,
            status: "completed",
            description: `Platform fee for booking ${booking._id}`,
            paymentMethod: "wallet"
        });
        await platformTransaction.save();

        // Notify nurse: booking confirmed
        if (io) {
            io.to(`nurse_${offer.nurseId}`).emit("matching:booking_confirmed", {
                bookingId: booking._id,
                offerId: offer._id,
                patientName: booking.patientName,
                address: booking.address,
                visitPin,
                totalPrice: offer.totalPrice,
                nurseEarnings: offer.nurseEarnings,
                estimatedArrivalMinutes: offer.estimatedArrivalMinutes
            });
        }

        // Notify patient: booking confirmed
        if (io) {
            io.to(`patient_${offer.patientId}`).emit("matching:booking_confirmed", {
                bookingId: booking._id,
                offerId: offer._id,
                nurseSnapshot: offer.nurseSnapshot,
                totalPrice: offer.totalPrice,
                estimatedArrivalMinutes: offer.estimatedArrivalMinutes,
                visitPin
            });
        }

        // Also notify other nurses that their offers are no longer needed
        if (io) {
            const otherOffers = await NurseOffer.find({
                matchingRequestId: matchingRequest._id,
                _id: { $ne: offer._id },
                nurseStatus: "accepted"
            });
            for (const otherOffer of otherOffers) {
                io.to(`nurse_${otherOffer.nurseId}`).emit("matching:offer_cancelled", {
                    offerId: otherOffer._id,
                    reason: "Patient selected another nurse"
                });
            }
        }

        console.log(`🎉 Booking ${booking._id} created! Nurse ${offer.nurseId} → Patient ${offer.patientId}`);
    }

    await offer.save();

    return {
        offer,
        booking
    };
}

// ============================================================
// GET PATIENT OFFERS (what the patient sees)
// ============================================================

/**
 * Get all nurse offers that are visible to the patient for a matching request.
 * The patient sees: name, picture, rating, years of experience, completed visits, price, ETA.
 * 
 * @param {string} matchingRequestId - MatchingRequest ID
 * @param {string} patientUserId - User ID of the patient (for auth)
 * @returns {Promise<Array>} Array of offers formatted for patient view
 */
async function getPatientOffers(matchingRequestId, patientUserId) {
    const matchingRequest = await MatchingRequest.findById(matchingRequestId);

    if (!matchingRequest) {
        throw new Error("Matching request not found");
    }

    if (matchingRequest.patientId.toString() !== patientUserId) {
        throw new Error("Unauthorized: This request does not belong to you");
    }

    // Get offers where nurse has accepted (visible to patient)
    const offers = await NurseOffer.find({
        matchingRequestId,
        nurseStatus: "accepted",
        patientStatus: { $in: ["pending", "accepted"] }
    }).sort({ matchScore: -1 });

    // Format for patient view
    return offers.map(offer => ({
        offerId: offer._id,
        nurse: {
            name: offer.nurseSnapshot.name,
            profilePictureUrl: offer.nurseSnapshot.profilePictureUrl,
            rating: offer.nurseSnapshot.rating,
            totalRatings: offer.nurseSnapshot.totalRatings,
            yearsOfExperience: offer.nurseSnapshot.yearsOfExperience,
            completedVisits: offer.nurseSnapshot.completedVisits,
            specialization: offer.nurseSnapshot.specialization,
            gender: offer.nurseSnapshot.gender
        },
        pricing: {
            servicePrice: offer.servicePrice,
            destinationFee: offer.destinationFee,
            totalPrice: offer.totalPrice,
            currency: offer.currency
        },
        distanceKm: offer.distanceKm,
        estimatedArrivalMinutes: offer.estimatedArrivalMinutes,
        patientStatus: offer.patientStatus,
        matchScore: offer.matchScore,
        createdAt: offer.createdAt
    }));
}

// ============================================================
// GET NURSE PENDING OFFERS
// ============================================================

/**
 * Get all pending offers for a nurse.
 * The nurse sees: patient info, service details, price, distance.
 * 
 * @param {string} nurseUserId - User ID of the nurse
 * @returns {Promise<Array>} Array of pending offers for the nurse
 */
async function getNursePendingOffers(nurseUserId) {
    // Find the nurse profile
    const nurse = await Nurse.findOne({ user: nurseUserId });
    if (!nurse) {
        throw new Error("Nurse profile not found");
    }

    // Get pending offers
    const offers = await NurseOffer.find({
        nurseId: nurse._id,
        nurseStatus: "pending",
        nurseExpiresAt: { $gt: new Date() }
    })
        .populate({
            path: "matchingRequestId",
            select: "serviceName serviceCategory address location notes timeOption"
        })
        .sort({ createdAt: -1 });

    // Get patient ratings for each offer
    const formattedOffers = [];
    for (const offer of offers) {
        const patient = await User.findById(offer.patientId).select("name profilePictureUrl");

        // Get patient's average rating (from nurse perspective)
        const Rating = require("../models/Rating");
        const patientRating = await Rating.calculateAverageRating(offer.patientId);

        formattedOffers.push({
            offerId: offer._id,
            patient: {
                name: patient?.name || "Patient",
                profilePictureUrl: patient?.profilePictureUrl || "",
                rating: patientRating.avgRating,
                totalRatings: patientRating.totalRatings
            },
            service: {
                name: offer.matchingRequestId?.serviceName || "",
                category: offer.matchingRequestId?.serviceCategory || "",
            },
            location: offer.matchingRequestId?.address || {},
            pricing: {
                totalPrice: offer.totalPrice,
                nurseEarnings: offer.nurseEarnings,
                destinationFee: offer.destinationFee,
                servicePrice: offer.servicePrice,
                currency: offer.currency
            },
            distanceKm: offer.distanceKm,
            estimatedArrivalMinutes: offer.estimatedArrivalMinutes,
            notes: offer.matchingRequestId?.notes || "",
            timeOption: offer.matchingRequestId?.timeOption || "asap",
            expiresAt: offer.nurseExpiresAt,
            createdAt: offer.createdAt
        });
    }

    return formattedOffers;
}

// ============================================================
// CANCEL MATCHING REQUEST
// ============================================================

/**
 * Cancel a matching request and all associated offers.
 * 
 * @param {string} matchingRequestId - MatchingRequest ID
 * @param {string} patientUserId - User ID of the patient (for auth)
 * @param {Object} io - Socket.io instance
 * @returns {Promise<Object>} Cancelled request
 */
async function cancelMatchingRequest(matchingRequestId, patientUserId, io = null) {
    const matchingRequest = await MatchingRequest.findById(matchingRequestId);

    if (!matchingRequest) {
        throw new Error("Matching request not found");
    }

    if (matchingRequest.patientId.toString() !== patientUserId) {
        throw new Error("Unauthorized");
    }

    if (["accepted", "cancelled", "expired"].includes(matchingRequest.status)) {
        throw new Error(`Cannot cancel request in status: ${matchingRequest.status}`);
    }

    // Cancel all pending/accepted offers
    const offers = await NurseOffer.find({
        matchingRequestId,
        nurseStatus: { $in: ["pending", "accepted"] }
    });

    await NurseOffer.updateMany(
        {
            matchingRequestId,
            nurseStatus: { $in: ["pending", "accepted"] }
        },
        {
            $set: { nurseStatus: "expired", patientStatus: "declined" }
        }
    );

    // Notify nurses
    if (io) {
        for (const offer of offers) {
            io.to(`nurse_${offer.nurseId}`).emit("matching:offer_cancelled", {
                offerId: offer._id,
                reason: "Patient cancelled the request"
            });
        }
    }

    matchingRequest.status = "cancelled";
    await matchingRequest.save();

    return matchingRequest;
}

module.exports = {
    MATCHING_CONFIG,
    findNearbyNurses,
    calculateNurseScore,
    rankNurses,
    createNurseOffers,
    executeMatching,
    handleNurseResponse,
    handlePatientResponse,
    getPatientOffers,
    getNursePendingOffers,
    cancelMatchingRequest
};
