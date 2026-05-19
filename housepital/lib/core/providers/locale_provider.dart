import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  final String _prefKey = 'language_code';

  LocaleProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_prefKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    } else {
      // First app launch: Check device language
      final deviceLocale = ui.PlatformDispatcher.instance.locale;
      if (deviceLocale.languageCode == 'ar') {
        _locale = const Locale('ar');
      } else {
        _locale = const Locale('en');
      }
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'ar'].contains(locale.languageCode)) return;
    if (_locale == locale) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
    notifyListeners();
  }
}
