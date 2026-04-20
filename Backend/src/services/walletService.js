/**
 * Wallet Service for Housepital
 *
 * Handles all wallet operations:
 * - Atomic balance adjustments via MongoDB $inc
 * - Threshold enforcement (-150 EGP)
 * - Commission deductions for Nurse (15%) and Doctor (10%)
 * - Auto-block / unblock logic
 */

const User = require("../models/User");
const Transaction = require("../models/Transaction");
const Nurse = require("../models/Nurse");
const Doctor = require("../models/Doctor");

// ============================================================
// CONSTANTS
// ============================================================
const WALLET_THRESHOLD = -150; // Maximum allowed negative balance (EGP)
const NURSE_COMMISSION_RATE = 0.15; // 15% platform commission for nurses
const DOCTOR_COMMISSION_RATE = 0.10; // 10% platform commission for doctors

// ============================================================
// CORE WALLET OPERATIONS
// ============================================================

/**
 * Get wallet balance and status for a user.
 * @param {string} userId
 * @returns {Object} { balance, walletBlocked, walletBlockReason }
 */
async function getWalletBalance(userId) {
    const user = await User.findById(userId).select("wallet walletBlocked walletBlockReason role");
    if (!user) {
        throw new Error("User not found");
    }
    return {
        balance: user.wallet,
        walletBlocked: user.walletBlocked,
        walletBlockReason: user.walletBlockReason,
        role: user.role,
    };
}

/**
 * Atomically adjust wallet balance and create a transaction record.
 * Uses MongoDB $inc for concurrency safety.
 *
 * @param {Object} params
 * @param {string} params.userId - The user whose wallet to adjust
 * @param {number} params.amount - Positive to credit, negative to debit
 * @param {string} params.type - Transaction type enum value
 * @param {string} params.description - Human-readable description
 * @param {string} [params.bookingId] - Related booking ID
 * @param {string} [params.paymentMethod] - Payment method used
 * @param {string} [params.paymobOrderId] - PayMob order ID for recharges
 * @returns {Object} { transaction, newBalance, walletBlocked }
 */
async function adjustWallet({
    userId,
    amount,
    type,
    description,
    bookingId = null,
    paymentMethod = null,
    paymobOrderId = null,
}) {
    // Atomically update the balance
    const updatedUser = await User.findByIdAndUpdate(
        userId,
        { $inc: { wallet: amount } },
        { new: true, select: "wallet walletBlocked walletBlockReason role" }
    );

    if (!updatedUser) {
        throw new Error("User not found");
    }

    const newBalance = updatedUser.wallet;

    // Create transaction record
    const transaction = await Transaction.create({
        type,
        amount: Math.abs(amount),
        currency: "EGP",
        direction: amount >= 0 ? "credit" : "debit",
        fromUser: amount < 0 ? userId : null,
        toUser: amount >= 0 ? userId : null,
        bookingId: bookingId || undefined,
        status: "completed",
        paymentMethod: paymentMethod || undefined,
        paymobOrderId: paymobOrderId || undefined,
        description,
        balanceAfter: newBalance,
    });

    // Check and enforce threshold
    const blockResult = await checkAndEnforceThreshold(userId, newBalance);

    return {
        transaction,
        newBalance,
        walletBlocked: blockResult.walletBlocked,
    };
}

/**
 * Check if user's balance breaches the threshold and auto-block/unblock.
 * @param {string} userId
 * @param {number} [currentBalance] - Optional, fetches if not provided
 * @returns {Object} { walletBlocked, walletBlockReason }
 */
async function checkAndEnforceThreshold(userId, currentBalance = null) {
    let balance = currentBalance;
    if (balance === null) {
        const user = await User.findById(userId).select("wallet");
        if (!user) throw new Error("User not found");
        balance = user.wallet;
    }

    if (balance < WALLET_THRESHOLD) {
        // Block the user
        await User.findByIdAndUpdate(userId, {
            walletBlocked: true,
            walletBlockReason: `Wallet balance (${balance} EGP) exceeded the minimum threshold of ${WALLET_THRESHOLD} EGP. Please recharge your wallet or contact support.`,
        });
        return {
            walletBlocked: true,
            walletBlockReason: `Balance below ${WALLET_THRESHOLD} EGP threshold`,
        };
    } else {
        // Unblock if previously blocked and now above threshold
        const user = await User.findById(userId).select("walletBlocked");
        if (user && user.walletBlocked) {
            await User.findByIdAndUpdate(userId, {
                walletBlocked: false,
                walletBlockReason: null,
            });
        }
        return { walletBlocked: false, walletBlockReason: null };
    }
}

