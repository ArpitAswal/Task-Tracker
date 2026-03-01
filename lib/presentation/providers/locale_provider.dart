import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  late SharedPreferences _prefs;

  Locale get locale => _locale;
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isHindi => _locale.languageCode == 'hi';

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('hi', ''), // Hindi
  ];

  // Initialize locale from storage
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedLocale = _prefs.getString(StorageKeys.locale);

      if (savedLocale != null) {
        _locale = Locale(savedLocale);
        notifyListeners();
      }
    } catch (e) {
      // Fall back to default locale on storage error
      debugPrint('LocaleProvider init failed: $e');
    }
  }

  // Set locale
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    if (_locale == locale) return;

    _locale = locale;
    await _prefs.setString(StorageKeys.locale, locale.languageCode);
    notifyListeners();
  }

  // Set English
  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }

  // Set Hindi
  Future<void> setHindi() async {
    await setLocale(const Locale('hi'));
  }

  // Toggle between English and Hindi
  Future<void> toggleLocale() async {
    if (_locale.languageCode == 'en') {
      await setHindi();
    } else {
      await setEnglish();
    }
  }

  // Get locale name for display
  String getLocaleName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी';
      default:
        return languageCode;
    }
  }

  String get currentLocaleName => getLocaleName(_locale.languageCode);
}
