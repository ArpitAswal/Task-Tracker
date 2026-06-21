// Splash Screen to determine initial route
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/utils/extensions/context_extension.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Wait for splash animations/delays
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final onboardingCompleted =
        StorageService().readBool(StorageKeys.onboardingCompleted) ?? false;

    String nextRoute = AppRoutes.onboarding;

    if (authProvider.isAuthenticated && authProvider.isEmailVerify) {
      nextRoute =
          AppRoutes.home; // Replace with your explicit home route string
    } else if (onboardingCompleted) {
      nextRoute = AppRoutes.login; // Replace with your login route string
    }

    // Safely remove the splash screen from the backstack completely
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AppConstants.splashLottie,
              height: context.screenHeight * (context.isTablet ? 0.5 : 0.3),
            ),
            Text(AppConstants.appName, style: theme.textTheme.displayLarge),
          ],
        ),
      ),
    );
  }
}
