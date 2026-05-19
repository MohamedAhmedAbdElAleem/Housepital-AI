import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NursingServiceCard extends StatelessWidget {
  final String title;
  final String category;
  final String duration;
  final double rating;
  final int reviewCount;
  final int price;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const NursingServiceCard({
    super.key,
    required this.title,
    required this.category,
    required this.duration,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A202C);
    final textMuted = isDark ? const Color(0xFFA19EAB) : const Color(0xFFA0AEC0);
    final cardBg = isDark ? const Color(0xFF16151A) : Colors.white;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 140, // Fixed height for a sleek horizontal look
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: iconColor.withAlpha(20), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Large blurred background icon for extreme premium feel
              Positioned(
                right: -40,
                top: -20,
                child: Icon(
                  icon,
                  size: 180,
                  color: iconColor.withAlpha(8), // Very subtle
                ),
              ),
              
              Row(
                children: [
                  // Left side color block + Icon
                  Container(
                    width: 100,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          iconColor.withAlpha(40),
                          iconColor.withAlpha(10),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withAlpha(30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: iconColor, size: 28),
                      ),
                    ),
                  ),

                  // Right side Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top row: Title and Category
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: iconColor.withAlpha(15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: iconColor.withAlpha(30)),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Bottom row: Metrics and Price
                          Row(
                            children: [
                              // Metrics
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.schedule_rounded, size: 14, color: textMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                          duration,
                                          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textMuted, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
                                        const SizedBox(width: 4),
                                        Text(
                                          rating.toString(),
                                          style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary),
                                        ),
                                        Text(
                                          ' ($reviewCount)',
                                          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textMuted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Price Tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white : textPrimary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      price.toString(),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? const Color(0xFF1A202C) : Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'EGP',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: (isDark ? const Color(0xFF1A202C) : Colors.white).withAlpha(200),
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
