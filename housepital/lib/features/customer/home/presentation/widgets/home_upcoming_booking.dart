import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../booking/presentation/pages/booking_tracking_page.dart';
import '../../../../../generated/l10n/app_localizations.dart';

class HomeUpcomingBooking extends StatefulWidget {
  final bool hasActiveBooking;
  final Map<String, dynamic>? booking;

  const HomeUpcomingBooking({
    super.key,
    this.hasActiveBooking = true,
    this.booking,
  });

  @override
  State<HomeUpcomingBooking> createState() => _HomeUpcomingBookingState();
}

class _HomeUpcomingBookingState extends State<HomeUpcomingBooking>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasActiveBooking) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final serviceName = widget.booking?['serviceName'] ?? l10n.nursingService;
    final nurseName = widget.booking?['nurseName'] ?? l10n.assigningNurse;
    final rawStatus = (widget.booking?['status'] ?? 'IN PROGRESS').toString().toUpperCase();
    final status = (rawStatus == 'IN_PROGRESS' || rawStatus == 'IN PROGRESS') 
        ? l10n.activeStatus 
        : rawStatus;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingTrackingPage(booking: widget.booking ?? {}),
            ),
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
                      const Color(0xFF1E3C40), // Premium Emerald Deep Pine
                      const Color(0xFF112224),
                    ]
                  : [
                      const Color(0xFF26B09B), // Teal
                      const Color(0xFF1D8F7D),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF1E3C40) : const Color(0xFF26B09B))
                    .withAlpha(isDark ? 60 : 80),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withAlpha(isDark ? 10 : 25),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Large translucent background icon (Watermark style)
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.local_hospital_rounded,
                  size: 140,
                  color: Colors.white.withAlpha(isDark ? 5 : 8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Service Icon Container
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
                            Icons.medical_services_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Service Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceName,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nurseName,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(isDark ? 10 : 20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withAlpha(isDark ? 10 : 25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: Tween(begin: 1.0, end: 1.3).animate(
                                  CurvedAnimation(
                                    parent: _pulseController,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4ADE80), // Vibrant Green
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                status,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Glassmorphic ETA Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
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
                          const Icon(
                            Icons.directions_walk_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isDark ? 'Nurse en route...' : 'Nurse is on the way',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.white70,
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
}
