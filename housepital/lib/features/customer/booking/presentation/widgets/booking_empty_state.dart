import 'package:flutter/material.dart';

class BookingEmptyState extends StatelessWidget {
  final bool isHistory;

  const BookingEmptyState({super.key, required this.isHistory});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(10) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isHistory ? Icons.history : Icons.calendar_today,
                size: 48,
                color: isDark ? Colors.white.withAlpha(50) : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isHistory ? 'No Booking History' : 'No Active Bookings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isHistory
                  ? 'Your completed and cancelled bookings will appear here.'
                  : 'You don\'t have any active or upcoming bookings. Book a service to get started!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFA19EAB) : Colors.grey[600],
                height: 1.5,
              ),
            ),
            if (!isHistory) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Go back to home to book
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Book Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17C47F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
