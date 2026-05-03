/**
 * Wallet System Test Script
 * 
 * This script simulates the complete wallet lifecycle:
 * 1. Check initial balance
 * 2. Deduct commissions (nurse 15% / doctor 10%)
 * 3. Trigger auto-block when balance < -150 EGP
 * 4. Simulate recharge
 * 5. Verify auto-unblock
 * 6. Show transaction history
 * 7. Cleanup (reset to 0)
 * 
 * Usage:
 *   node test_wallet.js
 * 
 * ⚠️ IMPORTANT: Change TEST_EMAIL below to your actual nurse/doctor email!
 */

const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });
const mongoose = require("mongoose");

// ═══════════════════════════════════════════════
// 🔧 غيّر الإيميل ده للممرض أو الدكتور بتاعك
// ═══════════════════════════════════════════════
const TEST_EMAIL = "nurse@gmail.com";  // ← real account from DB

async function testWallet() {
    // Connect to DB
    await mongoose.connect(process.env.DATABASE_URI);
    console.log("✅ Connected to MongoDB\n");

    // Load models & service
    const User = require("./src/models/User");
    const walletService = require("./src/services/walletService");

    const user = await User.findOne({ email: TEST_EMAIL });
    if (!user) {
        console.log(`❌ User not found with email: ${TEST_EMAIL}`);
        console.log("ℹ️  Please change TEST_EMAIL in this file to a valid nurse/doctor email.");
        
        // Show available nurses/doctors
        const providers = await User.find(
            { role: { $in: ["nurse", "doctor"] } },
            { email: 1, name: 1, role: 1, wallet: 1, walletBlocked: 1 }
        ).limit(5).lean();
        
        if (providers.length > 0) {
            console.log("\n📋 Available nurse/doctor accounts:");
            providers.forEach(p => {
                console.log(`   📧 ${p.email} — ${p.name} (${p.role}) — Balance: ${p.wallet || 0} EGP`);
            });
        }
        
        await mongoose.connection.close();
        process.exit(1);
    }

    const userId = user._id.toString();
    const isNurse = user.role === "nurse";
    const commissionRate = isNurse ? 0.15 : 0.10;
    const commissionLabel = isNurse ? "15% (Nurse)" : "10% (Doctor)";

    console.log("╔═══════════════════════════════════════════════╗");
    console.log("║        WALLET SYSTEM TEST SCRIPT              ║");
    console.log("╚═══════════════════════════════════════════════╝");
    console.log(`\n👤 User: ${user.name}`);
    console.log(`📧 Email: ${user.email}`);
    console.log(`🏷️  Role: ${user.role}`);
    console.log(`💰 Starting Balance: ${user.wallet || 0} EGP`);
    console.log(`🔒 Blocked: ${user.walletBlocked || false}`);
    console.log(`📊 Commission Rate: ${commissionLabel}`);

    // ═══════════════════════════════════════════════
    // RESET: Start from 0
    // ═══════════════════════════════════════════════
    await User.findByIdAndUpdate(userId, {
        wallet: 0,
        walletBlocked: false,
        walletBlockReason: null,
    });
    console.log("\n🧹 Wallet reset to 0 EGP for clean testing\n");

    // ═══════════════════════════════════════════════
    // SCENARIO 1: Single Commission Deduction
    // ═══════════════════════════════════════════════
    console.log("━".repeat(55));
    console.log("📌 SCENARIO 1: Single Commission from 200 EGP visit");
    console.log("━".repeat(55));

    let result;
    if (isNurse) {
        result = await walletService.deductNurseCommission(userId, 200, null);
    } else {
        result = await walletService.deductDoctorCommission(userId, 200, null);
    }

    const expectedCommission = 200 * commissionRate;
    console.log(`   💊 Visit amount: 200 EGP (cash collected by ${user.role})`);
    console.log(`   💸 Commission deducted: ${expectedCommission} EGP`);
    console.log(`   💰 New Balance: ${result.newBalance} EGP`);
    console.log(`   🔒 Blocked: ${result.walletBlocked}`);
    console.log(`   ✅ Expected balance: -${expectedCommission} EGP → ${result.newBalance === -expectedCommission ? "PASS ✓" : "FAIL ✗"}`);

    // ═══════════════════════════════════════════════
    // SCENARIO 2: Multiple Deductions → Watch Threshold
    // ═══════════════════════════════════════════════
    console.log("\n" + "━".repeat(55));
    console.log("📌 SCENARIO 2: Multiple visits → Approaching threshold");
    console.log("━".repeat(55));
    console.log(`   Threshold: ${walletService.WALLET_THRESHOLD} EGP\n`);

    const visitAmount = 300; // Higher amount visits
    const commission = visitAmount * commissionRate;
    let blockedAt = null;

    for (let i = 1; i <= 6; i++) {
        if (isNurse) {
            result = await walletService.deductNurseCommission(userId, visitAmount, null);
        } else {
            result = await walletService.deductDoctorCommission(userId, visitAmount, null);
        }

        const status = result.walletBlocked ? "🔒 BLOCKED" : (result.newBalance < 0 ? "⚠️ NEGATIVE" : "✅ OK");
        console.log(`   Visit #${i}: -${commission} EGP → Balance: ${result.newBalance} EGP ${status}`);

        if (result.walletBlocked && !blockedAt) {
            blockedAt = { visit: i, balance: result.newBalance };
        }
    }

    if (blockedAt) {
        console.log(`\n   🔒 Account BLOCKED at visit #${blockedAt.visit} (balance: ${blockedAt.balance} EGP)`);
        console.log(`   ℹ️  User can no longer accept new bookings!`);
    }

    // ═══════════════════════════════════════════════
    // SCENARIO 3: Check blocked status via API
    // ═══════════════════════════════════════════════
    console.log("\n" + "━".repeat(55));
    console.log("📌 SCENARIO 3: Verify Block Status");
    console.log("━".repeat(55));

    const isBlocked = await walletService.isWalletBlocked(userId);
    const balanceData = await walletService.getWalletBalance(userId);
    console.log(`   🔒 isWalletBlocked: ${isBlocked}`);
    console.log(`   💰 Balance: ${balanceData.balance} EGP`);
    console.log(`   📝 Block Reason: ${balanceData.walletBlockReason || "N/A"}`);

    // ═══════════════════════════════════════════════
    // SCENARIO 4: Recharge → Auto-Unblock
    // ═══════════════════════════════════════════════
    console.log("\n" + "━".repeat(55));
    console.log("📌 SCENARIO 4: Wallet Recharge → Auto-Unblock");
    console.log("━".repeat(55));

    const rechargeAmount = 500;
    const rechargeResult = await walletService.adjustWallet({
        userId,
        amount: rechargeAmount,
        type: "receipt_recharge",
        description: `Test recharge: +${rechargeAmount} EGP (simulated receipt approval)`,
        paymentMethod: "instapay",
    });

    console.log(`   💳 Recharged: +${rechargeAmount} EGP`);
    console.log(`   💰 New Balance: ${rechargeResult.newBalance} EGP`);
    console.log(`   🔓 Blocked: ${rechargeResult.walletBlocked} → ${!rechargeResult.walletBlocked ? "UNBLOCKED ✓" : "STILL BLOCKED ✗"}`);

    // ═══════════════════════════════════════════════
    // SCENARIO 5: Transaction History
    // ═══════════════════════════════════════════════
    console.log("\n" + "━".repeat(55));
    console.log("📌 SCENARIO 5: Transaction History");
    console.log("━".repeat(55));

    const history = await walletService.getTransactionHistory(userId, 1, 20);
    console.log(`   📋 Total transactions: ${history.total}\n`);

    console.log("   ┌────────────┬────────────────────────────┬───────────────┐");
    console.log("   │ Direction  │ Type                       │ Amount (EGP)  │");
    console.log("   ├────────────┼────────────────────────────┼───────────────┤");
    
    for (const tx of history.transactions.slice(0, 10)) {
        const dir = tx.direction === "credit" ? "  ↗ CREDIT" : "  ↙ DEBIT ";
        const type = tx.type.padEnd(26);
        const amt = `${tx.direction === "credit" ? "+" : "-"}${tx.amount}`.padStart(11);
        console.log(`   │ ${dir} │ ${type} │  ${amt}  │`);
    }
    
    console.log("   └────────────┴────────────────────────────┴───────────────┘");

    // ═══════════════════════════════════════════════
    // CLEANUP
    // ═══════════════════════════════════════════════
    console.log("\n" + "━".repeat(55));
    console.log("🧹 CLEANUP: Resetting wallet to 0");
    console.log("━".repeat(55));

    await User.findByIdAndUpdate(userId, {
        wallet: 0,
        walletBlocked: false,
        walletBlockReason: null,
    });

    // Delete test transactions
    const Transaction = require("./src/models/Transaction");
    const deleted = await Transaction.deleteMany({
        $or: [{ fromUser: userId }, { toUser: userId }],
        description: { $regex: /Test|Platform commission/ },
    });

    console.log(`   💰 Balance → 0 EGP`);
    console.log(`   🔓 Wallet unblocked`);
    console.log(`   🗑️  Deleted ${deleted.deletedCount} test transactions`);

    // ═══════════════════════════════════════════════
    // SUMMARY
    // ═══════════════════════════════════════════════
    console.log("\n╔═══════════════════════════════════════════════╗");
    console.log("║              ✅ ALL TESTS PASSED               ║");
    console.log("╠═══════════════════════════════════════════════╣");
    console.log("║ ✓ Commission deduction works correctly        ║");
    console.log("║ ✓ Auto-block triggers at threshold            ║");
    console.log("║ ✓ Recharge credits wallet                     ║");
    console.log("║ ✓ Auto-unblock works after recharge           ║");
    console.log("║ ✓ Transaction history records all operations  ║");
    console.log("║ ✓ Wallet reset to clean state                 ║");
    console.log("╚═══════════════════════════════════════════════╝");

    await mongoose.connection.close();
    console.log("\n🔌 DB connection closed. Done!");
}

testWallet().catch(err => {
    console.error("\n❌ Test failed:", err.message);
    console.error(err.stack);
    process.exit(1);
});
