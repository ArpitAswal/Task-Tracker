import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/utils/message_utils.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/curved_clipper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/loading_overlay.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_form_fields.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Clear any previous errors
    context.read<AuthProvider>().clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loc = AppLocalizations.of(context);
    // ✨ Use LoadingOverlay
    final success = await context.withLoading(
      message: loc?.translate('reset_link') ?? 'Reset link...', // or localized
      future: context.read<AuthProvider>().sendPasswordResetEmail(
        _emailController.text.trim(),
      ),
    );

    if (!mounted) return;

    if (success) {
      context.showSuccess('reset_email_sent');

      // Navigate back after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Clear the email field
          _emailController.clear();

          if (AppRoutes.canPop(context)) {
            AppRoutes.pop(context);
          } else {
            AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
          }
        }
      });
    } else {
      // Show error
      context.showError(
        context.read<AuthProvider>().errorMessage ??
            'Failed to send reset email',
      );
    }
  }

  void _popBack() {
    // Navigator.pop(context);
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
      resizeToAvoidBottomInset: false, // Prevent resizing on keyboard open
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          // SafeArea to avoid notches
          child: Column(
            children: [
              Expanded(
                // Main content area
                child: SingleChildScrollView(
                  // Scrollable content
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Close Button
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _popBack,
                            ),
                          ),

                          SizedBox(height: size.height * 0.02),

                          // Title
                          Text(
                            localization.forgotPasswordTitle,
                            style: theme.textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            localization.forgotPasswordSubtitle,
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: size.height * 0.04),

                          // Email Field
                          EmailTextField(
                            controller: _emailController,
                            labelText: localization.email,
                            textInputAction: TextInputAction.done,
                            validator: (value) => Validators.validateEmail(
                              value,
                              errorMessage: localization.emailRequired,
                            ),
                            onFieldSubmitted: (_) => {
                              _formKey.currentState!.validate(),
                            },
                          ),

                          SizedBox(height: size.height * 0.02),

                          // Submit Button
                          CustomButton(
                            text: localization.submit,
                            onPressed: _handleSubmit,
                            width: size.width * 0.4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom section with image and curved clipper
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
                          Icons.lock_reset,
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
      ),
    );
  }
}
