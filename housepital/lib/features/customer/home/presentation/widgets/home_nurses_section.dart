import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NurseItem {
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final bool isAvailable;
  final Color color;

  const NurseItem({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.isAvailable,
    required this.color,
  });
}

class HomeNursesSection extends StatelessWidget {
  HomeNursesSection({super.key});

  final List<NurseItem> _nurses = [
    const NurseItem(
      name: 'Sarah Ahmed',
      specialty: 'Wound Care',
      rating: 4.9,
      reviews: 127,
      isAvailable: true,
      color: Color(0xFF00C853), // Healing Green
    ),
    const NurseItem(
      name: 'Fatima Hassan',
      specialty: 'Elderly Care',
      rating: 4.8,
      reviews: 98,
      isAvailable: true,
      color: Color(0xFF3498BB), // Trust Blue
    ),
    const NurseItem(
      name: 'Mona Ibrahim',
      specialty: 'IV Therapy',
      rating: 4.9,
      reviews: 156,
      isAvailable: false,
      color: Color(0xFF2196F3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Nurses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              GestureDetector(
                onTap: () => HapticFeedback.selectionClick(),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: _nurses.length,
            itemBuilder: (context, index) => _buildNurseCard(context, _nurses[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildNurseCard(BuildContext context, NurseItem nurse, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          width: 130,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: nurse.color.withAlpha(isDark ? 20 : 30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: isDark ? Border.all(color: theme.dividerColor.withAlpha(40)) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [nurse.color, nurse.color.withAlpha(150)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.surface,
                      child: Icon(
                        Icons.person_rounded,
                        color: nurse.color,
                        size: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: nurse.isAvailable ? theme.colorScheme.primary : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                nurse.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Specialty
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: nurse.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  nurse.specialty,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: isDark ? nurse.color.withAlpha(200) : nurse.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),

              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC107),
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${nurse.rating}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    ' (${nurse.reviews})',
                    style: TextStyle(
                      fontSize: 9, 
                      color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Book button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: nurse.isAvailable 
                      ? nurse.color.withAlpha(isDark ? 40 : 25) 
                      : theme.dividerColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nurse.isAvailable ? 'Book' : 'Busy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: nurse.isAvailable 
                        ? (isDark ? nurse.color.withAlpha(220) : nurse.color) 
                        : theme.textTheme.bodyMedium?.color?.withAlpha(150),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
