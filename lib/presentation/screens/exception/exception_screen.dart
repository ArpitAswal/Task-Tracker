import 'package:flutter/material.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';

import '../../../core/routes/app_routes.dart';
import '../../widgets/common/custom_button.dart';

class ExceptionScreen extends StatelessWidget {
  const ExceptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = ModalRoute.of(context)?.settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('error') ?? 'Error'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                loc?.translate('route_not_found') ?? 'Route not found',
              ),
              const SizedBox(height: 8),
              Text(
                '${loc?.translate('path') ?? 'Path'}: ${settings?.name ?? loc?.translate('unknown_path') ?? 'Unknown Path'}',
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: () => {
                  AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login)
                },
                text: loc?.translate('goto_login') ??
                'Go to Login',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
