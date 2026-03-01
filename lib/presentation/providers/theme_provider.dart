import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  late SharedPreferences _prefs;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  // Initialize theme from storage
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(StorageKeys.themeMode);

    if (savedTheme != null) {
      _themeMode = _getThemeModeFromString(savedTheme);
      notifyListeners();
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _prefs.setString(StorageKeys.themeMode, _getStringFromThemeMode(mode));
    notifyListeners();
  }

  // Toggle between light and dark (useful for quick toggle)
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  // Set to system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  // Helper methods
  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  ThemeType get themeType {
    switch (_themeMode) {
      case ThemeMode.light:
        return ThemeType.light;
      case ThemeMode.dark:
        return ThemeType.dark;
      case ThemeMode.system:
      default:
        return ThemeType.system;
    }
  }
}