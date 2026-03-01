import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/core/utils/loading_overlay.dart';
import 'package:task_tracker/presentation/widgets/common/custom_button.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? timer;
  int resendCooldown = 60;
  bool canResend = false;
  late AuthProvider _authProvider;
  late Timer? runningTimer;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    startVerificationCheck();
    startCooldown();
  }

  void startVerificationCheck() {
    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final user = _authProvider.firebaseAuth?.currentUser;
      if (user != null) {
        await user.reload();

        if (user.emailVerified) {
          timer?.cancel();
          await _authProvider.setEmailVerify(true);
          if (!mounted) return;

          await context.withLoading(
            message:
                AppLocalizations.of(context)?.translate('email_verifying') ??
                'Email verifying...',
            future: Future.delayed(const Duration(seconds: 3), () async {
              await _authProvider.updateCollectionField(
                FirebaseCollections.users,
                'isEmailVerified',
                true,
              );
            }),
          );

          if (mounted) {
            AppRoutes.navigateAndRemoveUntil(context, AppRoutes.profileSetup);
          }
        }
      }
    });
  }

  void startCooldown() {
    resendCooldown = 60;
    canResend = false;
    runningTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendCooldown == 0) {
        t.cancel();
        setState(() => canResend = true);
      } else {
        setState(() => resendCooldown--);
      }
    });
  }

  Future<void> resendEmail() async {
    await _authProvider.resendEmail();
    startCooldown();
  }

  @override
  void dispose() {
    runningTimer?.cancel();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final loc = AppLocalizations.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    canResend = args['fromLogin'] ?? false;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_read_outlined, size: size.width * 0.4),
                const SizedBox(height: 20),
                Text(
                  loc?.verifyEmail ?? 'Verify your email',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  loc?.verifyEmailMsg ??
                      "We have sent a verification link to your register email.Please verify your account to continue",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 30),

                CustomButton(
                  onPressed: canResend ? resendEmail : null,
                  text: canResend
                      ? (loc?.resendEmail ?? "Resend Email")
                      : "${loc?.resendIn ?? "Resend in"}"
                            " $resendCooldown s",
                ),

                const SizedBox(height: 20),
                CustomButton(
                  onPressed: () {
                    runningTimer?.cancel();
                    _authProvider.logout();
                    if (!mounted) return;
                    // Navigate to login
                    AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
                  },
                  text: loc?.anotherAccount ?? "Use another account",
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
