import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Base Text Style
  static const String fontFamily = 'Poppins';

  // Light Theme Text Styles
  static TextTheme lightTextTheme = const TextTheme(
    //display for headings like app name with primary & secondary color
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryLightColor,
      fontFamily: fontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryLightColor,
      fontFamily: fontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryLightColor,
      fontFamily: fontFamily,
    ),
    //headline for app description or app bar title with primary & secondary text color
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      fontFamily: fontFamily,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      fontFamily: fontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.lightTextSecondary,
      fontFamily: fontFamily,
    ),
    // title for buttons text and section heading with different text colors
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryLightColor,
      fontFamily: fontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      fontFamily: fontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      fontFamily: fontFamily,
    ),
    // body for general text with primary & secondary text colors
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextPrimary,
      fontFamily: fontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextPrimary,
      fontFamily: fontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextSecondary,
      fontFamily: fontFamily,
    ),
    //label for section text with primary & secondary text colors
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextSecondary,
      fontFamily: fontFamily,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextPrimary,
      fontFamily: fontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextSecondary,
      fontFamily: fontFamily,
    ),
  );

  // Dark Theme Text Styles
  static TextTheme darkTextTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryDarkColor,
      fontFamily: fontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryDarkColor,
      fontFamily: fontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryDarkColor,
      fontFamily: fontFamily,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      fontFamily: fontFamily,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      fontFamily: fontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.darkTextSecondary,
      fontFamily: fontFamily,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryDarkColor,
      fontFamily: fontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      fontFamily: fontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.darkTextPrimary,
      fontFamily: fontFamily,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextPrimary,
      fontFamily: fontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextPrimary,
      fontFamily: fontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextSecondary,
      fontFamily: fontFamily,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextSecondary,
      fontFamily: fontFamily,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextPrimary,
      fontFamily: fontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextSecondary,
      fontFamily: fontFamily,
    ),
  );
}
