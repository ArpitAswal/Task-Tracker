import 'package:flutter/material.dart';

/// ✨ NEW: Extension methods for BuildContext to simplify common operations
///
/// Provides convenient access to:
/// - Theme data
/// - MediaQuery data
/// - Navigation
/// - Dialogs and overlays
/// - SnackBars and messages
extension ContextExtensions on BuildContext {
  // ============================================================================
  // THEME ACCESS
  // ============================================================================

  /// Get the current theme data
  ThemeData get theme => Theme.of(this);

  /// Get the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Check if current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get primary color
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Get background color
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  // ============================================================================
  // MEDIA QUERY ACCESS
  // ============================================================================

  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get screen padding (for notches, status bar, etc.)
  EdgeInsets get screenPadding => MediaQuery.of(this).padding;

  /// Get view insets (keyboard height, etc.)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Get device pixel ratio
  double get pixelRatio => MediaQuery.of(this).devicePixelRatio;

  // ============================================================================
  // RESPONSIVE HELPERS
  // ============================================================================

  /// Check if device is mobile (width < 600)
  bool get isMobile => screenWidth < 600;

  /// Check if device is tablet (600 <= width < 900)
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Check if device is desktop (width >= 900)
  bool get isDesktop => screenWidth >= 900;

  /// Get responsive value based on screen size
  T responsiveValue<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // ============================================================================
  // FOCUS
  // ============================================================================

  /// Unfocus (dismiss keyboard)
  void unfocus() {
    FocusScope.of(this).unfocus();
  }

  /// Request focus
  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }

  // ============================================================================
  // DIALOGS & BOTTOM SHEETS
  // ============================================================================

  /// Show a dialog
  Future<T?> showDialogBox<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (_) => child,
    );
  }

  Future<bool?> showAlertDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    final currentTheme = theme;
    return showDialog<bool>(
      context: this,
      barrierDismissible: false,
      builder: (context) => Center(
        child: ConstrainedBox(
          // Limits the width on tablets so it stays centered and readable
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: AlertDialog(
            backgroundColor: currentTheme.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            // DYNAMIC PADDING
            titlePadding: EdgeInsets.fromLTRB(
              isTablet ? 32 : 24, // Left
              isTablet ? 32 : 24, // Top
              isTablet ? 32 : 24, // Right
              isTablet ? 16 : 12, // Bottom
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 24,
            ),
            actionsPadding: EdgeInsets.all(isTablet ? 24 : 16),
            title: Text(
              title,
              style: currentTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(message, style: currentTheme.textTheme.bodyMedium),
            actions: [
              if (cancelText != null)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: currentTheme.colorScheme.onSurface
                        .withOpacity(0.6),
                  ),
                  child: Text(cancelText),
                ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: theme.elevatedButtonTheme.style?.copyWith(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                child: Text(confirmText ?? 'OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show bottom sheet
  Future<T?> showBottomSheetModal<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => child,
    );
  }

  // ============================================================================
  // SCAFFOLD MESSENGER (For SnackBars)
  // ============================================================================

  /// Get ScaffoldMessenger
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  /// Show a basic snackbar
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Hide current snackbar
  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }

  /// Clear all snackbars
  void clearSnackBars() {
    ScaffoldMessenger.of(this).clearSnackBars();
  }
}
