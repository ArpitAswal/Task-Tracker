import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double? height;
  final Widget? icon;
  final ButtonStyle? btnStyle;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height,
    this.icon,
    this.btnStyle
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 50,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: btnStyle,
          child: _buildButtonContent(context),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: btnStyle,
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final double? iconSize;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size,
    this.iconSize,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 48.0;
    final actualIconSize = iconSize ?? 24.0;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, size: actualIconSize),
        color: color,
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}