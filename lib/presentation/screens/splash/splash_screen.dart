// Splash Screen to determine initial route
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../home_dashboard_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<Widget> _navigateToNextScreen(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    ); // Get AuthProvider, listen: false to avoid rebuilds
    final isLoggedIn =
        authProvider.isAuthenticated; // Check if user is logged in
    final isEmailVerify =
        authProvider.isEmailVerify; // Check if user verify email
    final onboardingCompleted =
        StorageService().readBool(StorageKeys.onboardingCompleted) ??
        false; // Check if onboarding is completed
    if (isLoggedIn && isEmailVerify) {
      debugPrint('🔄 Navigating to: /home');
      return const HomeDashboardView(); // Your Task Screen
    } else if (onboardingCompleted && (!isEmailVerify || !isLoggedIn)) {
      debugPrint('🔄 Navigating to: /login');
      return const LoginScreen(); // Your Login Screen
    } else {
      debugPrint('🔄 Navigating to: /onboarding');
      return const OnboardingScreen(); // Your Onboarding Screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSplashScreen.withScreenFunction(
      centered: true,
      curve: Curves.linear,
      splashIconSize: MediaQuery.of(context).size.height,
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // The Lottie animation
          Flexible(
            child: Lottie.asset(
              AppConstants.splashLottie,
              fit: BoxFit.cover,
              repeat: true,
              reverse: true,
              options: LottieOptions(enableMergePaths: true),
            ),
          ),
          // Your App Name
          Text(AppConstants.appName, style: theme.textTheme.displayLarge),
        ],
      ),
      // Use screenFunction to handle conditional logic
      screenFunction: () async {
        // This creates an infinite wait so you can inspect your UI
        // await Future.delayed(const Duration(days: 1));

        // This part will never be reached
        // return const HomeScreen();
        await Future.delayed(const Duration(seconds: 3));
        return await _navigateToNextScreen(context);
      },
      backgroundColor: theme.scaffoldBackgroundColor,
      splashTransition: SplashTransition.scaleTransition,
      animationDuration: const Duration(seconds: 2),
    );
  }
}
