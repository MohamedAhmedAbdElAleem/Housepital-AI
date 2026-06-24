import 'package:flutter/material.dart';
import '../theme/doctor_theme.dart';

/// Unified empty-state widget used across doctor pages.
///
/// Shows a gradient circle with an icon, a heading, and a subtitle.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconSize = 48,
    this.circleSize = 100,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double iconSize;
  final double circleSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    DoctorTheme.primary.withValues(alpha: 0.15),
                    DoctorTheme.secondary.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Icon(icon, size: iconSize, color: DoctorTheme.primary),
            ),
            SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: DoctorTheme.headingMedium(context),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: DoctorTheme.bodyMedium.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
