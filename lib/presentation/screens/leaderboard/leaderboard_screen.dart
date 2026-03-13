import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/data/models/image_data.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_image.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: StreamBuilder<List<UserModel>>(
        stream: authProvider.getAllUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                loc?.translate('error_loading_leaderboard') ??
                    'Error loading leaderboard',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Text(
                loc?.translate('no_users_found') ?? 'No users found.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildLeaderboardTile(context, user, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, UserModel user, int index) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: (theme.brightness == Brightness.dark)
              ? [
            AppColors.currentStreak.withValues(alpha: 0.12),
            AppColors.longestStreak.withValues(alpha: 0.08),
          ]
              : [
            AppColors.longestStreak.withValues(alpha: 0.2),
            AppColors.currentStreak.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '#${index + 1}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: (theme.brightness == Brightness.dark) ?
                  AppColors.currentStreakDark : AppColors.longestStreak
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.onSecondary,
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: AppImage(
                  image: AppImageData.memory(
                  base64Decode(user.photoUrl ?? "")),
                  fit: BoxFit.cover,
                  width: 64,
                  height: 64,
                    placeholderBuilder:(context) {
                      return Center(child: Text(user.initials,style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),));
                    } ,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Text(user.initials,style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),));
                    }
                ),
              ),
            ),
          ],
        ),
        title: Text(
          user.fullName ?? user.firstName ?? '',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.primaryColor
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.w500
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            '${user.completedTasksCount}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
