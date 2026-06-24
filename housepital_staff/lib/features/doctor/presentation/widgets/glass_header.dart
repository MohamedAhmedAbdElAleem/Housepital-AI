import 'package:flutter/material.dart';
import '../theme/doctor_theme.dart';

/// Reusable gradient "Canopy Header" used across all doctor sub-pages.
///
/// Renders as a gradient card with back button, title, subtitle,
/// and an optional trailing action icon.
class GlassHeader extends StatelessWidget {
  const GlassHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.onAction,
    this.actionIcon,
    this.actionTooltip,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final String? actionTooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          gradient: DoctorTheme.headerGradient(context),
          borderRadius: BorderRadius.circular(DoctorTheme.radiusLG),
          boxShadow: DoctorTheme.headerShadow(context),
        ),
        child: Row(
          children: [
            // ── Back Button ──
            if (onBack != null)
              _GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack!,
                tooltip: 'Back',
              ),
            if (onBack != null) SizedBox(width: 12),

            // ── Title & Subtitle ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: DoctorTheme.headerTitle),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(subtitle!, style: DoctorTheme.headerSubtitle),
                  ],
                ],
              ),
            ),

            // ── Trailing Action ──
            if (onAction != null && actionIcon != null) ...[
              SizedBox(width: 8),
              _GlassIconButton(
                icon: actionIcon!,
                onTap: onAction!,
                tooltip: actionTooltip ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip = '',
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DoctorTheme.radiusXS),
          child: Ink(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(DoctorTheme.radiusXS),
            ),
            child: Icon(icon, color: DoctorTheme.surface(context), size: 20),
          ),
        ),
      ),
    );
  }
}
