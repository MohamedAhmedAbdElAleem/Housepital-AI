/**
 * Wallet Middleware
 *
 * Reusable middleware to check wallet status before allowing actions.
 */

const User = require("../models/User");

/**
 * Middleware that checks if the current user's wallet is blocked.
 * If blocked, returns 403 with the block reason.
 * Use this before any action that should be restricted when wallet is in debt.
 */
const checkWalletNotBlocked = async (req, res, next) => {
    try {
        const userId = req.user?.id;
        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Not authenticated",
            });
        }

        const user = await User.findById(userId).select("walletBlocked walletBlockReason wallet");
        if (!user) {
            return res.status(404).json({
                success: false,
                message: "User not found",
            });
        }

        if (user.walletBlocked) {
            return res.status(403).json({
                success: false,
                message: "Your account is restricted due to outstanding wallet balance.",
                walletBlocked: true,
                walletBlockReason: user.walletBlockReason,
                currentBalance: user.wallet,
            });
        }

        next();
    } catch (error) {
        console.error("❌ Wallet check middleware error:", error);
        res.status(500).json({
            success: false,
            message: "Error checking wallet status",
        });
    }
};

module.exports = { checkWalletNotBlocked };
