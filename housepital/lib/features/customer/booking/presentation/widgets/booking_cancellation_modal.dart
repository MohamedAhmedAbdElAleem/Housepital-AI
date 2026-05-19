import 'package:flutter/material.dart';

class BookingCancellationModal extends StatelessWidget {
  final bool isLateCancel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const BookingCancellationModal({
    super.key,
    required this.isLateCancel,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF16151A) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B);
    final descColor = isDark ? const Color(0xFFA19EAB) : Colors.grey[600]!;
    final iconCircleBg = isDark ? const Color(0xFF2E1A1A) : const Color(0xFFFEE2E2);
    final feeBoxBg = isDark ? const Color(0xFF2C1F00) : const Color(0xFFFFF7ED);
    final feeBoxBorder = isDark ? const Color(0xFF4A3200) : const Color(0xFFFED7AA);
    final feeTextColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
    final goBtnFg = isDark ? const Color(0xFFA19EAB) : Colors.grey[700]!;
    final goBtnBorder = isDark ? const Color(0xFF2A2831) : Colors.grey[300]!;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconCircleBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                size: 32,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Cancel Booking?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              isLateCancel
                  ? 'Since the nurse is already assigned, a late cancellation fee of 50 EGP will apply.'
                  : 'Are you sure you want to cancel this booking? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: descColor,
                height: 1.5,
              ),
            ),

            // Fee warning for late cancel
            if (isLateCancel) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feeBoxBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: feeBoxBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Late Cancellation Fee: 50 EGP',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: feeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: goBtnFg,
                      side: BorderSide(color: goBtnBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Go Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      isLateCancel ? 'Cancel & Pay Fee' : 'Yes, Cancel',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
