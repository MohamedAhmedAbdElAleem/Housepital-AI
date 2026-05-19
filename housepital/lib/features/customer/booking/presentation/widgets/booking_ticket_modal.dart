import 'package:flutter/material.dart';

class BookingTicketModal extends StatelessWidget {
  final String serviceName;
  final String patientName;
  final String clinicName;
  final String clinicAddress;
  final String doctorName;
  final String scheduledTime;
  final String checkInPin;
  final VoidCallback onClose;

  const BookingTicketModal({
    super.key,
    required this.serviceName,
    required this.patientName,
    required this.clinicName,
    required this.clinicAddress,
    required this.doctorName,
    required this.scheduledTime,
    required this.checkInPin,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF16151A) : Colors.white;
    final qrBoxBg = isDark ? const Color(0xFF1E1C24) : Colors.grey[200]!;
    final qrBoxBorder = isDark ? const Color(0xFF2A2831) : Colors.grey[300]!;
    final qrIconColor = isDark ? const Color(0xFF5F5C68) : Colors.grey[600]!;
    final qrTextColor = isDark ? const Color(0xFFA19EAB) : Colors.grey[600]!;
    final instructionBg = isDark ? const Color(0xFF1A2E1A) : const Color(0xFFF0FDF4);
    final instructionBorder = isDark ? const Color(0xFF2A4A2A) : const Color(0xFFBBF7D0);
    final instructionIconColor = const Color(0xFF16A34A);
    final instructionTextColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534);

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Digital Ticket',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF16151A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // QR Code placeholder
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: qrBoxBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: qrBoxBorder),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_2,
                                  size: 80,
                                  color: qrIconColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Scan at reception',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: qrTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Check-in PIN',
                            style: TextStyle(
                              fontSize: 12,
                              color: qrTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            checkInPin,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B),
                              letterSpacing: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Ticket details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow('Service', serviceName, isDark),
                    const SizedBox(height: 12),
                    _buildDetailRow('Patient', patientName, isDark),
                    const SizedBox(height: 12),
                    _buildDetailRow('Clinic', clinicName, isDark),
                    if (clinicAddress.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow('Address', clinicAddress, isDark),
                    ],
                    const SizedBox(height: 12),
                    _buildDetailRow('Doctor', doctorName, isDark),
                    const SizedBox(height: 12),
                    _buildDetailRow('Time', scheduledTime, isDark),

                    const SizedBox(height: 20),

                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: instructionBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: instructionBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: instructionIconColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Show this QR code or PIN at the clinic reception to check in.',
                              style: TextStyle(
                                fontSize: 12,
                                color: instructionTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFFA19EAB) : Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
