import 'package:flutter/material.dart';

class AppColors {
  // 🟢 Primary Palette (Healing Green)
  static const Color primary50 = Color(0xFFEAFAF1);
  static const Color primary100 = Color(0xFFBEEFD3);
  static const Color primary200 = Color(0xFF9FE8BE);
  static const Color primary300 = Color(0xFF73DDA0);
  static const Color primary400 = Color(0xFF58D68D);
  static const Color primary500 = Color(0xFF2ECC71);
  static const Color primary600 = Color(0xFF2ABA67);
  static const Color primary700 = Color(0xFF219150);
  static const Color primary800 = Color(0xFF19703E);
  static const Color primary900 = Color(0xFF13562F);

  // Primary Default
  static const Color primary = primary500;
  static const Color primaryDark = primary700;
  static const Color primaryLight = primary300;

  // 🔵 Secondary Palette (Trust Blue)
  static const Color secondary50 = Color(0xFFEBF5F8);
  static const Color secondary100 = Color(0xFFC0DFEA);
  static const Color secondary200 = Color(0xFFA2D0E0);
  static const Color secondary300 = Color(0xFF77BAD1);
  static const Color secondary400 = Color(0xFF5DADC9);
  static const Color secondary500 = Color(0xFF3498BB);
  static const Color secondary600 = Color(0xFF2F8AAA);
  static const Color secondary700 = Color(0xFF256C85);
  static const Color secondary800 = Color(0xFF1D5467);
  static const Color secondary900 = Color(0xFF16404F);

  // Secondary Default
  static const Color secondary = secondary500;
  static const Color secondaryDark = secondary700;
  static const Color secondaryLight = secondary300;

  // ⚪ Light Background Palette
  static const Color light50 = Color(0xFFFDFDFD);
  static const Color light100 = Color(0xFFF9F9F9);
  static const Color light200 = Color(0xFFF6F6F6);
  static const Color light300 = Color(0xFFF2F2F2);
  static const Color light400 = Color(0xFFEFEFEF);
  static const Color light500 = Color(0xFFEBEBEB);
  static const Color light600 = Color(0xFFD6D6D6);
  static const Color light700 = Color(0xFFA7A7A7);
  static const Color light800 = Color(0xFF818181);
  static const Color light900 = Color(0xFF636363);

  // ⚫ Dark Background Palette
  static const Color dark50 = Color(0xFFE9E9E9);
  static const Color dark100 = Color(0xFFBBBBBB);
  static const Color dark200 = Color(0xFF9A9A9A);
  static const Color dark300 = Color(0xFF6C6C6C);
  static const Color dark400 = Color(0xFF4F4F4F);
  static const Color dark500 = Color(0xFF232323);
  static const Color dark600 = Color(0xFF202020);
  static const Color dark700 = Color(0xFF191919);
  static const Color dark800 = Color(0xFF131313);
  static const Color dark900 = Color(0xFF0F0F0F);

  // ❌ Error Palette (Alert Red)
  static const Color error50 = Color(0xFFFEECEB);
  static const Color error100 = Color(0xFFFCC5C1);
  static const Color error200 = Color(0xFFFAA9A3);
  static const Color error300 = Color(0xFFF88178);
  static const Color error400 = Color(0xFFF6695E);
  static const Color error500 = Color(0xFFF44336);
  static const Color error600 = Color(0xFFDE3D31);
  static const Color error700 = Color(0xFFAD3026);
  static const Color error800 = Color(0xFF86251E);
  static const Color error900 = Color(0xFF661C17);

  // ✅ Success Palette (Medical Green)
  static const Color success50 = Color(0xFFECF6ED);
  static const Color success100 = Color(0xFFC5E2C6);
  static const Color success200 = Color(0xFFA9D3AB);
  static const Color success300 = Color(0xFF81BF84);
  static const Color success400 = Color(0xFF69B36D);
  static const Color success500 = Color(0xFF43A048);
  static const Color success600 = Color(0xFF3D9242);
  static const Color success700 = Color(0xFF307233);
  static const Color success800 = Color(0xFF255828);
  static const Color success900 = Color(0xFF1C431E);

  // ⚠️ Warning Palette (Medical Orange)
  static const Color warning50 = Color(0xFFFFF3E6);
  static const Color warning100 = Color(0xFFFEDBB0);
  static const Color warning200 = Color(0xFFFDC98A);
  static const Color warning300 = Color(0xFFFCB154);
  static const Color warning400 = Color(0xFFFCA133);
  static const Color warning500 = Color(0xFFFB8A00);
  static const Color warning600 = Color(0xFFE47E00);
  static const Color warning700 = Color(0xFFB26200);
  static const Color warning800 = Color(0xFF8A4C00);
  static const Color warning900 = Color(0xFF693A00);

  // ℹ️ Info Palette (Blue)
  static const Color info50 = Color(0xFFE3F2FD);
  static const Color info100 = Color(0xFFBBDEFB);
  static const Color info200 = Color(0xFF90CAF9);
  static const Color info300 = Color(0xFF64B5F6);
  static const Color info400 = Color(0xFF42A5F5);
  static const Color info500 = Color(0xFF2196F3);
  static const Color info600 = Color(0xFF1E88E5);
  static const Color info700 = Color(0xFF1976D2);
  static const Color info800 = Color(0xFF1565C0);
  static const Color info900 = Color(0xFF0D47A1);

  // Common Defaults
  static const Color background = light100;
  static const Color surface = light50;
  static const Color error = error500;
  static const Color success = success500;
  static const Color warning = warning500;
  static const Color info = secondary500;

  // Text Colors
  static const Color textPrimary = dark500;
  static const Color textSecondary = dark300;
  static const Color textHint = light700;
  static const Color textOnPrimary = light50;
  static const Color textOnSecondary = light50;

  // Role Colors (using branding colors)
  static const Color customerColor = secondary500;
  static const Color nurseColor = primary500;
  static const Color doctorColor = primary700;
  static const Color adminColor = warning600;
}
