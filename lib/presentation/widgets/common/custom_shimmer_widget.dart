import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracker/core/utils/extensions/context_extension.dart';

class CustomShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final BoxShape shape;
  final BorderRadius? borderRadius;

  const CustomShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
  }) : shape = BoxShape.rectangle;

  const CustomShimmerWidget.circular({
    super.key,
    required this.width,
    required this.height,
  }) : shape = BoxShape.circle,
       borderRadius = null;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: context.isDarkMode
          ? Colors.grey[700]!
          : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? (borderRadius ?? BorderRadius.circular(8))
              : null,
        ),
      ),
    );
  }
}

class LeaderboardTileShimmer extends StatelessWidget {
  const LeaderboardTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.isDarkMode ? Colors.grey[900] : Colors.grey[100],
      ),
      child: const ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomShimmerWidget.rectangular(width: 24, height: 32),
            SizedBox(width: 8),
            CustomShimmerWidget.circular(width: 64, height: 64),
          ],
        ),
        title: CustomShimmerWidget.rectangular(height: 16, width: 40),
        subtitle: CustomShimmerWidget.rectangular(height: 14),
        trailing: CustomShimmerWidget.circular(width: 40, height: 40),
      ),
    );
  }
}

class TaskCardShimmer extends StatelessWidget {
  const TaskCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          color: context.isDarkMode ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: (context.isDarkMode ? Colors.black : Colors.grey)
                  .withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(-4, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmerWidget.rectangular(
                  width: context.isTablet ? 28 : 24,
                  height: context.isTablet ? 28 : 24,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomShimmerWidget.rectangular(height: 20),
                      ),
                      SizedBox(width: 8),
                      CustomShimmerWidget.rectangular(
                        width: 70,
                        height: 24,
                        borderRadius: BorderRadius.all(Radius.circular(32)),
                      ),
                      SizedBox(width: 4),
                      CustomShimmerWidget.rectangular(
                        width: 70,
                        height: 24,
                        borderRadius: BorderRadius.all(Radius.circular(32)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const CustomShimmerWidget.rectangular(
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            const SizedBox(height: 8),
            const CustomShimmerWidget.rectangular(
              width: 120,
              height: 16,
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
          ],
        ),
      ),
    );
  }
}
