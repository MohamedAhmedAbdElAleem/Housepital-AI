const mongoose = require("mongoose");

const transactionSchema = new mongoose.Schema(
    {
        // Transaction Type
        type: {
            type: String,
            enum: [
                "booking_payment",      // Customer pays for booking
                "tools_deposit",        // Customer pays tools deposit
                "cancellation_fee",     // Cancellation fee charged
                "refund",               // Refund to customer
                "nurse_earning",        // Nurse earns from visit
                "doctor_earning",       // Doctor earns from appointment
                "tools_compensation",   // Tools compensation to nurse
                "withdrawal",           // Provider withdraws earnings
                "platform_fee",         // Platform commission
                "bonus_credit",         // Good faith bonus
                "no_show_fee"           // No-show penalty
            ],
            required: [true, "Transaction type is required"]
        },
        // Amount
        amount: {
            type: Number,
            required: [true, "Amount is required"]
        },
        currency: {
            type: String,
            default: "EGP"
        },
        // Direction
        direction: {
            type: String,
            enum: ["credit", "debit"],
            required: true
        },
        // Parties involved
        fromUser: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User"
        },
        toUser: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User"
        },
        // Related entities
        bookingId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Booking"
        },
        // Status
        status: {
            type: String,
            enum: ["pending", "processing", "completed", "failed", "cancelled"],
            default: "pending"
        },
        // Payment details
        paymentMethod: {
            type: String,
            enum: ["cash", "card", "wallet", "fawry", "bank_transfer", "vodafone_cash"]
        },
        paymentReference: {
            type: String,
            trim: true
        },
        // For withdrawals
        withdrawalDetails: {
            bankName: String,
            accountNumber: String,
            accountHolderName: String,
            eWalletProvider: String,
            eWalletNumber: String
        },
        // Metadata
        description: {
            type: String,
            trim: true
        },
        notes: {
            type: String,
            trim: true
        },
        // Admin processing
        processedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User"
        },
        processedAt: {
            type: Date
        },
        // Balance after transaction (for audit trail)
        balanceAfter: {
            type: Number
        }
    },
    { timestamps: true }
);

// Indexes
transactionSchema.index({ type: 1, status: 1, createdAt: -1 });
transactionSchema.index({ fromUser: 1, createdAt: -1 });
transactionSchema.index({ toUser: 1, createdAt: -1 });
transactionSchema.index({ bookingId: 1 });
transactionSchema.index({ status: 1, createdAt: -1 });

module.exports = mongoose.model("Transaction", transactionSchema);
