import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../generated/l10n/app_localizations.dart';

class BookingsCanopyHeader extends StatelessWidget {
  final VoidCallback onRefresh;

  const BookingsCanopyHeader({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF16151A),
                  Color(0xFF0D0C10),
                ],
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
            color: AppColors.primary500.withAlpha(20),
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
                color: Colors.white.withAlpha(Theme.of(context).brightness == Brightness.dark ? 8 : 20),
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
                color: Colors.white.withAlpha(Theme.of(context).brightness == Brightness.dark ? 5 : 15),
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
                  color: Colors.white.withAlpha(Theme.of(context).brightness == Brightness.dark ? 8 : 20),
                  width: 2,
                ),
              ),
            ),
          ),
          // Small accent ring
          Positioned(
            bottom: 20,
            right: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha(Theme.of(context).brightness == Brightness.dark ? 10 : 25),
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
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title Group
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.bookingsTitle,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.bookingsSubtitle,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
