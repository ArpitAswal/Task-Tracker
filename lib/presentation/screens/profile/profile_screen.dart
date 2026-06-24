import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/core/utils/extensions/context_extension.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider.checkStreakDecay();
    });
  }

  Future<void> _showWarningDelayed() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.showWarningToast(
        _authProvider.errorMessage ?? 'user-profile-error',
      );
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
    final user = authProvider.userData!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: (context.isTablet ? 16 : 0)),
          ),
          // ── Gradient Header ──
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: (context.isTablet) ? 24 : 12,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildHeader(context, theme, user, loc),
            ),
          ),

          // ── Info Cards ──
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: (context.isTablet) ? 24 : 12,
              vertical: 16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildInfoSection(theme, user, loc),
                ),
                const SizedBox(height: 18),

                // 🔥 Streak Section
                _buildStreakSection(theme, user, loc),
                const SizedBox(height: 18),

                // Statistics
                Consumer<TaskProvider>(
                  builder: (context, taskProvider, _) {
                    return _buildStatisticsSection(
                      context,
                      taskProvider,
                      user,
                      theme,
                      loc,
                    );
                  },
                ),
                SizedBox(height: (context.screenHeight * 0.04)),

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
                    context.read<TaskProvider>().reset();
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
    UserModel user,
    AppLocalizations? loc,
  ) {
    final dateStr = DateFormat('d MMMM yyyy').format(user.createdAt);
    final memberText = _authProvider.lan?.languageCode == 'en'
        ? '${loc?.translate('member_since') ?? 'Member since'} $dateStr'
        : "$dateStr ${loc?.translate('member_since') ?? 'Member since'}";
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: (context.screenWidth * (context.isTablet ? 0.15 : 0.2)),
          height: (context.screenWidth * (context.isTablet ? 0.15 : 0.2)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: (context.isDarkMode)
                  ? [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary.withValues(alpha: 0.4),
                    ]
                  : [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.secondary.withValues(alpha: 0.15),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: (context.isDarkMode)
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary.withValues(alpha: 0.3),
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
                      style: context.textTheme.displayLarge?.copyWith(
                        fontSize: 40,
                        color: (context.isDarkMode)
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Display Name
              Text(
                user.displayName ?? user.firstName ?? "",
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              // Email
              Text(
                user.email,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
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

  // ============================================================================
  // 🔥 STREAK SECTION
  // ============================================================================

  Widget _buildStreakSection(
    ThemeData theme,
    UserModel user,
    AppLocalizations? loc,
  ) {
    final currentStreak = user.currentStreak;
    final longestStreak = user.longestStreak;
    String dayLabel(int count) => count <= 1
        ? (loc?.translate('day_streak') ?? 'day')
        : (loc?.translate('days_streak') ?? 'days');

    return Container(
      constraints: BoxConstraints(
        minHeight: context.screenHeight * (context.isTablet ? 0.2 : 0.16),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (context.isDarkMode)
              ? [
                  AppColors.currentStreak.withValues(alpha: 0.24),
                  AppColors.longestStreak.withValues(alpha: 0.18),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Current streak
          Expanded(
            child: Column(
              children: [
                Container(
                  width:
                      (context.screenWidth * (context.isTablet ? 0.1 : 0.12)),
                  height:
                      (context.screenWidth * (context.isTablet ? 0.1 : 0.12)),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.currentStreakDark,
                        AppColors.currentStreak,
                      ],
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
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: (context.isTablet ? 56 : 30),
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
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 2,
            color: Colors.deepOrange.withValues(
              alpha: (context.isDarkMode) ? 0.6 : 0.3,
            ),
            height: context.screenHeight * 0.12,
          ),

          // Longest streak
          Expanded(
            child: Column(
              children: [
                Container(
                  width:
                      (context.screenWidth * (context.isTablet ? 0.1 : 0.12)),
                  height:
                      (context.screenWidth * (context.isTablet ? 0.1 : 0.12)),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.longestStreak,
                        AppColors.longestStreakDark,
                      ],
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
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: (context.isTablet ? 56 : 30),
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
                    fontWeight: FontWeight.w600,
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
          value: loc?.translate(user.location?.toLowerCase() ?? '') ?? '',
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
        final item = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: (context.screenWidth * (context.isTablet ? 0.06 : 0.1)),
              height: (context.screenWidth * (context.isTablet ? 0.06 : 0.1)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                size: (context.isTablet ? 32 : 21),
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
    UserModel user,
    ThemeData theme,
    AppLocalizations? loc,
  ) {
    final spacing = (context.screenWidth * (context.isTablet ? 0.04 : 0.03));
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: (context.screenWidth * (context.isTablet ? 0.06 : 0.1)),
                height: (context.screenWidth * (context.isTablet ? 0.06 : 0.1)),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: (context.isTablet ? 32 : 21),
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
            children: [
              Expanded(
                child: _buildStatItem(
                  loc?.translate('total_tasks') ?? 'Total',
                  taskProvider.tasks.length.toString(),
                  AppColors.warning,
                  theme,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildStatItem(
                  loc?.translate('pending_label') ?? 'Pending',
                  taskProvider.pendingTasks.length.toString(),
                  AppColors.error,
                  theme,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  loc?.translate('completed_label') ?? 'Completed',
                  taskProvider.completedTasks.length.toString(),
                  AppColors.success,
                  theme,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildStatItem(
                  loc?.translate('lifetime_completed') ?? 'Lifetime Completed',
                  user.completedTasksCount.toString(),
                  AppColors.info,
                  theme,
                ),
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
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: (context.isTablet ? 36 : 24)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: (context.isDarkMode ? 0.2 : 0.06)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: (context.isDarkMode) ? 0.8 : 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: (context.isTablet ? 12 : 8)),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
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
