/**
 * Pricing Service for Housepital
 * 
 * Handles all pricing calculations for the matching system:
 * - Distance-based destination fees (Egyptian market rates)
 * - Platform commission (10%)
 * - ETA estimation
 * - Price breakdown generation
 */

// ============================================================
// PRICING CONFIGURATION (Egyptian Market)
// ============================================================
const PRICING_CONFIG = {
    // Destination fee rate per kilometer (EGP)
    // Based on Egyptian ride-hailing rates (InDriver/Careem average ~3-4 EGP/km)
    RATE_PER_KM: 3.50,

    // Minimum destination fee (EGP) — floor for very short trips
    MIN_DESTINATION_FEE: 15,

    // Maximum destination fee (EGP) — cap for very long trips
    MAX_DESTINATION_FEE: 200,

    // Platform commission percentage (admin takes this from total)
    PLATFORM_COMMISSION_RATE: 0.10, // 10%

    // Currency
    CURRENCY: "EGP",

    // Average nurse travel speed in km/h (for ETA calculation)
    // Conservative estimate for Egyptian urban traffic
    AVG_TRAVEL_SPEED_KMH: 25,

    // Minimum ETA in minutes (even for very close nurses)
    MIN_ETA_MINUTES: 5,

    // Rush hour multiplier (optional, for future use)
    RUSH_HOUR_MULTIPLIER: 1.0,
};

// ============================================================
// DISTANCE CALCULATION — Haversine Formula
// ============================================================

/**
 * Calculate the distance between two geographic points using the Haversine formula.
 * 
 * @param {number} lat1 - Latitude of point 1 (degrees)
 * @param {number} lon1 - Longitude of point 1 (degrees)
 * @param {number} lat2 - Latitude of point 2 (degrees)
 * @param {number} lon2 - Longitude of point 2 (degrees)
 * @returns {number} Distance in kilometers
 */
function calculateDistanceKm(lat1, lon1, lat2, lon2) {
    const EARTH_RADIUS_KM = 6371;

    const toRadians = (degrees) => degrees * (Math.PI / 180);

    const dLat = toRadians(lat2 - lat1);
    const dLon = toRadians(lon2 - lon1);

    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRadians(lat1)) *
        Math.cos(toRadians(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return EARTH_RADIUS_KM * c;
}

// ============================================================
// PRICING CALCULATIONS
// ============================================================

/**
 * Calculate the destination fee based on distance.
 * 
 * @param {number} distanceKm - Distance in kilometers
 * @returns {number} Destination fee in EGP (rounded to 2 decimals)
 */
function calculateDestinationFee(distanceKm) {
    let fee = distanceKm * PRICING_CONFIG.RATE_PER_KM;

    // Apply floor and cap
    fee = Math.max(fee, PRICING_CONFIG.MIN_DESTINATION_FEE);
    fee = Math.min(fee, PRICING_CONFIG.MAX_DESTINATION_FEE);

    return Math.round(fee * 100) / 100;
}

/**
 * Calculate platform commission fee.
 * 
 * @param {number} totalPrice - Total price (service + destination)
 * @returns {number} Platform fee in EGP (rounded to 2 decimals)
 */
function calculatePlatformFee(totalPrice) {
    return Math.round(totalPrice * PRICING_CONFIG.PLATFORM_COMMISSION_RATE * 100) / 100;
}

/**
 * Calculate estimated arrival time in minutes.
 * 
 * @param {number} distanceKm - Distance in kilometers
 * @returns {number} Estimated minutes (integer)
 */
function calculateETA(distanceKm) {
    const timeHours = distanceKm / PRICING_CONFIG.AVG_TRAVEL_SPEED_KMH;
    const timeMinutes = Math.ceil(timeHours * 60);

    return Math.max(timeMinutes, PRICING_CONFIG.MIN_ETA_MINUTES);
}

/**
 * Generate a complete price breakdown for a nurse-patient match.
 * 
 * @param {Object} params
 * @param {number} params.servicePrice - Fixed service price from the Service model
 * @param {number} params.nurseLatitude - Nurse's current latitude
 * @param {number} params.nurseLongitude - Nurse's current longitude
 * @param {number} params.patientLatitude - Patient's latitude
 * @param {number} params.patientLongitude - Patient's longitude
 * @returns {Object} Full price breakdown
 */
function calculatePriceBreakdown({ servicePrice, nurseLatitude, nurseLongitude, patientLatitude, patientLongitude }) {
    // Calculate distance
    const distanceKm = calculateDistanceKm(
        nurseLatitude, nurseLongitude,
        patientLatitude, patientLongitude
    );

    // Calculate fees
    const destinationFee = calculateDestinationFee(distanceKm);
    const totalPrice = Math.round((servicePrice + destinationFee) * 100) / 100;
    const platformFee = calculatePlatformFee(totalPrice);
    const nurseEarnings = Math.round((totalPrice - platformFee) * 100) / 100;

    // Calculate ETA
    const estimatedArrivalMinutes = calculateETA(distanceKm);

    return {
        servicePrice,
        distanceKm: Math.round(distanceKm * 100) / 100,
        destinationFee,
        totalPrice,
        platformFee,
        nurseEarnings,
        estimatedArrivalMinutes,
        currency: PRICING_CONFIG.CURRENCY,
        ratePerKm: PRICING_CONFIG.RATE_PER_KM,
        commissionRate: `${PRICING_CONFIG.PLATFORM_COMMISSION_RATE * 100}%`
    };
}

/**
 * Generate a price estimate for the patient before creating a matching request.
 * Uses a fixed average distance for estimation.
 * 
 * @param {number} servicePrice - Fixed service price
 * @param {number} estimatedDistanceKm - Estimated distance (optional, defaults to 5km)
 * @returns {Object} Estimated price range
 */
function getPriceEstimate(servicePrice, estimatedDistanceKm = 5) {
    const destinationFee = calculateDestinationFee(estimatedDistanceKm);
    const totalPrice = servicePrice + destinationFee;
    const platformFee = calculatePlatformFee(totalPrice);

    // Show a range: ±20%
    const minDestFee = calculateDestinationFee(Math.max(estimatedDistanceKm * 0.5, 1));
    const maxDestFee = calculateDestinationFee(estimatedDistanceKm * 1.5);

    return {
        servicePrice,
        estimatedDestinationFee: destinationFee,
        estimatedTotal: Math.round(totalPrice * 100) / 100,
        priceRange: {
            min: Math.round((servicePrice + minDestFee) * 100) / 100,
            max: Math.round((servicePrice + maxDestFee) * 100) / 100
        },
        platformFee,
        estimatedArrivalMinutes: calculateETA(estimatedDistanceKm),
        currency: PRICING_CONFIG.CURRENCY,
        note: "Final price depends on the nurse's actual distance from your location."
    };
}

module.exports = {
    PRICING_CONFIG,
    calculateDistanceKm,
    calculateDestinationFee,
    calculatePlatformFee,
    calculateETA,
    calculatePriceBreakdown,
    getPriceEstimate
};
