import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ✨ NEW: Global loading overlay that blocks user interaction
///
/// Shows a centered loading indicator with a semi-transparent background
/// Usage:
/// ```dart
/// // Show loading
/// LoadingOverlay.show(context);
///
/// // Hide loading
/// LoadingOverlay.hide(context);
///
/// // Or wrap async operation
/// await LoadingOverlay.wrap(
///   context,
///   future: someAsyncOperation(),
/// );
/// ```
class LoadingOverlay {
  // Keep track of overlay entry to remove it later
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// Show the loading overlay
  ///
  /// [overlay] - OverlayState to insert the loading widget into
  /// [message] - Optional loading message (default: "Loading...")
  static void show(OverlayState overlay, {String? message}) {
    // Prevent showing multiple overlays
    if (_isShowing) return;

    _isShowing = true;

    // Create overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingOverlayWidget(message: message),
    );

    // Insert overlay into the overlay stack
    overlay.insert(_overlayEntry!);
  }

  /// Hide the loading overlay
  ///
  /// No context needed — the entry removes itself from whichever overlay it
  /// was inserted into.
  static void hide() {
    if (!_isShowing || _overlayEntry == null) return;

    try {
      _overlayEntry?.remove();
    } catch (_) {
      // Overlay may already be disposed (e.g. context unmounted); ignore.
    }
    _overlayEntry = null;
    _isShowing = false;
  }

  /// Wrap an async operation with loading overlay
  ///
  /// Automatically shows loading at start and hides when complete
  /// Returns the result of the future
  ///
  /// Example:
  /// ```dart
  /// final result = await LoadingOverlay.wrap(
  ///   context,
  ///   future: authProvider.login(email, password),
  ///   message: "Logging in...",
  /// );
  /// ```
  static Future<T> wrap<T>({
    required BuildContext context,
    required Future<T> future,
    String? message,
  }) async {
    try {
      show(Overlay.of(context), message: message);
      final result = await future;
      return result;
    } finally {
      // Always hide loading, even if error occurs
      hide();
    }
  }

  /// Check if loading is currently showing
  static bool get isShowing => _isShowing;
}

/// Internal widget for the loading overlay UI
class _LoadingOverlayWidget extends StatelessWidget {
  final String? message;

  const _LoadingOverlayWidget({this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.black.withOpacity(0.5), // Semi-transparent grey background
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Progress Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Loading text
              Text(
                message ?? 'Loading...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension method to easily show/hide loading from context
extension LoadingOverlayExtension on BuildContext {
  /// Show loading overlay
  void showLoading({String? message}) {
    LoadingOverlay.show(Overlay.of(this), message: message);
  }

  /// Hide loading overlay
  void hideLoading() {
    LoadingOverlay.hide();
  }

  /// Wrap future with loading
  Future<T> withLoading<T>({
    required Future<T> future,
    String? message,
  }) {
    return LoadingOverlay.wrap(
      context: this,
      future: future,
      message: message,
    );
  }
}