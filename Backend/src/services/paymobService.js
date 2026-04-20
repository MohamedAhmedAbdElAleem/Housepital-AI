/**
 * PayMob Payment Gateway Integration Service
 *
 * Supports TWO payment methods:
 * 1. Card (Visa/Mastercard) — via iframe
 * 2. Mobile Wallet (Vodafone Cash, Etisalat Cash, etc.) — via wallet API
 *
 * Flow:
 * ┌─────────────┐   ┌──────────────┐   ┌───────────────┐
 * │ Authenticate │──▶│ Create Order  │──▶│ Payment Key   │
 * └─────────────┘   └──────────────┘   └───────┬───────┘
 *                                               │
 *                                    ┌──────────┴──────────┐
 *                                    │                     │
 *                              ┌─────▼─────┐       ┌──────▼──────┐
 *                              │ Card Flow  │       │ Wallet Flow │
 *                              │ (Iframe)   │       │ (API Call)  │
 *                              └───────────┘       └─────────────┘
 *
 * Docs: https://docs.paymob.com/docs/accept-standard-redirect
 */

const axios = require("axios");
const crypto = require("crypto");

// ============================================================
// CONFIGURATION
// ============================================================
const PAYMOB_BASE_URL = "https://accept.paymob.com/api";
const PAYMOB_API_KEY = process.env.PAYMOB_API_KEY;
const PAYMOB_CARD_INTEGRATION_ID = process.env.PAYMOB_CARD_INTEGRATION_ID;
const PAYMOB_WALLET_INTEGRATION_ID = process.env.PAYMOB_WALLET_INTEGRATION_ID;
const PAYMOB_IFRAME_ID = process.env.PAYMOB_IFRAME_ID;
const PAYMOB_HMAC_SECRET = process.env.PAYMOB_HMAC_SECRET;

// Payment method constants
const PAYMENT_METHODS = {
	CARD: "card",
	WALLET: "wallet",
};

// ============================================================
// STEP 1: AUTHENTICATION
// ============================================================

/**
 * Authenticate with PayMob to get an auth token.
 * @returns {string} Authentication token
 */
async function authenticate() {
	try {
		const response = await axios.post(`${PAYMOB_BASE_URL}/auth/tokens`, {
			api_key: PAYMOB_API_KEY,
		});
		return response.data.token;
	} catch (error) {
		console.error("❌ PayMob authentication failed:", error.response?.data || error.message);
		throw new Error("PayMob authentication failed");
	}
}

// ============================================================
// STEP 2: ORDER REGISTRATION
// ============================================================

/**
 * Register an order with PayMob.
 * @param {string} authToken - Token from authenticate()
 * @param {number} amountCents - Amount in cents (e.g., 5000 for 50.00 EGP)
 * @param {string} merchantOrderId - Unique internal order reference
 * @returns {Object} { id, ... }
 */
async function createOrder(authToken, amountCents, merchantOrderId) {
	try {
		const response = await axios.post(`${PAYMOB_BASE_URL}/ecommerce/orders`, {
			auth_token: authToken,
			delivery_needed: false,
			amount_cents: amountCents,
			currency: "EGP",
			merchant_order_id: merchantOrderId,
			items: [
				{
					name: "Wallet Recharge",
					amount_cents: amountCents,
					description: "Housepital Wallet Top-up",
					quantity: 1,
				},
			],
		});
		return response.data;
	} catch (error) {
		console.error("❌ PayMob order creation failed:", error.response?.data || error.message);
		throw new Error("PayMob order creation failed");
	}
}

// ============================================================
// STEP 3: PAYMENT KEY
// ============================================================

/**
 * Get a payment key for the PayMob payment.
 * @param {Object} params
 * @param {string} params.authToken
 * @param {number} params.orderId
 * @param {number} params.amountCents
 * @param {Object} params.billingData
 * @param {string} params.paymentMethod - 'card' or 'wallet'
 * @returns {string} Payment key
 */
async function getPaymentKey({ authToken, orderId, amountCents, billingData, paymentMethod }) {
	// Select the correct integration ID
	const integrationId =
		paymentMethod === PAYMENT_METHODS.WALLET
			? parseInt(PAYMOB_WALLET_INTEGRATION_ID)
			: parseInt(PAYMOB_CARD_INTEGRATION_ID);

	try {
		const response = await axios.post(`${PAYMOB_BASE_URL}/acceptance/payment_keys`, {
			auth_token: authToken,
			amount_cents: amountCents,
			expiration: 3600, // 1 hour
			order_id: orderId,
			billing_data: {
				apartment: billingData.apartment || "N/A",
				email: billingData.email || "customer@housepital.com",
				floor: billingData.floor || "N/A",
				first_name: billingData.firstName || "Housepital",
				street: billingData.street || "N/A",
				building: billingData.building || "N/A",
				phone_number: billingData.phone || "01000000000",
				shipping_method: "N/A",
				postal_code: billingData.postalCode || "00000",
				city: billingData.city || "Cairo",
				country: billingData.country || "EG",
				last_name: billingData.lastName || "User",
				state: billingData.state || "Cairo",
			},
			currency: "EGP",
			integration_id: integrationId,
		});
		return response.data.token;
	} catch (error) {
		console.error("❌ PayMob payment key failed:", error.response?.data || error.message);
		throw new Error("PayMob payment key generation failed");
	}
}

// ============================================================
// STEP 4A: CARD FLOW — Build iframe URL
// ============================================================

/**
 * Build the full PayMob iframe URL for card payments.
 * @param {string} paymentKey
 * @returns {string} Full iframe URL
 */
