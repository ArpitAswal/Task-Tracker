import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/utils/extensions/context_extension.dart';
import 'package:task_tracker/presentation/providers/task_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/curved_clipper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/extensions/widget_extensions.dart';
import '../../../core/utils/loading_overlay.dart';
import '../../../core/utils/message_utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_form_fields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final authProvider = context.read<AuthProvider>();
    final credentials = await authProvider.getSavedCredentials();
    if (credentials['email'] != null && credentials['password'] != null) {
      _emailController.text = credentials['email']!;
      _passwordController.text = credentials['password']!;
    }
  }

  Future<void> _handleLogin() async {
    debugPrint("# handling login");
    // Clear any previous errors
    context.read<AuthProvider>().clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loc = AppLocalizations.of(context);
    // ✨ Use LoadingOverlay
    final success = await context.withLoading(
      message: loc?.translate('logging_in') ?? 'Logging in...', // or localized
      future: context.read<AuthProvider>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        rememberMe: context.read<AuthProvider>().isRememberMe,
      ),
    );

    if (!mounted) return;

    context.read<TaskProvider>().initialize();
    if (success) {
      // ✨ Use context extensions
      context.showSuccessToast('login_success');
      if (context.read<AuthProvider>().isEmailVerify) {
        AppRoutes.navigateAndRemoveUntil(context, AppRoutes.home);
      } else {
        AppRoutes.navigateTo(
          context,
          AppRoutes.emailVerify,
          arguments: {'fromLogin': true},
        );
      }
    } else {
      // ✨ Use MessageUtils
      debugPrint("✨AppError:---> ${context.read<AuthProvider>().errorMessage}");
      if (context.read<AuthProvider>().errorMessage != null &&
          context.read<AuthProvider>().errorMessage!.contains(
            "user-profile-error",
          )) {
        AppRoutes.navigateAndRemoveUntil(context, AppRoutes.profile);
      } else {
        context.showErrorToast(
          (context.read<AuthProvider>().errorMessage != null &&
                  context.read<AuthProvider>().errorMessage!.contains(
                    'cloud_firestore/unavailable',
                  ))
              ? 'cloud_firestore/unavailable'
              : context.read<AuthProvider>().errorMessage ??
                    'login_failed_no_user',
        );
      }
    }
  }

  void _navigateToSignup() {
    AppRoutes.navigateTo(context, AppRoutes.signup);
  }

  void _navigateToForgotPassword() {
    AppRoutes.navigateTo(context, AppRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (context.isTablet) ? 48 : 24.0,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.05),

                              // Title
                              Text(
                                localization.loginTitle,
                                style: theme.textTheme.displayMedium,
                              ),

                              const SizedBox(height: 8),

                              // Subtitle
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 36.0,
                                ),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: localization.loginSubtitle,
                                    style: (context.isTablet)
                                        ? theme.textTheme.titleLarge?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                            fontWeight: theme
                                                .textTheme
                                                .bodySmall
                                                ?.fontWeight,
                                          )
                                        : theme.textTheme.bodySmall,
                                    children: [
                                      TextSpan(
                                        text: ' ${localization.termsPrivacy}',
                                        style: (context.isTablet)
                                            ? theme.textTheme.titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                  )
                                            : theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: size.height * 0.04),

                              // Email Field
                              EmailTextField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                labelText: localization.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) => Validators.validateEmail(
                                  value,
                                  errorMessage: localization.emailRequired,
                                  context: context,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Password Field
                              PasswordTextField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                labelText: localization.password,
                                textInputAction: TextInputAction.done,
                                validator: (value) =>
                                    Validators.validatePassword(
                                      value,
                                      errorMessage:
                                          localization.passwordRequired,
                                      context: context,
                                    ),
                                onFieldSubmitted: (_) => {
                                  _formKey.currentState!.validate(),
                                },
                              ),

                              SizedBox(height: (context.isTablet ? 6 : 0)),
                              // Remember Me & Forgot Password
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Remember Me
                                  Row(
                                    children: [
                                      Consumer<AuthProvider>(
                                        // toggle remember me and update checkbox UI
                                        builder: (context, authProvider, _) {
                                          return Transform.scale(
                                            scale: (context.isTablet) ? 1.5 : 1,
                                            child: Checkbox(
                                              // This shrinks the hit area to the size of the box itself
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              // This removes extra padding around the checkbox
                                              visualDensity:
                                                  VisualDensity.compact,
                                              fillColor:
                                                  WidgetStateProperty.resolveWith((
                                                    states,
                                                  ) {
                                                    if (states.contains(
                                                      WidgetState.selected,
                                                    )) {
                                                      return (context
                                                              .isDarkMode)
                                                          ? AppColors
                                                                .primaryDarkColor
                                                          : AppColors
                                                                .primaryLightColor;
                                                    }
                                                    return (context.isDarkMode)
                                                        ? AppColors.black
                                                        : AppColors.white;
                                                  }),
                                              checkColor: (context.isDarkMode)
                                                  ? AppColors.black
                                                  : AppColors.white,
                                              side: BorderSide(
                                                width: 2,
                                                color: (context.isDarkMode)
                                                    ? AppColors.primaryDarkColor
                                                    : AppColors
                                                          .primaryLightColor,
                                              ),
                                              value: authProvider.isRememberMe,
                                              onChanged: (_) {
                                                authProvider.toggleRememberMe();
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        width: (context.isTablet ? 8 : 0),
                                      ),
                                      Text(
                                        localization.rememberMe,
                                        style: (context.isTablet)
                                            ? theme.textTheme.bodyMedium
                                            : theme.textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                  // Forgot Password
                                  TextButton(
                                    onPressed: _navigateToForgotPassword,
                                    child: Text(
                                      localization.forgotPassword,
                                      style: (context.isTablet)
                                          ? theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: context
                                                      .theme
                                                      .colorScheme
                                                      .primary,
                                                )
                                          : theme.textTheme.bodyLarge?.copyWith(
                                              color: context
                                                  .theme
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Login Button
                              context.themedElevatedButton(
                                label: localization.login,
                                onPressed: _handleLogin,
                              ),

                              // Sign Up Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    localization.dontHaveAccount,
                                    style: (context.isTablet)
                                        ? theme.textTheme.bodyMedium
                                        : theme.textTheme.bodyLarge,
                                  ),
                                  const SizedBox(width: 4),
                                  TextButton(
                                    onPressed: _navigateToSignup,
                                    child: Text(
                                      localization.register,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            theme.colorScheme.primary,
                                        fontSize: (context.isTablet) ? 16 : 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom curved section with image
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                          ).copyWith(bottom: 30),
                          child: Image.asset(
                            AppConstants.loginImage,
                            fit: BoxFit.contain,
                            height: size.height * 0.25,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.task_alt,
                                size: size.height * 0.15,
                                color: theme.colorScheme.primary,
                              );
                            },
                          ),
                        ),
                        ClipPath(
                          clipper: CurvedClipper(),
                          child: Container(
                            width: size.width,
                            height: size.height * 0.18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
