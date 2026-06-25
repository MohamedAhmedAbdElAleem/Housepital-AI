import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../profile/presentation/pages/wallet_page.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeWalletCard extends StatelessWidget {
  final UserModel? user;

  const HomeWalletCard({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WalletPage()),
          );
        },
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF242636), // Velvet Slate Purple
                      const Color(0xFF141522),
                    ]
                  : [
                      const Color(0xFF4F46E5), // Rich Royal Indigo
                      const Color(0xFF3730A3),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF4F46E5) : const Color(0xFF3730A3))
                    .withAlpha(isDark ? 25 : 80),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withAlpha(isDark ? 10 : 20),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Subtle background coin watermark
              Positioned(
                right: -25,
                top: -25,
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 150,
                  color: Colors.white.withAlpha(isDark ? 4 : 8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top balance row
                    Row(
                      children: [
                        // Wallet icon bubble
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(isDark ? 10 : 20),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withAlpha(isDark ? 10 : 30),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.wallet_giftcard_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Balance text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.housepitalWallet,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    user?.wallet?.toString() ?? '0.00',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.currencyEgp,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Quick Action Top-Up
                        _buildTopUpButton(context, l10n, isDark),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Bottom border and details
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(isDark ? 6 : 12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withAlpha(isDark ? 8 : 15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: Colors.white.withAlpha(180),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.availableBalance,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.white.withAlpha(200),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                l10n.history,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopUpButton(BuildContext context, AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalletPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              color: isDark ? const Color(0xFF141522) : const Color(0xFF3730A3),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.topUp,
              style: TextStyle(
                fontFamily: 'Inter',
                color: isDark ? const Color(0xFF141522) : const Color(0xFF3730A3),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
