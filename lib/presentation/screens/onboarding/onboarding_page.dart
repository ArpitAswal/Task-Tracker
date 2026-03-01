import 'package:flutter/material.dart';
import 'package:task_tracker/data/models/image_data.dart';

import '../../../data/models/onboarding_model.dart';
import '../../widgets/common/app_image.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image
          AppImage(
            image: AppImageData.asset(data.image),
            height: size.height * 0.4,
            width: double.infinity,
            borderRadius: BorderRadius.circular(12),
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.task_alt,
                size: size.height * 0.4,
                color: theme.colorScheme.primary,
              );
            },
          ),
          SizedBox(height: size.height * 0.03),
          // Title
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  softWrap: true,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                // Description
                Text(
                  data.description,
                  softWrap: true,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