/**
 * Explicitly unblock a user's wallet (admin/support action).
 * @param {string} userId
 */
async function unblockWallet(userId) {
    await User.findByIdAndUpdate(userId, {
        walletBlocked: false,
        walletBlockReason: null,
    });
}

/**
 * Check if a user's wallet is currently blocked.
 * @param {string} userId
 * @returns {boolean}
 */
async function isWalletBlocked(userId) {
    const user = await User.findById(userId).select("walletBlocked");
    return user ? user.walletBlocked : false;
}

// ============================================================
// COMMISSION DEDUCTIONS
// ============================================================

/**
 * Deduct 15% commission from nurse's wallet after a completed visit.
 * The nurse collects full cash from the patient; the platform deducts its cut.
 *
 * @param {string} nurseUserId - The User._id of the nurse
 * @param {number} bookingAmount - The total service amount collected in cash
 * @param {string} bookingId - The booking ID for the transaction record
 * @returns {Object} { transaction, newBalance, walletBlocked }
 */
async function deductNurseCommission(nurseUserId, bookingAmount, bookingId) {
    const commissionAmount = Math.round(bookingAmount * NURSE_COMMISSION_RATE * 100) / 100;

    console.log(`💰 Deducting nurse commission: ${commissionAmount} EGP (${NURSE_COMMISSION_RATE * 100}% of ${bookingAmount}) from user ${nurseUserId}`);

    const result = await adjustWallet({
        userId: nurseUserId,
        amount: -commissionAmount,
        type: "commission_deduction",
        description: `Platform commission (${NURSE_COMMISSION_RATE * 100}%) for completed nursing visit`,
        bookingId,
        paymentMethod: "wallet",
    });

    // Also update nurse's financial tracking fields
    await Nurse.findOneAndUpdate(
        { user: nurseUserId },
        {
            $inc: {
                totalEarnings: bookingAmount,
                availableBalance: -commissionAmount,
            },
        }
    );

    return result;
}

/**
 * Deduct 10% commission from doctor's wallet after a completed clinic appointment.
 *
 * @param {string} doctorUserId - The User._id of the doctor
 * @param {number} bookingAmount - The total appointment amount
 * @param {string} bookingId - The booking ID for the transaction record
 * @returns {Object} { transaction, newBalance, walletBlocked }
 */
async function deductDoctorCommission(doctorUserId, bookingAmount, bookingId) {
    const commissionAmount = Math.round(bookingAmount * DOCTOR_COMMISSION_RATE * 100) / 100;

    console.log(`💰 Deducting doctor commission: ${commissionAmount} EGP (${DOCTOR_COMMISSION_RATE * 100}% of ${bookingAmount}) from user ${doctorUserId}`);

    const result = await adjustWallet({
        userId: doctorUserId,
        amount: -commissionAmount,
        type: "commission_deduction",
        description: `Platform commission (${DOCTOR_COMMISSION_RATE * 100}%) for completed clinic appointment`,
        bookingId,
        paymentMethod: "wallet",
    });

    return result;
}

// ============================================================
// TRANSACTION HISTORY
// ============================================================

/**
 * Get paginated transaction history for a user.
 * @param {string} userId
 * @param {number} page - Page number (1-indexed)
 * @param {number} limit - Items per page
 * @returns {Object} { transactions, total, page, totalPages }
 */
async function getTransactionHistory(userId, page = 1, limit = 20) {
    const skip = (page - 1) * limit;

    const [transactions, total] = await Promise.all([
        Transaction.find({
            $or: [{ fromUser: userId }, { toUser: userId }],
        })
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .populate("bookingId", "serviceName type")
            .lean(),
        Transaction.countDocuments({
            $or: [{ fromUser: userId }, { toUser: userId }],
        }),
    ]);

    return {
        transactions,
        total,
        page,
        totalPages: Math.ceil(total / limit),
    };
}

module.exports = {
    WALLET_THRESHOLD,
    NURSE_COMMISSION_RATE,
    DOCTOR_COMMISSION_RATE,
    getWalletBalance,
    adjustWallet,
    checkAndEnforceThreshold,
    unblockWallet,
    isWalletBlocked,
    deductNurseCommission,
    deductDoctorCommission,
    getTransactionHistory,
};
