import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';

import '../../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              // Proper logout: clear provider state, sign out, then navigate
              try {
                final authProvider = context.read<AuthProvider>();
                final taskProvider = context.read<TaskProvider>();
                taskProvider.reset();
                await authProvider.logout();
              } catch (e) {
                debugPrint('Logout error: $e');
              }
              if (context.mounted) {
                AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: loc?.translate('logout') ?? 'Logout',
          ),
        ],
      ),
    );
  }
}
