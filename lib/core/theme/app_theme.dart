import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLightColor,
      secondary: AppColors.accentLightColor,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.error,
      onPrimary: AppColors.black,
      onSecondary: AppColors.white,
      onSurface: AppColors.lightTextPrimary,
      onBackground: AppColors.lightTextPrimary,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLightColor,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    textTheme: AppTextStyles.lightTextTheme,

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryLightColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
      hintStyle: TextStyle(
        color: AppColors.lightTextSecondary.withOpacity(0.6),
      ),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLightColor,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: AppTextStyles.lightTextTheme.titleMedium,
      ),
    ),

    // Outline Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryLightColor,
        padding: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: const BorderSide(color: AppColors.primaryLightColor),
        textStyle: AppTextStyles.darkTextTheme.titleMedium,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightTextBtnColor,
        textStyle: AppTextStyles.lightTextTheme.titleMedium,
        padding: EdgeInsets.zero,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.lightCardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryLightColor;
        }
        return AppColors.white;
      }),
      checkColor: MaterialStateProperty.all(AppColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.lightTextPrimary, size: 24),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 1,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLightColor,
      secondary: AppColors.accentLightColor,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.greyLight,
      onSurface: AppColors.darkTextPrimary,
      onBackground: AppColors.darkTextPrimary,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    textTheme: AppTextStyles.darkTextTheme,

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryLightColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
      hintStyle: TextStyle(color: AppColors.darkTextSecondary.withOpacity(0.6)),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDarkColor,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: AppTextStyles.darkTextTheme.titleMedium,
      ),
    ),

    // Outline Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryDarkColor,
        padding: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: const BorderSide(color: AppColors.primaryDarkColor),
        textStyle: AppTextStyles.darkTextTheme.titleMedium,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkTextBtnColor,
        textStyle: AppTextStyles.lightTextTheme.titleMedium,
        padding: EdgeInsets.zero
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.darkCardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryLightColor;
        }
        return AppColors.darkSurface;
      }),
      checkColor: MaterialStateProperty.all(AppColors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 24),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),
  );
}
