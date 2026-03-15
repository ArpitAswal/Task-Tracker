import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/utils/extensions/context_extension.dart';
import 'package:task_tracker/core/utils/extensions/widget_extensions.dart';
import 'package:task_tracker/data/models/image_data.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_image.dart';
import '../../widgets/common/custom_shimmer_widget.dart';
import '../../../core/utils/message_utils.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _itemsToShow = 10;
  final ScrollController _scrollController = ScrollController();
  
  final TextEditingController _startIdxController = TextEditingController();
  final TextEditingController _endIdxController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isSearching) return;
    
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      setState(() {
        _itemsToShow += 10;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _startIdxController.dispose();
    _endIdxController.dispose();
    super.dispose();
  }

  void _performSearch() {
    FocusScope.of(context).unfocus();
    final start = int.tryParse(_startIdxController.text.trim());
    final end = int.tryParse(_endIdxController.text.trim());
    
    if (start != null && end != null && start > 0 && end >= start) {
      setState(() {
        _isSearching = true;
      });
    } else {
       context.showErrorToast("Invalid search indices.");
    }
  }

  void _clearSearch() {
    FocusScope.of(context).unfocus();
    _startIdxController.clear();
    _endIdxController.clear();
    setState(() {
      _isSearching = false;
      _itemsToShow = 10;
      _scrollController.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal:
        context.isTablet ? 24 : 12),
        child: Column(
          children: [
            _buildSearchBar(theme, loc),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: authProvider.getAllUsersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: (MediaQuery.of(context).size.width > 600 ? 10 : 5),
                      itemBuilder: (context, index) => const LeaderboardTileShimmer(),
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

                  final allUsers = snapshot.data ?? [];

                  if (allUsers.isEmpty) {
                    return Center(
                      child: Text(
                        loc?.translate('no_users_found') ?? 'No users found.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }

                  List<UserModel> displayUsers = [];
                  int startRank = 1;

                  if (_isSearching) {
                    final start = int.tryParse(_startIdxController.text.trim()) ?? 1;
                    final end = int.tryParse(_endIdxController.text.trim()) ?? 10;
                    int actualStart = start > 0 ? start - 1 : 0;
                    int actualEnd = end;
                    if (actualStart < allUsers.length) {
                      if (actualEnd > allUsers.length) {
                         actualEnd = allUsers.length;
                      }
                      displayUsers = allUsers.sublist(actualStart, actualEnd);
                      startRank = actualStart + 1;
                    } else {
                      displayUsers = [];
                    }
                  } else {
                    final takeCount = _itemsToShow > allUsers.length ? allUsers.length : _itemsToShow;
                    displayUsers = allUsers.take(takeCount).toList();
                    startRank = 1;
                  }

                  if (displayUsers.isEmpty) {
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
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 40),
                    itemCount: displayUsers.length + (_isSearching ? 0 : (_itemsToShow < allUsers.length ? 1 : 0)),
                    itemBuilder: (context, index) {
                      if (!_isSearching && index == displayUsers.length) {
                         return const Padding(
                           padding: EdgeInsets.all(16.0),
                           child: Center(
                              child: LeaderboardTileShimmer(),
                           ),
                         );
                      }
                      final user = displayUsers[index];
                      return _buildLeaderboardTile(context, user, startRank + index - 1);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, AppLocalizations? loc) {
    return Row(
      children: [
        Expanded(
          child: _buildSearchField(
             _startIdxController,
             loc?.translate('start_rank') ?? 'Start Rank',
             theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSearchField(
             _endIdxController,
             loc?.translate('end_rank') ?? 'End Rank',
             theme,
          ),
        ),
        const SizedBox(width: 8),
        if (_isSearching)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
               icon: Icon(Icons.clear, color: theme.colorScheme.error),
               onPressed: _clearSearch,
               tooltip: "Clear Search",
            ),
          ),
        const SizedBox(width: 8),
        Container(
          height: (context.isTablet) ? 60 : 48,
          width: (context.isTablet) ? 60 : 48,
          decoration: BoxDecoration(
            color: (context.isDarkMode) ?
            theme.colorScheme.secondary.withValues(alpha: 0.3) :
            theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: IconButton(
             icon: Icon(Icons.search, color: theme.colorScheme.primary),
             onPressed: _performSearch,
             tooltip: "Search Ranks",
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(TextEditingController controller, String hint, ThemeData theme) {
    return context.themedTextField(
      controller: controller,
      keyboardType: TextInputType.number,
      hint: hint,
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, UserModel user, int index) {
    final theme = Theme.of(context);

    final double tileHeight =
        context.screenHeight * (context.isTablet ? 0.08 : 0.06);

    final double avatarSize =
        context.screenHeight * (context.isTablet ? 0.07 : 0.05);

    final double spacing =
        context.screenHeight * (context.isTablet ? 0.015 : 0.01);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: tileHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: (theme.brightness == Brightness.dark)
              ? [
            AppColors.currentStreak.withValues(alpha: 0.5),
            AppColors.longestStreak.withValues(alpha: 0.7),
          ]
              : [
            AppColors.longestStreak.withValues(alpha: 0.2),
            AppColors.currentStreak.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          /// Rank
          Text(
            '#${index + 1}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: (theme.brightness == Brightness.dark)
                  ? AppColors.currentStreakDark
                  : AppColors.longestStreak,
            ),
          ),

          SizedBox(width: spacing),

          /// Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.onSecondary,
              border: Border.all(
                color:  theme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: AppImage(
                image: AppImageData.memory(
                  base64Decode(user.photoUrl ?? ""),
                ),
                fit: BoxFit.cover,
                placeholderBuilder: (context) {
                  return Center(
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: avatarSize * 0.35,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: avatarSize * 0.35,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: spacing),

          /// Name + Email
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? user.firstName ?? '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: (context.isDarkMode) ?
                    theme.colorScheme.onPrimary :
                    theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing * 0.2),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: (context.isDarkMode) ?
                    theme.colorScheme.onPrimary :
                    theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          /// Score
          Container(
            padding: EdgeInsets.all(avatarSize * 0.15),
            decoration: BoxDecoration(
              color: (context.isDarkMode) ?
              AppColors.longestStreak.withValues(alpha: 0.6) :
              AppColors.currentStreak.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: (context.isDarkMode) ?
                AppColors.white :
                AppColors.currentStreak.withValues(alpha: 0.4),
                width: 2
              ),
            ),
            child: Text(
              '${user.completedTasksCount}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: (context.isDarkMode) ?
                AppColors.white :
                AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
