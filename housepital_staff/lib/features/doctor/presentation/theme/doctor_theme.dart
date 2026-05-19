import 'package:flutter/material.dart';

/// Centralized design tokens for the Doctor application.
///
/// All doctor‑scoped pages should import this file instead of
/// declaring their own `static const Color _bg = …` constants.
class DoctorTheme {
  DoctorTheme._();

  // ─── Brand Colors ───────────────────────────────────────────────
  static const Color primary       = Color(0xFF2664EC);
  static const Color primaryDark   = Color(0xFF1136A8);
  static const Color primaryDeep   = Color(0xFF091E7E);
  static const Color secondary     = Color(0xFF3498BB);

  // ─── Surfaces ───────────────────────────────────────────────────
  static const Color background    = Color(0xFFF4F8FF);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceDim    = Color(0xFFF8FBFF);

  // ─── Text ───────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint      = Color(0xFF94A3B8);

  // ─── Semantic ───────────────────────────────────────────────────
  static const Color success       = Color(0xFF16A34A);
  static const Color successLight  = Color(0xFFDCFCE7);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color warningLight  = Color(0xFFFEF3C7);
  static const Color danger        = Color(0xFFDC2626);
  static const Color dangerLight   = Color(0xFFFEE2E2);

  // ─── Borders ────────────────────────────────────────────────────
  static const Color border        = Color(0xFFD8E5FF);
  static const Color borderLight   = Color(0xFFDBEAFE);

  // ─── Gradients ──────────────────────────────────────────────────

  /// The hero / canopy header gradient used across all sub-pages.
  static const List<Color> heroGradient = [
    Color(0xFF1136A8),
    Color(0xFF2664EC),
    Color(0xFF3498BB),
  ];

  static const LinearGradient headerGradient = LinearGradient(
    colors: heroGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Wallet / premium gradient.
  static const List<Color> walletGradient = [
    Color(0xFF1746C0),
    Color(0xFF1E56D8),
    Color(0xFF2664EC),
  ];

  /// Blocked / danger gradient.
  static const List<Color> blockedGradient = [
    Color(0xFF8B1A1A),
    Color(0xFFB71C1C),
    Color(0xFFC62828),
  ];

  // ─── Shadows ────────────────────────────────────────────────────

  static List<BoxShadow> headerShadow = [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.24),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.06),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> softShadow = [
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

  /// Standard card box decoration.
  static BoxDecoration cardDecoration({Color? borderColor}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMD),
        border: Border.all(color: borderColor ?? border),
        boxShadow: cardShadow,
      );

  /// Glassmorphic overlay for elements on top of gradients.
  static BoxDecoration glassOverlay({double alpha = 0.18}) => BoxDecoration(
        color: Colors.white.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(radiusXS),
      );

  // ─── Input Decoration ───────────────────────────────────────────

  /// Consistent form‑field decoration used across all doctor pages.
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: surfaceDim,
      prefixIcon: Icon(icon, color: primaryDark),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusXS),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusXS),
        borderSide: const BorderSide(color: border),
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

  static const TextStyle headingLarge = TextStyle(
    color: textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  static const TextStyle headingMedium = TextStyle(
    color: textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  static const TextStyle headingSmall = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle titleMedium = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    color: textSecondary,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    color: textHint,
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
