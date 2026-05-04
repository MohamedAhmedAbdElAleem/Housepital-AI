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

const configuredOfferExpirySeconds = Number(process.env.MATCHING_NURSE_OFFER_EXPIRY_SECONDS);

// ============================================================
// MATCHING CONFIGURATION
// ============================================================
const MATCHING_CONFIG = {
    // Default search radius in kilometers
    DEFAULT_RADIUS_KM: 15,

    // Search expansion fallback when no nearby nurses are found.
    // This keeps the system usable in low-supply environments.
    ENABLE_RADIUS_EXPANSION:
        String(process.env.MATCHING_ENABLE_RADIUS_EXPANSION || "true").toLowerCase() !== "false",
    RADIUS_EXPANSION_STEPS_KM: [30, 50, 75, 100],
    MAX_SEARCH_RADIUS_KM: 100,

    // Maximum nurses to show to the patient
    MAX_NURSES_TO_MATCH: 5,

    // Nurse offer expiry time in seconds
    NURSE_OFFER_EXPIRY_SECONDS:
        Number.isFinite(configuredOfferExpirySeconds) && configuredOfferExpirySeconds > 0
            ? configuredOfferExpirySeconds
            : 600,

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

function normalizeRadiusKm(value, fallback) {
    const parsed = Number(value);
    if (!Number.isFinite(parsed) || parsed <= 0) return fallback;
    return parsed;
}

function buildRadiusSearchSteps(baseRadiusKm) {
    const normalizedBase = normalizeRadiusKm(baseRadiusKm, MATCHING_CONFIG.DEFAULT_RADIUS_KM);
    const maxRadius = normalizeRadiusKm(
        MATCHING_CONFIG.MAX_SEARCH_RADIUS_KM,
        MATCHING_CONFIG.MAX_SEARCH_RADIUS_KM
    );

    if (!MATCHING_CONFIG.ENABLE_RADIUS_EXPANSION) {
        return [Math.min(normalizedBase, maxRadius)];
    }

    const configuredSteps = Array.isArray(MATCHING_CONFIG.RADIUS_EXPANSION_STEPS_KM)
        ? MATCHING_CONFIG.RADIUS_EXPANSION_STEPS_KM
        : [];

    const steps = [normalizedBase, ...configuredSteps, maxRadius]
        .map((step) => normalizeRadiusKm(step, normalizedBase))
        .filter((step) => step >= normalizedBase && step <= maxRadius)
        .sort((a, b) => a - b);

    return [...new Set(steps)];
}

function mergeNurseCandidates(candidates) {
    const byId = new Map();

    for (const candidate of candidates) {
        const id = String(candidate?._id || "");
        if (!id) continue;

        const existing = byId.get(id);
        if (!existing) {
            byId.set(id, candidate);
            continue;
        }

        if ((candidate.calculatedDistanceMeters || Infinity) < (existing.calculatedDistanceMeters || Infinity)) {
            byId.set(id, candidate);
        }
    }

    return Array.from(byId.values()).sort(
        (a, b) => (a.calculatedDistanceMeters || Infinity) - (b.calculatedDistanceMeters || Infinity)
    );
}

async function runGeoSearch({
    coordinates,
    radiusKm,
    locationKey,
    locationLabel,
    locationCoordinatesField,
    matchConditions,
    serviceCategory
}) {
    const pipeline = [
        {
            $geoNear: {
                near: {
                    type: "Point",
                    coordinates
                },
                key: locationKey,
                distanceField: "calculatedDistanceMeters",
                maxDistance: radiusKm * 1000,
                spherical: true,
                query: matchConditions
            }
        },
        {
            $addFields: {
                calculatedDistanceKm: {
                    $divide: ["$calculatedDistanceMeters", 1000]
                },
                matchedLocationSource: locationLabel,
                matchedLocationCoordinates: locationCoordinatesField
            }
        }
    ];

    if (serviceCategory) {
        pipeline.push({
            $match: {
                $or: [
                    { skills: serviceCategory },
                    {
                        $expr: {
                            $eq: [
                                {
                                    $size: {
                                        $ifNull: ["$skills", []]
                                    }
                                },
                                0
                            ]
                        }
                    }
                ]
            }
        });
    }

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

    return Nurse.aggregate(pipeline);
}

/**
 * Emit a socket event to a nurse using both room strategies:
 * - nurse_{nurseProfileId} for backward compatibility
 * - nurse_{nurseUserId} for authenticated socket rooms
 */
async function emitToNurse(io, nurseProfileId, eventName, payload, nurseUserId = null) {
    if (!io || !nurseProfileId) return;

    io.to(`nurse_${nurseProfileId}`).emit(eventName, payload);

    let resolvedNurseUserId = nurseUserId;
    if (!resolvedNurseUserId) {
        const nurse = await Nurse.findById(nurseProfileId).select("user");
        resolvedNurseUserId = nurse?.user ? String(nurse.user) : null;
    }

    if (resolvedNurseUserId) {
        io.to(`nurse_${resolvedNurseUserId}`).emit(eventName, payload);
    }
}

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

    const radiusSteps = buildRadiusSearchSteps(radiusKm);
    const searchStrategies = [
        {
            locationKey: "currentLocation",
            locationLabel: "currentLocation",
            locationCoordinatesField: "$currentLocation.coordinates",
            extraMatch: {} // no extra filter needed
        },
        {
            locationKey: "workZone.center",
            locationLabel: "workZone.center",
            locationCoordinatesField: "$workZone.center.coordinates",
            // Skip nurses whose workZone is still default [0,0]
            extraMatch: {
                "workZone.center.coordinates": { $ne: [0, 0] }
            }
        }
    ];

    let lastMergedCount = 0;

    for (const stepRadiusKm of radiusSteps) {
        const resultsPerStrategy = await Promise.all(
            searchStrategies.map((strategy) =>
                runGeoSearch({
                    coordinates,
                    radiusKm: stepRadiusKm,
                    locationKey: strategy.locationKey,
                    locationLabel: strategy.locationLabel,
                    locationCoordinatesField: strategy.locationCoordinatesField,
                    matchConditions: { ...matchConditions, ...(strategy.extraMatch || {}) },
                    serviceCategory
                })
            )
        );

        const merged = mergeNurseCandidates(resultsPerStrategy.flat());
        lastMergedCount = merged.length;

        if (merged.length > 0) {
            if (stepRadiusKm > radiusKm) {
                console.log(
                    `   ⚠️ No nurses within ${radiusKm}km. Expanded search to ${stepRadiusKm}km and found ${merged.length}.`
                );
            }
            return merged;
        }
    }

    if (lastMergedCount === 0) {
        console.log(`   ⚠️ No eligible nurses found after expansion up to ${radiusSteps[radiusSteps.length - 1]}km.`);
    }

    return [];
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

    const now = Date.now();
    const expiryFromConfig = new Date(now + MATCHING_CONFIG.NURSE_OFFER_EXPIRY_SECONDS * 1000);
    const requestExpiry = matchingRequest.expiresAt ? new Date(matchingRequest.expiresAt) : null;
    const offerExpiry =
        requestExpiry && requestExpiry.getTime() > now && requestExpiry < expiryFromConfig
            ? requestExpiry
            : expiryFromConfig;

    for (const nurse of rankedNurses) {
        // Calculate pricing for this specific nurse-patient pair
        const nurseCoords =
            (Array.isArray(nurse.matchedLocationCoordinates) && nurse.matchedLocationCoordinates.length >= 2)
                ? nurse.matchedLocationCoordinates
                : (nurse.currentLocation?.coordinates || nurse.workZone?.center?.coordinates || [0, 0]);
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

            // Keep offer alive for the configured window (capped by request expiry).
            nurseExpiresAt: new Date(offerExpiry)
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
        console.log(`   ⏳ No nurses online currently. Request ${matchingRequest._id} will stay in searching state.`);

        // We do NOT set status to "no_nurses_found" here anymore.
        // We let the frontend wait for the 10-minute expiry window.

        return {
            success: true,
            message: "Searching for nurses in your area...",
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
        const patientName = (await User.findById(matchingRequest.patientId).select("name"))?.name || "Patient";
        const nurseUserByProfileId = new Map(
            rankedNurses.map((nurse) => [String(nurse._id), nurse.user ? String(nurse.user) : null])
        );

        for (const offer of offers) {
            await emitToNurse(
                io,
                offer.nurseId,
                "matching:new_offer",
                {
                    offerId: offer._id,
                    matchingRequestId: matchingRequest._id,
                    patientName,
                    serviceName: matchingRequest.serviceName,
                    serviceCategory: matchingRequest.serviceCategory,
                    location: matchingRequest.address,
                    distanceKm: offer.distanceKm,
                    totalPrice: offer.totalPrice,
                    nurseEarnings: offer.nurseEarnings,
                    estimatedArrivalMinutes: offer.estimatedArrivalMinutes,
                    expiresAt: offer.nurseExpiresAt
                },
                nurseUserByProfileId.get(String(offer.nurseId))
            );
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

    // Update matching request status
    const matchingRequest = await MatchingRequest.findById(offer.matchingRequestId);

    if (response === "accepted" && matchingRequest?.expiresAt) {
        const requestExpiry = new Date(matchingRequest.expiresAt);
        if (requestExpiry > new Date()) {
            offer.nurseExpiresAt = requestExpiry;
        }
    }

    await offer.save();

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
            address: {
                ...(matchingRequest.address || {}),
                coordinates: matchingRequest.location, // GeoJSON {type:"Point", coordinates:[lon,lat]}
            },
            // Patient selected a nurse, so this booking is now assigned to that nurse.
            status: "assigned",
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

        // Request finished successfully - delete it and the offer! 
        // As requested by user, we do not hold matching transients in DB after conversion.
        await MatchingRequest.findByIdAndDelete(matchingRequest._id);
        await NurseOffer.findByIdAndDelete(offer._id);

        const otherOffers = await NurseOffer.find({
            matchingRequestId: matchingRequest._id,
            _id: { $ne: offer._id },
            nurseStatus: { $in: ["pending", "accepted"] }
        }).select("_id nurseId");

        // Delete all other extraneous offers (cleaning house)
        await NurseOffer.deleteMany({
            matchingRequestId: matchingRequest._id,
            _id: { $ne: offer._id }
        });

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
            await emitToNurse(io, offer.nurseId, "matching:booking_confirmed", {
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
            for (const otherOffer of otherOffers) {
                await emitToNurse(io, otherOffer.nurseId, "matching:offer_cancelled", {
                    offerId: otherOffer._id,
                    reason: "Patient selected another nurse"
                });
            }
        }

        console.log(`🎉 Booking ${booking._id} created! MatchingRequest removed securely.`);
    } else {
        // If declined, just save the offer state
        await offer.save();
    }

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

    // Get offers that need nurse attention or are waiting for patient confirmation.
    const offers = await NurseOffer.find({
        nurseId: nurse._id,
        nurseExpiresAt: { $gt: new Date() },
        $or: [
            { nurseStatus: "pending" },
            { nurseStatus: "accepted", patientStatus: "pending" }
        ]
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
            nurseStatus: offer.nurseStatus,
            patientStatus: offer.patientStatus,
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

    // Explicitly delete offers associated with this request
    await NurseOffer.deleteMany({ matchingRequestId });

    // Notify nurses
    if (io) {
        for (const offer of offers) {
            await emitToNurse(io, offer.nurseId, "matching:offer_cancelled", {
                offerId: offer._id,
                reason: "Patient cancelled the request"
            });
        }
    }

    // Delete matching request since it's cancelled
    await MatchingRequest.findByIdAndDelete(matchingRequestId);

    return matchingRequest;
}

/**
 * Expire a matching request if its search window has elapsed.
 * Also expires any remaining pending/accepted offers tied to that request.
 *
 * @param {Object} matchingRequest - MatchingRequest mongoose document
 * @param {Object} io - Socket.io instance (optional)
 * @returns {Promise<Object>} Updated matching request
 */
async function expireMatchingRequestIfNeeded(matchingRequest, io = null) {
    if (!matchingRequest) return matchingRequest;

    const activeStatuses = ["searching", "offers_pending", "nurse_accepted"];
    const isActive = activeStatuses.includes(matchingRequest.status);
    const isTimedOut = matchingRequest.expiresAt && new Date() > matchingRequest.expiresAt;

    if (!isActive || !isTimedOut) {
        return matchingRequest;
    }

    const offers = await NurseOffer.find({
        matchingRequestId: matchingRequest._id,
        nurseStatus: { $in: ["pending", "accepted"] }
    });

    await NurseOffer.deleteMany({
        matchingRequestId: matchingRequest._id
    });

    if (io) {
        for (const offer of offers) {
            await emitToNurse(io, offer.nurseId, "matching:offer_cancelled", {
                offerId: offer._id,
                reason: "Request expired"
            });
        }

        io.to(`patient_${matchingRequest.patientId}`).emit("matching:request_expired", {
            matchingRequestId: matchingRequest._id,
            message: "Your matching request expired before confirmation."
        });
    }

    await MatchingRequest.findByIdAndDelete(matchingRequest._id);

    return null;
}

/**
 * Find all matching requests in the "searching" state and re-execute matching.
 * This is useful when a nurse comes online or updates their location.
 *
 * @param {Object} io - Socket.io instance
 */
async function recheckSearchingRequests(io) {
    try {
        const searchingRequests = await MatchingRequest.find({ status: "searching" });
        if (searchingRequests.length > 0) {
            console.log(`🔄 Rechecking ${searchingRequests.length} searching requests due to nurse status/location update.`);
            for (const req of searchingRequests) {
                await executeMatching(req._id, io);
            }
        }
    } catch (error) {
        console.error("Error rechecking searching requests:", error);
    }
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
    cancelMatchingRequest,
    expireMatchingRequestIfNeeded,
    recheckSearchingRequests
};
