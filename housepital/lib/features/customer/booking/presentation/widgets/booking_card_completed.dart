import 'package:flutter/material.dart';

class BookingCardCompleted extends StatelessWidget {
  final String serviceName;
  final String patientName;
  final String providerName;
  final String completedDate;
  final double price;
  final VoidCallback onRebook;
  final VoidCallback onRate;

  const BookingCardCompleted({
    super.key,
    required this.serviceName,
    required this.patientName,
    required this.providerName,
    required this.completedDate,
    required this.price,
    required this.onRebook,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF16151A) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF2A2831) : const Color(0xFFE2E8F0);
    final headerBg = isDark ? const Color(0xFF1E1C24) : const Color(0xFFF8FAFC);
    final headerBorder = isDark ? const Color(0xFF2A2831) : const Color(0xFFE2E8F0);
    final primaryText = isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B);
    final mutedText = isDark ? const Color(0xFFA19EAB) : Colors.grey[600]!;
    final mutedIcon = isDark ? const Color(0xFF5F5C68) : Colors.grey[500]!;
    final iconBg = isDark ? const Color(0xFF1E1C24) : Colors.grey[100]!;
    final iconColor = isDark ? const Color(0xFF5F5C68) : Colors.grey[400]!;
    final infoBoxBg = isDark ? const Color(0xFF1E1C24) : const Color(0xFFF8FAFC);
    final rateBg = isDark ? const Color(0xFF2C2000) : const Color(0xFFFFF8E1);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: headerBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                Text(
                  completedDate,
                  style: TextStyle(fontSize: 12, color: mutedText),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medical_services,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: mutedIcon,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                patientName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: mutedText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${price.toStringAsFixed(0)} EGP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: infoBoxBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: mutedIcon),
                      const SizedBox(width: 8),
                      Text(
                        'Served by: $providerName',
                        style: TextStyle(fontSize: 12, color: mutedText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRebook,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF17C47F),
                          side: const BorderSide(color: Color(0xFF17C47F)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Rebook'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onRate,
                        icon: const Icon(Icons.star, size: 16),
                        label: const Text('Rate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rateBg,
                          foregroundColor: const Color(0xFFF59E0B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
