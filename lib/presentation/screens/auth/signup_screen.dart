import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/data/models/image_data.dart';
import 'package:task_tracker/presentation/widgets/common/app_image.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/curved_clipper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/loading_overlay.dart';
import '../../../core/utils/message_utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_form_fields.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // Clear any previous errors
    context.read<AuthProvider>().clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loc = AppLocalizations.of(context);

    // ✨ Use LoadingOverlay
    final success = await context.withLoading(
      message: loc?.translate('signing_up') ?? 'Signing up...', // or localized
      future: context.read<AuthProvider>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );

    if (!mounted) return;

    if (success) {
      // ✨ Use context extensions
      context.showSuccess('signup_success');
      AppRoutes.navigateAndRemoveUntil(context, AppRoutes.emailVerify, arguments: {'fromLogin': false});
    } else {
      // ✨ Use MessageUtils
      debugPrint(
        "# AppError:---> ${context.read<AuthProvider>().errorMessage}",
      );
      context.showError(
        context.read<AuthProvider>().errorMessage ?? 'signup_failed',
      );
    }
  }

  void _navigateToLogin() {
    if (AppRoutes.canPop(context)) {
      AppRoutes.pop(context);
    } else {
      AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
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
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 0.05),

                            // Image
                            AppImage(
                              image: const AppImageData.asset(
                                AppConstants.signupImage,
                              ),
                              fit: BoxFit.cover,
                              height: size.height * 0.2,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person_add_alt_1,
                                  size: size.height * 0.15,
                                  color: theme.colorScheme.primary,
                                );
                              },
                            ),

                            SizedBox(height: size.height * 0.025),

                            // Title
                            Text(
                              localization.signupTitle,
                              style: theme.textTheme.displaySmall,
                            ),

                            const SizedBox(height: 4),

                            // Subtitle
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: localization.signupSubtitle,
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: ' ${localization.termsPrivacy}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: size.height * 0.03),

                            // Email Field
                            EmailTextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              labelText: localization.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) => Validators.validateEmail(
                                value,
                                errorMessage: localization.emailRequired,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Password Field
                            PasswordTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              labelText: localization.password,
                              textInputAction: TextInputAction.done,
                              validator: (value) => Validators.validatePassword(
                                value,
                                errorMessage: localization.passwordRequired,
                              ),
                              onFieldSubmitted: (_) => {
                                (!_formKey.currentState!.validate()),
                              },
                            ),

                            const SizedBox(height: 24),

                            // Register Button
                            CustomButton(
                              text: localization.signup,
                              onPressed: _handleSignup,
                            ),
                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  localization.alreadyHaveAccount,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: _navigateToLogin,
                                  child: Text(
                                    localization.translate('login'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom curved section
                  ClipPath(
                    clipper: CurvedClipper(),
                    child: Container(
                      width: size.width,
                      height: size.height * 0.15,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
