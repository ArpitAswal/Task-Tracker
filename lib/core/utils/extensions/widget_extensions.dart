import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

/// Extension methods on [BuildContext] for creating themed, reusable widgets.
///
/// These eliminate boilerplate by providing consistent styling from the theme,
/// replacing inline widget builders scattered across screens.
extension WidgetExtensions on BuildContext {
  // ============================================================================
  // TEXT FIELDS
  // ============================================================================

  /// Creates a themed [TextFormField] with consistent border styling.
  ///
  /// Uses [Theme.of(context)] for all colors and text styles.
  /// Supports validation, prefix icons, and keyboard types.
  Widget themedTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int? maxLength,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    String? errorText,
  }) {
    final theme = Theme.of(this);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLength: maxLength,
      maxLines: maxLines,
      obscureText: obscureText,
      enabled: enabled,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        counterText: maxLength != null ? null : '',
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
                color: theme.colorScheme.primary.withValues(alpha: 0.7))
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor:
            isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  // ============================================================================
  // BUTTONS
  // ============================================================================

  /// Creates a full-width themed [ElevatedButton] with optional loading state.
  ///
  /// Primary action button — uses theme primary color.
  Widget themedElevatedButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    double height = 54,
  }) {
    final theme = Theme.of(this);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Creates a full-width themed [OutlinedButton].
  ///
  /// Secondary action button — uses theme primary color outline.
  Widget themedOutlinedButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    double height = 50,
  }) {
    final theme = Theme.of(this);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a full-width danger/destructive button (e.g., Sign Out, Delete).
  ///
  /// Uses error color palette.
  Widget themedDangerButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    double height = 50,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          foregroundColor: AppColors.error,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Theme.of(this).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
