import 'package:flutter/material.dart';

/// Centralized design tokens for the Doctor application.
///
/// All doctor‑scoped pages should import this file instead of
/// declaring their own `static const Color _bg = …` constants.
class DoctorTheme {
  DoctorTheme._();

  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  // ─── Brand Colors ───────────────────────────────────────────────
  static const Color primary       = Color(0xFF2ECC71); // Updated to Healing Green for Dark Mode support
  static const Color primaryDark   = Color(0xFF27AE60);
  static const Color primaryDeep   = Color(0xFF1E8449);
  static const Color secondary     = Color(0xFF3498BB);

  // ─── Surfaces ───────────────────────────────────────────────────
  static Color background(BuildContext context) => isDark(context) ? const Color(0xFF0D0C11) : const Color(0xFFF4F8FF);
  static Color surface(BuildContext context) => isDark(context) ? const Color(0xFF16151A) : const Color(0xFFFFFFFF);
  static Color surfaceDim(BuildContext context) => isDark(context) ? const Color(0xFF1E1C24) : const Color(0xFFF8FBFF);

  // ─── Text ───────────────────────────────────────────────────────
  static Color textPrimary(BuildContext context) => isDark(context) ? const Color(0xFFF2F2F5) : const Color(0xFF0F172A);
  static Color textSecondary(BuildContext context) => isDark(context) ? const Color(0xFFA19EAB) : const Color(0xFF475569);
  static Color textHint(BuildContext context) => isDark(context) ? const Color(0xFF5F5C68) : const Color(0xFF94A3B8);

  // ─── Semantic ───────────────────────────────────────────────────
  static const Color success       = Color(0xFF16A34A);
  static const Color successLight  = Color(0xFFDCFCE7);
  static const Color warning       = Color(0xFFE67E22); // From guide
  static const Color warningLight  = Color(0xFFFEF3C7);
  static const Color danger        = Color(0xFFE74C3C); // From guide
  static const Color dangerLight   = Color(0xFFFEE2E2);

  // ─── Borders ────────────────────────────────────────────────────
  static Color border(BuildContext context) => isDark(context) ? const Color(0xFF2A2831) : const Color(0xFFD8E5FF);
  static Color borderLight(BuildContext context) => isDark(context) ? const Color(0xFF2A2831) : const Color(0xFFDBEAFE);

  // ─── Gradients ──────────────────────────────────────────────────

  static List<Color> heroGradient(BuildContext context) => isDark(context) ? [
    const Color(0xFF16151A),
    const Color(0xFF16151A),
  ] : [
    const Color(0xFF1136A8),
    const Color(0xFF2664EC),
    const Color(0xFF3498BB),
  ];

  static LinearGradient headerGradient(BuildContext context) => LinearGradient(
    colors: heroGradient(context),
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<Color> walletGradient(BuildContext context) => isDark(context) ? [
    const Color(0xFF1E1C24),
    const Color(0xFF16151A),
  ] : [
    const Color(0xFF1746C0),
    const Color(0xFF1E56D8),
    const Color(0xFF2664EC),
  ];

  static List<Color> blockedGradient(BuildContext context) => [
    const Color(0xFF8B1A1A),
    const Color(0xFFB71C1C),
    const Color(0xFFC62828),
  ];

  // ─── Shadows ────────────────────────────────────────────────────

  static List<BoxShadow> headerShadow(BuildContext context) => isDark(context) ? [] : [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.24),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> cardShadow(BuildContext context) => isDark(context) ? [] : [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.06),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> softShadow(BuildContext context) => isDark(context) ? [] : [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Radii ──────────────────────────────────────────────────────
  static const double radiusXL  = 28.0;
  static const double radiusLG  = 24.0;
  static const double radiusMD  = 20.0;
  static const double radiusSM  = 16.0;
  static const double radiusXS  = 12.0;
  static const double radiusChip = 10.0;

  // ─── Shared Decorations ─────────────────────────────────────────

  static BoxDecoration cardDecoration(BuildContext context, {Color? borderColor}) => BoxDecoration(
        color: surface(context),
        borderRadius: BorderRadius.circular(radiusMD),
        border: Border.all(color: borderColor ?? border(context)),
        boxShadow: cardShadow(context),
      );

  static BoxDecoration glassOverlay({double alpha = 0.18}) => BoxDecoration(
        color: Colors.white.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(radiusXS),
      );

  // ─── Input Decoration ───────────────────────────────────────────

  static InputDecoration inputDecoration(BuildContext context, {
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: surfaceDim(context),
      prefixIcon: Icon(icon, color: primary),
      labelStyle: TextStyle(color: textSecondary(context)),
      hintStyle: TextStyle(color: textHint(context)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusXS),
        borderSide: BorderSide(color: border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusXS),
        borderSide: BorderSide(color: border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusXS),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusXS),
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusXS),
        borderSide: const BorderSide(color: danger, width: 1.4),
      ),
    );
  }

  // ─── Text Styles ────────────────────────────────────────────────

  static TextStyle headingLarge(BuildContext context) => TextStyle(
    color: textPrimary(context),
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  static TextStyle headingMedium(BuildContext context) => TextStyle(
    color: textPrimary(context),
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  static TextStyle headingSmall(BuildContext context) => TextStyle(
    color: textPrimary(context),
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
    color: textPrimary(context),
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    color: textSecondary(context),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    color: textSecondary(context),
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    color: textHint(context),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ─── Header Text Styles (white on gradient) ─────────────────────

  static const TextStyle headerTitle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle headerSubtitle = TextStyle(
    color: Colors.white70,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