function buildIframeUrl(paymentKey) {
	return `https://accept.paymob.com/api/acceptance/iframes/${PAYMOB_IFRAME_ID}?payment_token=${paymentKey}`;
}

// ============================================================
// STEP 4B: WALLET FLOW — Pay with mobile wallet
// ============================================================

/**
 * Initiate a mobile wallet payment (Vodafone Cash, Etisalat Cash, etc.).
 * This makes a server-side API call and returns a redirect URL
 * that opens the wallet app on the user's phone.
 *
 * @param {string} paymentKey - Payment key from getPaymentKey()
 * @param {string} walletPhoneNumber - User's wallet phone number (e.g., "01xxxxxxxxx")
 * @returns {Object} { redirectUrl, ... }
 */
async function payWithWallet(paymentKey, walletPhoneNumber) {
	try {
		const response = await axios.post(
			`${PAYMOB_BASE_URL}/acceptance/payments/pay`,
			{
				source: {
					identifier: walletPhoneNumber,
					subtype: "WALLET",
				},
				payment_token: paymentKey,
			}
		);

		console.log("📱 Mobile wallet payment initiated:", JSON.stringify(response.data).substring(0, 300));

		// PayMob returns a redirect_url that opens the wallet app
		const redirectUrl = response.data.redirect_url || response.data.iframe_redirection_url;

		if (!redirectUrl) {
			throw new Error("No redirect URL received from PayMob wallet");
		}

		return {
			redirectUrl,
			transactionId: response.data.id,
			pending: response.data.pending,
		};
	} catch (error) {
		console.error("❌ PayMob wallet payment failed:", error.response?.data || error.message);
		throw new Error(error.response?.data?.message || "Mobile wallet payment failed");
	}
}

// ============================================================
// HMAC VERIFICATION
// ============================================================

/**
 * Verify PayMob webhook callback HMAC signature.
 * @param {Object} data - The transaction object from PayMob callback
 * @param {string} hmac - The HMAC value from the request query params
 * @returns {boolean} True if HMAC is valid
 */
function verifyHMAC(data, hmac) {
	if (!PAYMOB_HMAC_SECRET) {
		console.error("❌ PAYMOB_HMAC_SECRET is not set!");
		return false;
	}

	// PayMob HMAC concatenation order (alphabetical by key name)
	const concatenatedString = [
		data.amount_cents,
		data.created_at,
		data.currency,
		data.error_occured,
		data.has_parent_transaction,
		data.id,
		data.integration_id,
		data.is_3d_secure,
		data.is_auth,
		data.is_capture,
		data.is_refunded,
		data.is_standalone_payment,
		data.is_voided,
		data.order?.id || data.order,
		data.owner,
		data.pending,
		data.source_data?.pan || "",
		data.source_data?.sub_type || "",
		data.source_data?.type || "",
		data.success,
	].join("");

	const calculatedHMAC = crypto
		.createHmac("sha512", PAYMOB_HMAC_SECRET)
		.update(concatenatedString)
		.digest("hex");

	return calculatedHMAC === hmac;
}

// ============================================================
// FULL FLOW: Initiate Payment (Card or Wallet)
// ============================================================

/**
 * Execute the complete PayMob payment initiation flow.
 * @param {Object} params
 * @param {number} params.amount - Amount in EGP
 * @param {string} params.userId - Internal user ID
 * @param {Object} params.userInfo - { email, name, phone }
 * @param {string} params.paymentMethod - 'card' or 'wallet'
 * @param {string} [params.walletPhoneNumber] - Required for wallet payments
 * @returns {Object} { iframeUrl?, redirectUrl?, orderId, paymentKey }
 */
async function initiatePayment({ amount, userId, userInfo, paymentMethod = "card", walletPhoneNumber }) {
	// Step 1: Authenticate
	const authToken = await authenticate();

	// Step 2: Create order
	const amountCents = Math.round(amount * 100);
	const merchantOrderId = `WALLET_${userId}_${Date.now()}`;
	const orderData = await createOrder(authToken, amountCents, merchantOrderId);

	// Step 3: Get payment key (with correct integration ID)
	const paymentKey = await getPaymentKey({
		authToken,
		orderId: orderData.id,
		amountCents,
		billingData: {
			email: userInfo.email,
			firstName: userInfo.firstName || userInfo.name?.split(" ")[0] || "User",
			lastName: userInfo.lastName || userInfo.name?.split(" ").slice(1).join(" ") || "Housepital",
			phone: userInfo.phone || userInfo.mobile || "01000000000",
		},
		paymentMethod,
	});

	// Step 4: Route to the correct payment flow
	if (paymentMethod === PAYMENT_METHODS.WALLET) {
		// Mobile Wallet Flow — call PayMob pay endpoint
		if (!walletPhoneNumber) {
			throw new Error("Wallet phone number is required for mobile wallet payments");
		}

		const walletResult = await payWithWallet(paymentKey, walletPhoneNumber);

		return {
			paymentMethod: PAYMENT_METHODS.WALLET,
			redirectUrl: walletResult.redirectUrl,
			orderId: orderData.id,
			merchantOrderId,
			paymentKey,
			transactionId: walletResult.transactionId,
		};
	} else {
		// Card Flow — return iframe URL
		const iframeUrl = buildIframeUrl(paymentKey);

		return {
			paymentMethod: PAYMENT_METHODS.CARD,
			iframeUrl,
			orderId: orderData.id,
			merchantOrderId,
			paymentKey,
		};
	}
}

module.exports = {
	PAYMENT_METHODS,
	authenticate,
	createOrder,
	getPaymentKey,
	buildIframeUrl,
	payWithWallet,
	verifyHMAC,
	initiatePayment,
};
