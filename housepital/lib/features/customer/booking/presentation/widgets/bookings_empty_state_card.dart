import 'package:flutter/material.dart';

class BookingsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showAction;
  final VoidCallback? onAction;

  const BookingsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showAction,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Gradient icon circle ──
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2ECC71).withAlpha(25),
                    const Color(0xFF3498BB).withAlpha(20),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF2ECC71).withAlpha(40),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: const Color(0xFF2ECC71),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: isDark ? const Color(0xFFA19EAB) : const Color(0xFF94A3B8),
              ),
            ),
            if (showAction) ...[
              const SizedBox(height: 28),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2ECC71), Color(0xFF219150)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2ECC71).withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Book a Service',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
