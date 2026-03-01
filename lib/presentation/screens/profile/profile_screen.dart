import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/core/utils/extensions/widget_extensions.dart';
import 'package:task_tracker/core/utils/message_utils.dart';
import 'package:task_tracker/presentation/screens/profile/profile_setup.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    if (_authProvider.userData == null) {
      _showWarningDelayed();
    }
  }

  Future<void> _showWarningDelayed() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.showWarningToast(_authProvider.errorMessage ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.userData;

        // Show setup form if profile is not complete
        if (user == null || !user.isProfileComplete) {
          return const ProfileSetup(isEditing: false);
        }

        // Show profile display
        return _buildProfileDisplay(context, authProvider);
      },
    );
  }

  Widget _buildProfileDisplay(BuildContext context, AuthProvider authProvider) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = authProvider.userData!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header ──
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? screenWidth * 0.12 : 16,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildHeader(context, theme, isDark, user, loc),
            ),
          ),

          // ── Info Cards ──
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? screenWidth * 0.12 : 16,
              vertical: 16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Member Since
                // _buildMemberSinceCard(theme, isDark, user, loc),
                // const SizedBox(height: 16),

                // Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildInfoSection(theme, isDark, user, loc),
                ),
                const SizedBox(height: 18),

                // 🔥 Streak Section
                _buildStreakSection(theme, isDark, user, loc),
                const SizedBox(height: 18),

                // Statistics
                Consumer<TaskProvider>(
                  builder: (context, taskProvider, _) {
                    return _buildStatisticsSection(
                      context,
                      taskProvider,
                      theme,
                      isDark,
                      loc,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Edit Profile Button (using extension)
                context.themedOutlinedButton(
                  label: loc?.translate('edit_profile') ?? 'Edit Profile',
                  icon: Icons.edit_outlined,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileSetup(isEditing: true),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Sign Out Button (using extension)
                context.themedDangerButton(
                  label: loc?.translate('sign_out') ?? 'Sign Out',
                  icon: Icons.logout_rounded,
                  onPressed: () {
                    _authProvider.logout();
                    AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
                  },
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    UserModel user,
    AppLocalizations? loc,
  ) {
    final dateStr = DateFormat('d MMMM yyyy').format(user.createdAt);
    final memberText =
        '${loc?.translate('member_since') ?? 'Member since'} $dateStr';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.colorScheme.secondary.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: user.hasProfilePhoto
                ? _buildProfileImage(user.photoUrl!)
                : Center(
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Name
              Text(
                user.displayName ?? user.firstName ?? "",
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              // Email
              Text(
                user.email,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              // Account Create
              Text(
                memberText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(String photoData) {
    try {
      final bytes = base64Decode(photoData);
      return Image.memory(bytes, fit: BoxFit.cover, width: 108, height: 108);
    } catch (_) {
      return Image.network(
        photoData,
        fit: BoxFit.cover,
        width: 108,
        height: 108,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, size: 48, color: AppColors.grey),
      );
    }
  }

  Widget _buildMemberSinceCard(
    ThemeData theme,
    bool isDark,
    UserModel user,
    AppLocalizations? loc,
  ) {
    final dateStr = DateFormat('d MMMM yyyy').format(user.createdAt);
    final memberText =
        '${loc?.translate('member_since') ?? 'Member since'} $dateStr';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
            theme.colorScheme.secondary.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              memberText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 🔥 STREAK SECTION
  // ============================================================================

  Widget _buildStreakSection(
    ThemeData theme,
    bool isDark,
    UserModel user,
    AppLocalizations? loc,
  ) {
    final currentStreak = user.currentStreak;
    final longestStreak = user.longestStreak;
    String dayLabel(int count) => count <= 1
        ? (loc?.translate('day_streak') ?? 'day')
        : (loc?.translate('days_streak') ?? 'days');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.currentStreak.withValues(alpha: 0.12),
                  AppColors.longestStreak.withValues(alpha: 0.08),
                ]
              : [
                  AppColors.currentStreak.withValues(alpha: 0.08),
                  AppColors.longestStreak.withValues(alpha: 0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Current streak
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.currentStreakDark, AppColors.currentStreak],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.currentStreak.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$currentStreak ${dayLabel(currentStreak)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.currentStreak,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loc?.translate('current_streak') ?? 'Current Streak',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Divider
          Container(width: 1, height: 70, color: Colors.red),

          // Longest streak
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.longestStreak, AppColors.longestStreakDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.longestStreak.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$longestStreak ${dayLabel(longestStreak)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.longestStreak,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loc?.translate('longest_streak') ?? 'Longest Streak',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    ThemeData theme,
    bool isDark,
    UserModel user,
    AppLocalizations? loc,
  ) {
    final infoItems = <_InfoItem>[];

    if (user.gender != null && user.gender!.isNotEmpty) {
      String genderLabel;
      switch (user.gender) {
        case 'male':
          genderLabel = loc?.translate('male') ?? 'Male';
          break;
        case 'female':
          genderLabel = loc?.translate('female') ?? 'Female';
          break;
        case 'other':
          genderLabel = loc?.translate('other_gender') ?? 'Other';
          break;
        case 'prefer_not_to_say':
          genderLabel =
              loc?.translate('prefer_not_to_say') ?? 'Prefer not to say';
          break;
        default:
          genderLabel = user.gender!;
      }
      infoItems.add(
        _InfoItem(
          icon: Icons.wc_rounded,
          label: loc?.translate('gender') ?? 'Gender',
          value: genderLabel,
        ),
      );
    }

    if (user.age != null) {
      infoItems.add(
        _InfoItem(
          icon: Icons.cake_outlined,
          label: loc?.translate('age') ?? 'Age',
          value: '${user.age}',
        ),
      );
    }

    if (user.location != null && user.location!.isNotEmpty) {
      infoItems.add(
        _InfoItem(
          icon: Icons.location_on_outlined,
          label: loc?.translate('location') ?? 'Location',
          value: user.location!,
        ),
      );
    }

    if (infoItems.isEmpty) return const SizedBox.shrink();

    return Wrap(
      runSpacing: 16.0,
      spacing: 40.0,
      alignment: (infoItems.length > 2)
          ? WrapAlignment.spaceBetween
          : WrapAlignment.center,
      children: infoItems.asMap().entries.map((entry) {
        final isLast = entry.key == infoItems.length - 1;
        final item = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    TaskProvider taskProvider,
    ThemeData theme,
    bool isDark,
    AppLocalizations? loc,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 20,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                loc?.translate('statistics') ?? 'Statistics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                loc?.translate('total_tasks') ?? 'Total',
                taskProvider.tasks.length.toString(),
                AppColors.warning,
                theme,
                isDark,
              ),
              _buildStatItem(
                loc?.translate('pending_label') ?? 'Pending',
                taskProvider.pendingTasks.length.toString(),
                AppColors.error,
                theme,
                isDark,
              ),
              _buildStatItem(
                loc?.translate('completed_label') ?? 'Completed',
                taskProvider.completedTasks.length.toString(),
                AppColors.success,
                theme,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Helper class for info section items
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({required this.icon, required this.label, required this.value});
}
