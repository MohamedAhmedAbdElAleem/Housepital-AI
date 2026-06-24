import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class BookingsCanopyHeader extends StatelessWidget {
  final int activeCount;
  final int historyCount;
  final VoidCallback onRefresh;

  const BookingsCanopyHeader({
    super.key,
    required this.activeCount,
    required this.historyCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1F12),
                  Color(0xFF0D1A22),
                  Color(0xFF0D0C11),
                ],
                stops: [0.0, 0.5, 1.0],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary500,
                  AppColors.primary700,
                  AppColors.secondary500,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark ? [
          BoxShadow(
            color: AppColors.primary500.withAlpha(30),
            blurRadius: 60,
            spreadRadius: 20,
            offset: const Offset(0, -20),
          )
        ] : null,
      ),
      child: Stack(
        children: [
          // ── Geometric Background Rings ──
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha(20),
                  width: 2,
                ),
              ),
            ),
          ),
          // Small accent ring
          Positioned(
            bottom: 60,
            right: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha(25),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // ── Content ──
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 24,
              24,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title Group
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Bookings',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Track and manage your appointments',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    // Glassmorphic Refresh Button
                    GestureDetector(
                      onTap: onRefresh,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withAlpha(40),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // ── Stat Chips ──
                Row(
                  children: [
                    _buildGlassStatChip(
                      icon: Icons.flash_on_rounded,
                      label: '$activeCount Active',
                      isHighlighted: true,
                    ),
                    const SizedBox(width: 12),
                    _buildGlassStatChip(
                      icon: Icons.check_circle_rounded,
                      label: '$historyCount Completed',
                      isHighlighted: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatChip({
    required IconData icon,
    required String label,
    required bool isHighlighted,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(isHighlighted ? 40 : 20),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withAlpha(40),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isHighlighted ? Colors.white : Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isHighlighted ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
