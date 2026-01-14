import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../core/network/api_service.dart';

class CustomerBookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> booking;

  const CustomerBookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final serviceName = booking['serviceName'] ?? 'Service';
    final patientName = booking['patientName'] ?? 'Patient';
    final status = booking['status'] ?? 'pending';
    final price = (booking['servicePrice'] ?? 0).toDouble();
    final scheduledDate = booking['scheduledDate'];
    final scheduledTime = booking['scheduledTime'];
    final visitPin = booking['visitPin'];
    final type = booking['type'] ?? 'home_nursing';
    final isClinic = type == 'clinic_appointment';
    final bookingId = booking['_id'] ?? booking['id'] ?? '';

    String dateStr = 'Not scheduled';
    if (scheduledDate != null) {
      try {
        final date = DateTime.parse(scheduledDate);
        dateStr = DateFormat('EEEE, MMMM d, yyyy').format(date);
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: const Color(0xFF00D47F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getStatusColors(status),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStatusText(status),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isClinic ? 'Clinic Appointment' : 'Home Nursing Visit',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // QR Code & PIN (only for confirmed bookings)
            if (status == 'confirmed' && visitPin != null) ...[
              _buildSection(
                title: 'Check-in Code',
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: QrImageView(
                        data: '$bookingId:$visitPin',
                        version: QrVersions.auto,
                        size: 180.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your PIN Code',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D47F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00D47F)),
                      ),
                      child: Text(
                        visitPin,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: Color(0xFF00D47F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Show this to the doctor when you arrive',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Service Info
            _buildSection(
              title: 'Service',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Patient: $patientName',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    '${price.toStringAsFixed(0)} EGP',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00D47F),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Date & Time
            _buildSection(
              title: 'Date & Time',
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF00D47F)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (scheduledTime != null)
                        Text(
                          scheduledTime,
                          style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  List<Color> _getStatusColors(String status) {
    switch (status) {
      case 'confirmed':
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case 'completed':
        return [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
      case 'cancelled':
        return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case 'checked-in':
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      default:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'checked-in':
        return Icons.how_to_reg_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'checked-in':
        return 'Checked In';
      case 'pending':
        return 'Pending Confirmation';
      default:
        return status.replaceAll('-', ' ').toUpperCase();
    }
  }
}
