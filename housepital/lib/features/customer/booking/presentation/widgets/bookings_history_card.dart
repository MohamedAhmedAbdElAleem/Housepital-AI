import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/booking_utils.dart';

class BookingsHistoryCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final int index;

  const BookingsHistoryCard({
    super.key,
    required this.booking,
    required this.index,
  });

  bool _isClinic(dynamic b) =>
      (b['type'] ?? b['bookingType'] ?? '') == 'clinic_appointment';

  String? _doctorName(Map<String, dynamic> b) {
    if (b['doctorName'] != null) return b['doctorName'] as String;
    final doc = b['doctorId'];
    if (doc is Map) {
      final user = doc['user'];
      if (user is Map) return user['name'] as String?;
      return doc['name'] as String?;
    }
    return null;
  }

  String _clinicName(Map<String, dynamic> b) {
    if (b['clinicName'] != null) return b['clinicName'] as String;
    final c = b['clinicId'];
    if (c is Map) return (c['name'] ?? '') as String;
    return '';
  }

  String _doctorSpec(Map<String, dynamic> b) {
    if (b['doctorSpecialization'] != null) return b['doctorSpecialization'];
    final doc = b['doctorId'];
    if (doc is Map) return (doc['specialization'] ?? '') as String;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final status = BookingUtils.normalizeStatus(booking['status']);
    final isClinic = _isClinic(booking);
    final serviceName = booking['serviceName'] ?? 'Service';
    final price = (booking['servicePrice'] ?? 0).toDouble();
    final scheduledDate = booking['scheduledDate'];
    final rating = booking['nurseRating'] ?? 0.0;

    final providerName = isClinic
        ? (_doctorName(booking) ?? _clinicName(booking))
        : (booking['nurseName'] ?? 'Nurse');
    final providerSub = isClinic
        ? (_clinicName(booking).isNotEmpty
            ? _clinicName(booking)
            : _doctorSpec(booking))
        : null;

    // History status styling
    List<Color> statusGradient;
    String historyStatusLabel;
    IconData historyStatusIcon;
    IconData watermarkIcon;

    switch (status) {
      case 'cancelled':
        statusGradient = [const Color(0xFFEF4444), const Color(0xFFDC2626)];
        historyStatusLabel = 'Cancelled';
        historyStatusIcon = Icons.cancel_rounded;
        watermarkIcon = Icons.cancel_outlined;
        break;
      case 'no-show':
        statusGradient = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
        historyStatusLabel = 'No Show';
        historyStatusIcon = Icons.event_busy_rounded;
        watermarkIcon = Icons.event_busy_outlined;
        break;
      case 'completed':
      default:
        statusGradient = [const Color(0xFF2ECC71), const Color(0xFF219150)];
        historyStatusLabel = 'Completed';
        historyStatusIcon = Icons.check_circle_rounded;
        watermarkIcon = Icons.verified_outlined;
        break;
    }

    String dateLabel = historyStatusLabel;
    if (scheduledDate != null) {
      try {
        final date = DateTime.parse(scheduledDate);
        dateLabel =
            '$historyStatusLabel · ${DateFormat('MMM d, yyyy').format(date)}';
      } catch (_) {}
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: isDark ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: statusGradient,
                ) : null,
                color: isDark ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? statusGradient[0].withAlpha(40) : statusGradient[0].withAlpha(30),
                  width: isDark ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusGradient[0].withAlpha(isDark ? 50 : 25),
                    blurRadius: isDark ? 30 : 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // ── Subtle watermark icon ──
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: Icon(
                      watermarkIcon,
                      size: 80,
                      color: isDark ? Colors.white.withAlpha(10) : statusGradient[0].withAlpha(15),
                    ),
                  ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // ── Status icon with gradient background ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: statusGradient,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: statusGradient[0].withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      historyStatusIcon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                dateLabel,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              isClinic
                                  ? Icons.local_hospital_rounded
                                  : Icons.person_outline,
                              size: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                providerName,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (isClinic &&
                            providerSub != null &&
                            providerSub.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.local_hospital_rounded,
                                  size: 12, color: Color(0xFF3498BB)),
                              const SizedBox(width: 4),
                              Text(
                                providerSub,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: Color(0xFF3498BB),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (!isClinic && rating > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < (rating as num).round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: const Color(0xFFF59E0B),
                                size: 14,
                              );
                            }),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${price.toStringAsFixed(0)} EGP',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: statusGradient,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: statusGradient[0].withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          historyStatusLabel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2ECC71),
                                Color(0xFF219150),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF2ECC71).withAlpha(40),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Rebook',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
      ),
    );
  },
),
);
}
}
