import 'package:flutter/material.dart';

class ImageBuilders {
  static Widget placeholder(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image, color: Colors.grey, size: 28),
    );
  }

  static Widget loading(BuildContext context) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 1.4));
  }

  static Widget error(BuildContext context) {
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 28),
    );
  }

  static Widget fadeFrame(
      BuildContext context,
      Widget child,
      int? frame,
      bool wasSynchronouslyLoaded,
      ) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: const Duration(milliseconds: 250),
      child: child,
    );
  }
}
