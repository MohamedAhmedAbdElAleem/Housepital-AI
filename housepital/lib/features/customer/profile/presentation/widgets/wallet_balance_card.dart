import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class WalletBalanceCard extends StatelessWidget {
  final double balance;
  final double threshold;
  final bool isBlocked;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.threshold,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBlocked
              ? [const Color(0xFF991B1B), const Color(0xFF7F1D1D)]
              : [const Color(0xFF1E3A8A), const Color(0xFF1E40AF), const Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isBlocked ? Colors.red : const Color(0xFF1E3A8A)).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Watermark Icon
            Positioned(
              bottom: -20,
              right: -20,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 150,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            // Glassmorphic Layer
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          isBlocked ? Icons.lock_outline_rounded : Icons.wallet_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      if (isBlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 6),
                              Text(
                                'RESTRICTED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${balance >= 0 ? "" : "-"}${balance.abs().toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _StatLabel(
                        label: 'LIMIT',
                        value: '${threshold.toInt()} EGP',
                      ),
                      const SizedBox(width: 24),
                      _StatLabel(
                        label: 'STATUS',
                        value: isBlocked ? 'Blocked' : 'Active',
                        color: isBlocked ? Colors.redAccent : const Color(0xFF4ADE80),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatLabel({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
