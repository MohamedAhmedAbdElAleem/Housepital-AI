import 'package:flutter/material.dart';
import '../theme/doctor_theme.dart';

/// Reusable surface card with soft shadow, optional border accent, and
/// optional gradient accent strip on the left edge.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = EdgeInsets.all(16),
    this.hasBorder = true,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final bool hasBorder;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
        borderRadius: BorderRadius.circular(DoctorTheme.radiusMD),
        border: hasBorder
            ? Border.all(color: borderColor ?? DoctorTheme.border(context))
            : null,
        boxShadow: DoctorTheme.cardShadow(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Optional left accent strip.
          if (accentColor != null)
            Container(width: 4, color: accentColor),

          // Card content.
          Expanded(
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DoctorTheme.radiusMD),
          child: card,
        ),
      );
    }

    return card;
  }
}
