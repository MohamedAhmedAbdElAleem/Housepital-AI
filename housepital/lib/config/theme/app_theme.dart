import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppTheme {
  // Typography
  static const String fontFamilyPrimary = 'Poppins';
  static const String fontFamilySecondary = 'Inter';

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamilyPrimary,

    // Color Scheme
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary500,
      primaryContainer: AppColors.primary100,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.secondary500,
      secondaryContainer: AppColors.secondary100,
      onSecondary: AppColors.textOnSecondary,
      error: AppColors.error500,
      errorContainer: AppColors.error100,
      onError: AppColors.light50,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.light200,
      outline: AppColors.light600,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary500,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary500,
        side: const BorderSide(color: AppColors.primary500, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary500,
        textStyle: const TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.light600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.light600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error500),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error500, width: 2),
      ),
      labelStyle: const TextStyle(
        fontFamily: fontFamilySecondary,
        color: AppColors.textSecondary,
      ),
      hintStyle: const TextStyle(
        fontFamily: fontFamilySecondary,
        color: AppColors.textHint,
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: 2,
      color: AppColors.surface,
      shadowColor: AppColors.dark300.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary500,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: fontFamilySecondary,
        fontSize: 12,
      ),
      type: BottomNavigationBarType.fixed,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary500,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.light500,
      thickness: 1,
      space: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.light200,
      selectedColor: AppColors.primary100,
      labelStyle: const TextStyle(
        fontFamily: fontFamilySecondary,
        color: AppColors.textPrimary,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: fontFamilySecondary,
        color: AppColors.primary700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // Dark Theme (Optional - can be implemented later)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamilyPrimary,
    brightness: Brightness.dark,
    // TODO: Implement dark theme using dark palette
  );
}
