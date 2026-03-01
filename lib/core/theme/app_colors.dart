import 'package:flutter/material.dart';

class AppColors {
  // Light Text Colors

  static const Color primaryLightColor = Color(0xFF2196F3);
  static const Color accentLightColor = Color(0xFF03A9F4);
  static const Color secondaryLightColor = Color(0xFF03A9F4);

  // Dark Text Colors
  static const Color primaryDarkColor = Color(0xFF2196F3);
  static const Color accentDarkColor = Color(0xFF03A9F4);
  static const Color secondaryDarkColor = Color(0xFF03A9F4);

  // Background Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF121212);
  static const Color lightCardBackground = Color(0xFFF5F5F5);
  static const Color darkCardBackground = Color(0xFF1E1E1E);

  // Button Colors
  static const Color lightTextBtnColor = primaryLightColor;
  static const Color darkTextBtnColor = primaryDarkColor;

  // Surface Colors
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Text Colors
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF424242);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color status = Color(0xFF9174FF);

  // Task Status Colors
  static const Color taskPending = Color(0xFFFF9800);
  static const Color taskCompleted = Color(0xFF4CAF50);
  static const Color taskOverdue = Color(0xFFF44336);
  static const Color currentStreakDark = Color(0xFFFF6B35);
  static const Color currentStreak = Color(0xFFFF8C42);
  static const Color longestStreak = Color(0xFFFFD700);
  static const Color longestStreakDark = Color(0xFFFFA500);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLightColor, secondaryLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLightColor, secondaryLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static Color lightShadow = Colors.black.withOpacity(0.1);
  static Color darkShadow = Colors.black.withOpacity(0.3);

  // Border Colors
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color darkBorder = Color(0xFF424242);

  // Disabled Colors
  static Color disabledLight = Colors.grey.withOpacity(0.3);
  static Color disabledDark = Colors.grey.withOpacity(0.2);
}
