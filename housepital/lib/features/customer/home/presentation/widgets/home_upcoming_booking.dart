import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../booking/presentation/pages/booking_tracking_page.dart';

class HomeUpcomingBooking extends StatefulWidget {
  final bool hasActiveBooking;
  final Map<String, dynamic>? booking;

  const HomeUpcomingBooking({
    super.key,
    required this.hasActiveBooking,
    this.booking,
  });

  @override
  State<HomeUpcomingBooking> createState() => _HomeUpcomingBookingState();
}

class _HomeUpcomingBookingState extends State<HomeUpcomingBooking> with SingleTickerProviderStateMixin {
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
    if (!widget.hasActiveBooking || widget.booking == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final booking = widget.booking!;
    
    final serviceName = booking['serviceName'] ?? 'Nursing Service';
    final nurseName = booking['nurseName'] ?? 'Assigning...';
    final status = (booking['status'] ?? 'IN PROGRESS').toString().toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingTrackingPage(booking: booking),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C24) : null,
            gradient: isDark 
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3498BB), Color(0xFF1E5B70)], // Trust Blue gradient
                ),
            borderRadius: BorderRadius.circular(24),
            border: isDark ? Border.all(color: const Color(0xFF3498BB).withAlpha(40), width: 1.5) : null,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3498BB).withAlpha(isDark ? 40 : 80),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Large background watermark icon
              Positioned(
                right: -20,
                bottom: -30,
                child: Icon(
                  Icons.local_hospital_rounded,
                  size: 120,
                  color: Colors.white.withAlpha(30),
                ),
              ),
              Row(
                children: [
                  // Status indicator (Pulsing)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return Container(
                            width: 52 + (_pulseController.value * 12),
                            height: 52 + (_pulseController.value * 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withAlpha(
                                (50 * (1 - _pulseController.value)).toInt(),
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withAlpha(80), width: 1.5),
                        ),
                        child: const Icon(
                          Icons.directions_walk_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: Colors.white.withAlpha(200),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '$nurseName • Active',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withAlpha(220),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Arrow
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha(40)),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}