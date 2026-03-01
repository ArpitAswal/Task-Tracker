import 'package:flutter/material.dart';
import 'package:task_tracker/presentation/screens/auth/email_verification_screen.dart';
import 'package:task_tracker/presentation/screens/profile/profile_screen.dart';
import 'package:task_tracker/presentation/screens/profile/profile_setup.dart';
import 'package:task_tracker/presentation/screens/task/task_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/exception/exception_screen.dart';
import '../../presentation/screens/home_dashboard_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

/// ✅ CORRECTED: Centralized route management for the entire app
///
/// All routes are defined here with named routes
/// Supports optional route arguments with type safety
/// Provides helper methods for different navigation types
///
/// Usage:
/// ```dart
/// // Simple navigation
/// AppRoutes.navigateTo(context, AppRoutes.login);
///
/// // Replace current screen
/// AppRoutes.navigateAndReplace(context, AppRoutes.home);
///
/// // Clear stack and navigate
/// AppRoutes.navigateAndRemoveUntil(context, AppRoutes.home);
///
/// // With arguments
/// AppRoutes.navigateTo(
///   context,
///   AppRoutes.taskDetail,
///   arguments: TaskDetailArguments(taskId: '123'),
/// );
/// ```

enum TransitionType {
  slide,
  fade,
  scale,
  slideUp,
  none,
  rotation, // ← New type
}

class AppRoutes {
  // ============================================================================
  // ROUTE NAMES
  // ============================================================================

  /// Initial/Splash route
  static const String splash = '/';

  /// Authentication routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerify = '/email-verification';

  /// Onboarding route
  static const String onboarding = '/onboarding';

  /// Home route
  static const String home = '/home';

  /// Task routes (Phase 2)
  static const String taskList = '/tasks';
  static const String taskDetail = '/task-detail';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';

  /// Profile & Settings routes (Phase 2)
  static const String profile = '/profile';
  static const String profileSetup = '/profile-setup';
  static const String setting = '/settings';

  // ============================================================================
  // NAVIGATION HELPER METHODS
  // ============================================================================

  /// Navigate to a route (push)
  ///
  /// Pushes a new screen on top of current screen
  /// User can go back to previous screen
  ///
  /// Example:
  /// ```dart
  /// AppRoutes.navigateTo(context, AppRoutes.taskDetail);
  /// ```
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Navigate and replace current route (pushReplacement)
  ///
  /// Replaces current screen with new screen
  /// User cannot go back to previous screen
  ///
  /// Example:
  /// ```dart
  /// AppRoutes.navigateAndReplace(context, AppRoutes.home);
  /// ```
  static Future<T?> navigateAndReplace<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Navigate and remove all previous routes (pushAndRemoveUntil)
  ///
  /// Clears entire navigation stack and navigates to new screen
  /// User cannot go back
  ///
  /// Example:
  /// ```dart
  /// AppRoutes.navigateAndRemoveUntil(context, AppRoutes.home);
  /// ```
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false, // Remove all previous routes
      arguments: arguments,
    );
  }

  /// Navigate and remove until specific route
  ///
  /// Removes routes until reaching a specific route
  ///
  /// Example:
  /// ```dart
  /// // Remove until home screen
  /// AppRoutes.navigateAndRemoveUntilRoute(
  ///   context,
  ///   AppRoutes.taskDetail,
  ///   untilRoute: AppRoutes.home,
  /// );
  /// ```
  static Future<T?> navigateAndRemoveUntilRoute<T>(
    BuildContext context,
    String routeName, {
    required String untilRoute,
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      ModalRoute.withName(untilRoute),
      arguments: arguments,
    );
  }

  /// Pop current route
  ///
  /// Goes back to previous screen
  ///
  /// Example:
  /// ```dart
  /// AppRoutes.pop(context);
  /// ```
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Check if can pop
  ///
  /// Returns true if there's a route to go back to
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  /// Pop until first route
  ///
  /// Goes back to the very first screen
  static void popToFirst(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Pop until specific route
  ///
  /// Goes back until reaching a specific route
  static void popUntilRoute(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  // ============================================================================
  // ROUTE GENERATOR
  // ============================================================================

  /// Main route generator function
  ///
  /// Handles all named routes and their optional arguments
  /// Returns appropriate screen based on route name
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract route name and arguments
    final routeName = settings.name;
    final arguments = settings.arguments;

    // Log route navigation for debugging
    debugPrint('🔄 Navigating to: $routeName');

    // Route to appropriate screen
    switch (routeName) {
      // ========================================================================
      // AUTHENTICATION ROUTES
      // ========================================================================

      case splash:
        return _buildRoute(const SplashScreen(), null, TransitionType.fade);
      case login:
        return _buildRoute(const LoginScreen());

      case signup:
        return _buildRoute(
          const SignupScreen(),
          settings,
          TransitionType.slide,
        );

      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen());

      case emailVerify:
        return _buildRoute(
          const EmailVerificationScreen(),
          settings,
          TransitionType.fade,
        );

      // ========================================================================
      // ONBOARDING
      // ========================================================================

      case onboarding:
        return _buildRoute(const OnboardingScreen());

      // ========================================================================
      // HOME
      // ========================================================================

      case home:
        return _buildRoute(const HomeDashboardView(), settings);

      // ========================================================================
      // TASK ROUTES (Phase 2)
      // ========================================================================

      case taskList:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Task List - Coming in Phase 2')),
          ),
          settings,
        );

      case taskDetail:
        // Extract task ID from arguments (optional)
        if (arguments != null && arguments is TaskDetailArguments) {
          return _buildRoute(
            Scaffold(
              body: Center(
                child: Text(
                  'Task Detail: ${arguments.taskId} - Coming in Phase 2',
                ),
              ),
            ),
            settings,
          );
        }
        // If no arguments provided, show error or default
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Task Detail - No task ID provided')),
          ),
          settings,
        );

      case addTask:
        // TODO: Implement in Phase 2
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Add Task - Coming in Phase 2')),
          ),
          settings,
        );

      case editTask:
        // Extract task for editing (optional)
        if (arguments != null && arguments is EditTaskArguments) {
          return _buildRoute(
            Scaffold(
              body: Center(
                child: Text(
                  'Edit Task: ${arguments.taskId} - Coming in Phase 2',
                ),
              ),
            ),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Edit Task - No task provided')),
          ),
          settings,
        );

      // ========================================================================
      // PROFILE & SETTINGS (Phase 2)
      // ========================================================================

      case profile:
        return _buildRoute(const ProfileScreen(), settings);

      case setting:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Settings - Coming in Phase 2')),
          ),
          settings,
        );

      case profileSetup:
        return _buildRoute(
          const ProfileSetup(), settings
        );

      // ========================================================================
      // DEFAULT (404)
      // ========================================================================

      default:
        return _buildErrorRoute(settings);
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Build a standard MaterialPageRoute
  static Route<dynamic> _buildRoute(
    Widget screen, [
    RouteSettings? settings,
    TransitionType? trans = TransitionType.slide,
  ]) {
    // If slide (default), use MaterialPageRoute
    if (trans == TransitionType.slide) {
      return MaterialPageRoute(builder: (_) => screen, settings: settings);
    } else {
      return _buildCustomRoute(screen, settings, trans);
    }
  }

  /// Build a custom transition route (optional, for animations)
  static PageRouteBuilder _buildCustomRoute(
    Widget screen,
    RouteSettings? settings,
    TransitionType? trans, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Curves make transitions feel much more professional
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        switch (trans ?? TransitionType.slide) {
          case TransitionType.fade:
            return FadeTransition(opacity: animation, child: child);

          case TransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(opacity: animation, child: child),
            );

          case TransitionType.slide:
            // Standard Right-to-Left slide
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case TransitionType.slideUp:
            // Bottom-to-Top slide
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case TransitionType.rotation:
            return RotationTransition(
              turns: Tween<double>(
                begin: 0.5,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.5,
                    end: 1.0,
                  ).animate(curvedAnimation),
                  child: child,
                ),
              ),
            );

          case TransitionType.none:
            return child;
        }
      },
      transitionDuration: duration,
      settings: settings,
    );
  }

  /// Build error route for undefined routes
  static MaterialPageRoute _buildErrorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const ExceptionScreen(),
      settings: settings,
    );
  }
}

