import 'dart:math';

import 'package:flutter/material.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';

import '../constants/app_constants.dart';

class Validators {
  // Email Validator
  static String? validateEmail(String? value, {String? errorMessage, BuildContext? context}) {
    if (value == null || value.trim().isEmpty) {
      if(context != null){
        return AppLocalizations.of(context)!.emailRequired;
      }
      return errorMessage ?? 'Email is required';
    }

    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value.trim())) {
      if (context != null) {
        return AppLocalizations.of(context)!.invalidEmail;
      }
      return 'Please enter a valid email';
    }

    return null;
  }

  // Password Validator
  static String? validatePassword(String? value, {String? errorMessage, BuildContext? context}) {
    if (value == null || value.isEmpty) {
      if (context != null) {
        return AppLocalizations.of(context)!.passwordRequired;
      }
      return errorMessage ?? 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      if (context != null) {
        return AppLocalizations.of(context)!.passwordMinLength;
      }
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      if (context != null) {
        return AppLocalizations.of(context)!.passwordMaxLength;
      }
      return 'Password must not exceed ${AppConstants.maxPasswordLength} characters';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      if (context != null) {
        return AppLocalizations.of(context)!.passwordOneNumber;
      }
      return 'Add at least one number or special character';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      if (context != null) {
        return AppLocalizations.of(context)!.passwordOneUppercase;
      }
      return 'Add at least one uppercase letter';
    }
    return null;
  }

  // Required Field Validator
  static String? validateRequired(String? value, {String? fieldName, BuildContext? context}) {
    if (value == null || value.trim().isEmpty) {
      // return '${fieldName ?? 'This field'} is required';
      if (context != null) {
        return AppLocalizations.of(context)!.fieldRequired;
      }
      return 'This field is required';
    }
    return null;
  }

  // Name Validator
  static String? validateName(String? value, {String? fieldName, BuildContext? context}) {
    if (value == null || value.trim().isEmpty) {
      if (context != null) {
        return AppLocalizations.of(context)!.translate('name_required');
      }
      // return '${fieldName ?? 'Name'} is required';
      return 'Name is required';
    }

    if (value.trim().length < 3) {
      if (context != null) {
        return AppLocalizations.of(context)!.translate('name_short');
      }
      // return '${fieldName ?? 'Name'} must be at least 3 characters';
      return 'Name must be at least 3 characters';
    }

    if (value.trim().length > 30) {
      if (context != null) {
        return AppLocalizations.of(context)!.translate('name_long');
      }
      // return '${fieldName ?? 'Name'} must not exceed 30 characters';
      return 'Name must not exceed 30 characters';
    }

    // Only allow letters, spaces, and basic punctuation
    final nameRegex = RegExp(r"^[a-zA-Z\s\-.']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      if (context != null) {
        return AppLocalizations.of(context)!.translate('name_invalid');
      }
      // return '${fieldName ?? 'Name'} contains invalid characters';
      return 'Name contains invalid characters';
    }

    return null;
  }

  // Phone Number Validator
  static String? validatePhoneNumber(String? value, {BuildContext? context}) {
    if (value == null || value.trim().isEmpty) {
      if (context != null) {
        return AppLocalizations.of(context)!.phoneRequired;
      }
      return 'Phone number is required';
    }

    // Remove spaces and dashes
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-]'), '');

    // Check if it's a valid phone number (10 digits for India)
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(cleanNumber)) {
      if (context != null) {
        return AppLocalizations.of(context)!.validNumber;
      }
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  // Date Validator
  static String? validateDate(DateTime? date, {String? errorMessage, BuildContext? context }) {
    if (date == null) {
      if (context != null) {
        return AppLocalizations.of(context)!.translate('date_required');
      }
      return errorMessage ?? 'Date is required';
    }
    return null;
  }

  // Date Range Validator
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Both dates are required';
    }

    if (endDate.isBefore(startDate)) {
      return 'End date must be after start date';
    }

    return null;
  }
}
