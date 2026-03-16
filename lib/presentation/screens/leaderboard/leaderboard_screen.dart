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
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _startIdxController = TextEditingController();
  final TextEditingController _endIdxController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initLeaderboardStream();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isSearching) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      context.read<AuthProvider>().loadMoreLeaderboardUsers();
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
      context.showErrorToast("Invalid search rank indices.");
    }
  }

  void _clearSearch() {
    FocusScope.of(context).unfocus();
    _startIdxController.clear();
    _endIdxController.clear();
    setState(() {
      _isSearching = false;
    });
    // Need to wait until list view is rebuilt to attach the controller before jumping
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.isTablet ? 24 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(theme, loc),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.isLeaderboardLoading) {
                    return ListView.builder(
                      itemCount: (MediaQuery.of(context).size.width > 600
                          ? 10
                          : 5),
                      itemBuilder: (context, index) =>
                          const LeaderboardTileShimmer(),
                    );
                  }

                  final allUsers = authProvider.leaderboardUsers;

                  if (allUsers.isEmpty) {
                    return Center(
                      child: Text(
                        loc?.translate('no_users_found') ?? 'No users found.',
                        style: theme.textTheme.displayMedium,
                      ),
                    );
                  }

                  List<UserModel> displayUsers = [];
                  int startRank = 1;
                  final authItemsToShow = authProvider.leaderboardItemsToShow;

                  if (_isSearching) {
                    final start =
                        int.tryParse(_startIdxController.text.trim()) ?? 1;
                    final end =
                        int.tryParse(_endIdxController.text.trim()) ?? 10;
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
                    final takeCount = authItemsToShow > allUsers.length
                        ? allUsers.length
                        : authItemsToShow;
                    displayUsers = allUsers.take(takeCount).toList();
                    startRank = 1;
                  }

                  if (displayUsers.isEmpty) {
                    return Center(
                      child: Text(
                        _isSearching
                            ? loc?.translate('index_not_exist') ??
                                  'The searching ranks range does not exist'
                            : loc?.translate('no_users_found') ??
                                  'No users found.',
                        style: theme.textTheme.displayMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 40),
                    itemCount:
                        displayUsers.length +
                        (_isSearching
                            ? 0
                            : (authItemsToShow < allUsers.length ? 1 : 0)),
                    itemBuilder: (context, index) {
                      if (!_isSearching && index == displayUsers.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: LeaderboardTileShimmer()),
                        );
                      }
                      final user = displayUsers[index];
                      return _buildLeaderboardTile(
                        context,
                        user,
                        startRank + index - 1,
                      );
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
        SizedBox(width: (context.screenWidth * 0.02)),
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
            height: (context.isTablet) ? 60 : 44,
            width: (context.isTablet) ? 60 : 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.clear,
                color: theme.colorScheme.error,
                size: (context.isTablet) ? 36 : 24,
              ),
              onPressed: _clearSearch,
              tooltip: "Clear Search",
            ),
          ),
        const SizedBox(width: 8),
        Container(
          height: (context.isTablet) ? 60 : 44,
          width: (context.isTablet) ? 60 : 44,
          decoration: BoxDecoration(
            color: (context.isDarkMode)
                ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: IconButton(
            icon: Icon(
              Icons.search,
              color: theme.colorScheme.primary,
              size: (context.isTablet) ? 36 : 24,
            ),
            onPressed: _performSearch,
            tooltip: "Search Ranks",
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(
    TextEditingController controller,
    String hint,
    ThemeData theme,
  ) {
    return context.themedTextField(
      controller: controller,
      keyboardType: TextInputType.number,
      hint: hint,
    );
  }

  Widget _buildLeaderboardTile(
    BuildContext context,
    UserModel user,
    int index,
  ) {
    final theme = Theme.of(context);
    final double tileHeight = context.screenHeight * (0.08);

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
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            ),
            child: RepaintBoundary(
              child: ClipOval(
                child: Builder(
                  builder: (context) {
                    final decodedBytes = context
                        .read<AuthProvider>()
                        .getDecodedPhoto(user);
                    Widget initialsPlaceholder = Center(
                      child: Text(
                        user.initials,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: avatarSize * 0.35,
                        ),
                      ),
                    );

                    if (decodedBytes != null && decodedBytes.isNotEmpty) {
                      return AppImage(
                        image: AppImageData.memory(decodedBytes),
                        fit: BoxFit.cover,
                        placeholderBuilder: (context) => initialsPlaceholder,
                        errorBuilder: (context, error, stackTrace) =>
                            initialsPlaceholder,
                      );
                    } else {
                      return initialsPlaceholder;
                    }
                  },
                ),
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
                    color: (context.isDarkMode)
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing * 0.2),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: (context.isDarkMode)
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
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
              color: (context.isDarkMode)
                  ? AppColors.longestStreak.withValues(alpha: 0.6)
                  : AppColors.currentStreak.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: (context.isDarkMode)
                    ? AppColors.white
                    : AppColors.currentStreak.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Text(
              '${user.completedTasksCount}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: (context.isDarkMode) ? AppColors.white : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