// ==============================================================================
// ROUTE ARGUMENTS CLASSES (Optional - only when needed)
// ==============================================================================

/// Base class for route arguments (for type safety)
abstract class RouteArguments {
  const RouteArguments();
}

/// Arguments for task detail screen
class TaskDetailArguments extends RouteArguments {
  final String taskId;

  const TaskDetailArguments({required this.taskId});
}

/// Arguments for edit task screen
class EditTaskArguments extends RouteArguments {
  final String taskId;
  final String? initialTitle;
  final String? initialDescription;

  const EditTaskArguments({
    required this.taskId,
    this.initialTitle,
    this.initialDescription,
  });
}

/// Arguments for profile screen (if needed)
class ProfileArguments extends RouteArguments {
  final String userId;
  final bool isOwnProfile;

  const ProfileArguments({required this.userId, this.isOwnProfile = true});
}

/*
Navigation Flow
// 1. YOU CALL THIS IN YOUR CODE:
AppRoutes.navigateTo(context, AppRoutes.signup);

// 2. navigateTo METHOD EXECUTES:
static Future<T?> navigateTo<T>(
  BuildContext context,
  String routeName, {
  Object? arguments,
}) {
  return Navigator.of(context).pushNamed<T>(
    routeName,        // ← This is '/signup'
    arguments: arguments,
  );
}

// 3. Flutter's Navigator sees pushNamed('/signup')
//    and looks for how to build this route

// 4. Navigator calls the onGenerateRoute callback
//    (which you set in MaterialApp)

// 5. YOUR onGenerateRoute points to AppRoutes.generateRoute:
MaterialApp(
  onGenerateRoute: AppRoutes.generateRoute, // ← THIS!
  // ...
)

// 6. generateRoute is called with RouteSettings:
static Route<dynamic> generateRoute(RouteSettings settings) {
  // settings.name = '/signup'
  // settings.arguments = null (or your arguments)

  switch (settings.name) {
    case signup:  // ← Matches '/signup'
      return _buildRoute(
        const SignupScreen(),
        settings,
        TransitionType.slideUp,
      );
  }
}

// 7. _buildRoute creates the Route with transition:
static Route<dynamic> _buildRoute(...) {
  return PageRouteBuilder(
    // ... builds SignupScreen with slideUp animation
  );
}

// 8. Navigator pushes this Route onto the stack
//    and SignupScreen appears with slideUp animation!
```
 */
