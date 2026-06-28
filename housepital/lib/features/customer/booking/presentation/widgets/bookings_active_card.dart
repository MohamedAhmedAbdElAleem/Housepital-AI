import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../utils/booking_utils.dart';
import '../pages/booking_tracking_page.dart';
import '../pages/booking_matching_screen.dart';
import '../widgets/booking_cancellation_modal.dart';
import '../../../../../core/network/api_service.dart';
import 'booking_ticket_modal.dart';

class BookingsActiveCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final int index;
  final VoidCallback onRefresh;

  const BookingsActiveCard({
    super.key,
    required this.booking,
    required this.index,
    required this.onRefresh,
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

  String _doctorSpec(Map<String, dynamic> b) {
    if (b['doctorSpecialization'] != null) return b['doctorSpecialization'];
    final doc = b['doctorId'];
    if (doc is Map) return (doc['specialization'] ?? '') as String;
    return '';
  }

  String _clinicName(Map<String, dynamic> b) {
    if (b['clinicName'] != null) return b['clinicName'] as String;
    final c = b['clinicId'];
    if (c is Map) return (c['name'] ?? '') as String;
    return '';
  }

  String _clinicAddress(Map<String, dynamic> b) {
    if (b['clinicAddress'] != null) return b['clinicAddress'] as String;
    final c = b['clinicId'];
    if (c is Map) {
      final addr = c['address'];
      if (addr == null) return '';
      if (addr is String) return addr;
      if (addr is Map) {
        final street = addr['street'] ?? '';
        final area = addr['area'] ?? '';
        final city = addr['city'] ?? '';
        final state = addr['state'] ?? '';
        return [street, area, city, state]
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .join(', ');
      }
      return addr.toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final status = BookingUtils.normalizeStatus(booking['status']);
    final isMatchingRequest = booking['isMatchingRequest'] == true;
    final canResumeMatching =
        isMatchingRequest &&
        (status == 'searching' ||
            status == 'offers_pending' ||
            status == 'nurse_accepted');
    final isClinic = _isClinic(booking);
    final serviceName = booking['serviceName'] ?? 'Service';
    final patientName = booking['patientName'] ?? 'Patient';
    final price = (booking['servicePrice'] ?? 0).toDouble();

    final nurseName = booking['nurseName'] as String?;
    final doctorName = _doctorName(booking);
    final providerName = isClinic ? doctorName : nurseName;
    final providerSub =
        isClinic
            ? (_doctorSpec(booking).isNotEmpty
                ? _doctorSpec(booking)
                : _clinicName(booking))
            : '${booking['nurseRating'] ?? 4.5}';

    final scheduledDate = booking['scheduledDate'] as String?;
    final scheduledTime = booking['scheduledTime'] as String?;
    final isQueue = booking['timeOption'] == 'queue';

    // ── Jewel-toned gradient mapping per status ──
    List<Color> tileGradient;
    Color shadowColor;
    String statusLabel;
    IconData statusIcon;
    IconData watermarkIcon;

    final l10n = AppLocalizations.of(context)!;

    switch (status) {
      case 'in-progress':
        tileGradient =
            isClinic
                ? [const Color(0xFF3498BB), const Color(0xFF256C85)]
                : [const Color(0xFF2ECC71), const Color(0xFF219150)];
        shadowColor =
            isClinic ? const Color(0xFF3498BB) : const Color(0xFF2ECC71);
        statusLabel = isClinic ? l10n.inClinic : l10n.inProgress;
        statusIcon =
            isClinic
                ? Icons.local_hospital_rounded
                : Icons.directions_car_rounded;
        watermarkIcon =
            isClinic
                ? Icons.local_hospital_rounded
                : Icons.medical_services_rounded;
        break;
      case 'arrived':
        tileGradient = [const Color(0xFFEA580C), const Color(0xFFC2410C)];
        shadowColor = const Color(0xFFEA580C);
        statusLabel = isClinic ? l10n.readyForVisit : l10n.nurseArrived;
        statusIcon = Icons.location_on_rounded;
        watermarkIcon = Icons.location_on_rounded;
        break;
      case 'on-the-way':
        tileGradient = [const Color(0xFF0EA5E9), const Color(0xFF0284C7)];
        shadowColor = const Color(0xFF0EA5E9);
        statusLabel = isClinic ? l10n.confirmed : l10n.onTheWay;
        statusIcon = Icons.directions_car_rounded;
        watermarkIcon = Icons.directions_car_rounded;
        break;
      case 'confirmed':
      case 'assigned':
        tileGradient =
            isClinic
                ? [const Color(0xFF3498BB), const Color(0xFF256C85)]
                : [const Color(0xFF2ECC71), const Color(0xFF219150)];
        shadowColor =
            isClinic ? const Color(0xFF3498BB) : const Color(0xFF2ECC71);
        statusLabel = l10n.confirmed;
        statusIcon = Icons.check_circle_rounded;
        watermarkIcon = Icons.verified_rounded;
        break;
      case 'searching':
      case 'pending':
        tileGradient = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
        shadowColor = const Color(0xFFF59E0B);
        statusLabel = isClinic ? l10n.awaitingConfirmation : l10n.findingNurse;
        statusIcon =
            isClinic ? Icons.hourglass_top_rounded : Icons.search_rounded;
        watermarkIcon = Icons.search_rounded;
        break;
      case 'offers_pending':
        tileGradient = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
        shadowColor = const Color(0xFFF59E0B);
        statusLabel = l10n.findingNurse;
        statusIcon = Icons.search_rounded;
        watermarkIcon = Icons.search_rounded;
        break;
      case 'nurse_accepted':
        tileGradient = [const Color(0xFF16A34A), const Color(0xFF15803D)];
        shadowColor = const Color(0xFF16A34A);
        statusLabel = l10n.nurseOffersReady;
        statusIcon = Icons.local_offer_rounded;
        watermarkIcon = Icons.local_offer_rounded;
        break;
      default:
        tileGradient = [const Color(0xFF64748B), const Color(0xFF475569)];
        shadowColor = const Color(0xFF64748B);
        statusLabel = l10n.statusPending;
        statusIcon = Icons.schedule_rounded;
        watermarkIcon = Icons.schedule_rounded;
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
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: tileGradient,
              ),
              borderRadius: BorderRadius.circular(22),
              border:
                  isDark
                      ? Border.all(color: shadowColor.withAlpha(40), width: 1.5)
                      : null,
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withAlpha(isDark ? 50 : 80),
                  blurRadius: isDark ? 30 : 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // ── Massive translucent watermark icon ──
                Positioned(
                  bottom: -10,
                  right: -10,
                  child: Icon(
                    watermarkIcon,
                    size: 120,
                    color: Colors.white.withAlpha(25),
                  ),
                ),

                // ── Card Content ──
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withAlpha(30),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (status == 'in-progress')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '~15 min',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Service Name + Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  serviceName,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 14,
                                      color: Colors.white.withAlpha(180),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      patientName,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: Colors.white.withAlpha(180),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isClinic) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        isQueue
                                            ? Icons.people_rounded
                                            : Icons.calendar_today_rounded,
                                        size: 13,
                                        color: Colors.white.withAlpha(200),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          isQueue
                                              ? l10n.queueLabel
                                              : [
                                                if (scheduledDate != null)
                                                  () {
                                                    try {
                                                      return DateFormat(
                                                        'd MMM',
                                                      ).format(
                                                        DateTime.parse(
                                                          scheduledDate,
                                                        ),
                                                      );
                                                    } catch (_) {
                                                      return scheduledDate;
                                                    }
                                                  }(),
                                                if (scheduledTime != null)
                                                  scheduledTime,
                                              ].join(' · '),
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            color: Colors.white.withAlpha(200),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withAlpha(25),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${price.toStringAsFixed(0)} ${l10n.currencyEgp}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Provider Row
                      if (providerName != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withAlpha(25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    providerName[0],
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      providerName,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          isClinic
                                              ? Icons.info_outline_rounded
                                              : Icons.star,
                                          color:
                                              isClinic
                                                  ? Colors.white70
                                                  : const Color(0xFFF59E0B),
                                          size: 13,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            providerSub,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12,
                                              color: Colors.white.withAlpha(
                                                180,
                                              ),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    isClinic
                                        ? Icons.directions_rounded
                                        : Icons.phone_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Action Buttons
                      Row(
                        children: [
                          if (isClinic &&
                              (status == 'confirmed' ||
                                  status == 'in-progress' ||
                                  status == 'arrived' ||
                                  status == 'assigned')) ...[
                            Expanded(
                              child: _buildCardAction(
                                context: context,
                                label: l10n.viewTicket,
                                icon: Icons.qr_code_2_rounded,
                                isFilled: true,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => BookingTicketModal(
                                      serviceName: serviceName,
                                      patientName: patientName,
                                      clinicName: _clinicName(booking),
                                      clinicAddress: _clinicAddress(booking),
                                      doctorName: doctorName ?? '',
                                      scheduledTime: [
                                        if (scheduledDate != null)
                                          () {
                                            try {
                                              return DateFormat('d MMM').format(DateTime.parse(scheduledDate));
                                            } catch (_) {
                                              return scheduledDate;
                                            }
                                          }(),
                                        if (scheduledTime != null) scheduledTime,
                                      ].join(' · '),
                                      checkInPin: booking['visitPin'] ?? '----',
                                      onClose: () => Navigator.pop(ctx),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (!isClinic &&
                              (BookingUtils.isTrackableStatus(status) ||
                                  canResumeMatching))
                            Expanded(
                              child: _buildCardAction(
                                context: context,
                                label: l10n.track,
                                icon: Icons.location_on_rounded,
                                isFilled: true,
                                onTap: () {
                                  if (canResumeMatching) {
                                    // Extract coordinates safely
                                    double lat = 30.0444;
                                    double lon = 31.2357;
                                    final location =
                                        booking['location'] ??
                                        booking['locationGeo'];
                                    if (location is Map) {
                                      final coords = location['coordinates'];
                                      if (coords is List &&
                                          coords.length >= 2) {
                                        lon = (coords[0] as num).toDouble();
                                        lat = (coords[1] as num).toDouble();
                                      }
                                    } else if (booking['latitude'] != null &&
                                        booking['longitude'] != null) {
                                      lat =
                                          (booking['latitude'] as num)
                                              .toDouble();
                                      lon =
                                          (booking['longitude'] as num)
                                              .toDouble();
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => BookingMatchingScreen(
                                              matchingRequestId:
                                                  booking['_id'] ?? '',
                                              serviceName: serviceName,
                                              patientName: patientName,
                                              patientLatitude: lat,
                                              patientLongitude: lon,
                                            ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => BookingTrackingPage(
                                              booking: booking,
                                            ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          if (!isClinic &&
                              (BookingUtils.isTrackableStatus(status) ||
                                  canResumeMatching))
                            const SizedBox(width: 10),
                          Expanded(
                            child: _buildCardAction(
                              context: context,
                              label: l10n.cancel,
                              icon: Icons.close_rounded,
                              isFilled: false,
                              onTap: () => _handleCancelBooking(context),
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
        },
      ),
    );
  }

  Widget _buildCardAction({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isFilled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isFilled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border:
              isFilled
                  ? null
                  : Border.all(color: Colors.white.withAlpha(120), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isFilled ? const Color(0xFF2ECC71) : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isFilled ? const Color(0xFF1E293B) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCancelBooking(BuildContext context) {
    final isLate = BookingUtils.isLateCancel(booking['status']);
    final isMatchingRequest = booking['isMatchingRequest'] == true;

    showDialog(
      context: context,
      builder:
          (ctx) => BookingCancellationModal(
            isLateCancel: isLate,
            onConfirm: () {
              Navigator.pop(ctx);
              if (isMatchingRequest) {
                final requestId =
                    (booking['matchingRequestId'] ?? booking['id'] ?? '')
                        .toString();
                _performCancelMatchingRequest(context, requestId);
              } else {
                final bookingId =
                    (booking['_id'] ?? booking['id'] ?? '').toString();
                _performCancelBooking(context, bookingId);
              }
            },
            onCancel: () => Navigator.pop(ctx),
          ),
    );
  }

  Future<void> _performCancelBooking(
    BuildContext context,
    String bookingId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final apiService = ApiService();
      await apiService.put('/api/bookings/$bookingId/cancel', body: {});
      onRefresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(l10n.bookingCancelled),
              ],
            ),
            backgroundColor: const Color(0xFF2ECC71),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _performCancelMatchingRequest(
    BuildContext context,
    String requestId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (requestId.isEmpty) return;

    try {
      final apiService = ApiService();
      await apiService.put('/api/matching/request/$requestId/cancel', body: {});
      onRefresh();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n.matchingRequestCancelled),
            ],
          ),
          backgroundColor: const Color(0xFF2ECC71),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToCancelMatching)),
      );
    }
  }
}
