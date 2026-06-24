import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _languageKey = 'app_language';

  LanguageCubit() : super(const Locale('en')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_languageKey);
    if (langCode != null) {
      emit(Locale(langCode));
    } else {
      // Default to system locale or 'en'
      emit(const Locale('en'));
    }
  }

  Future<void> setLanguage(String langCode) async {
    final locale = Locale(langCode);
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, langCode);
  }

  Future<void> toggleLanguage() async {
    final newLang = state.languageCode == 'en' ? 'ar' : 'en';
    await setLanguage(newLang);
  }

  bool get isArabic => state.languageCode == 'ar';
}
