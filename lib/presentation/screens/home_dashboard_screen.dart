import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:popup_card/popup_card.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/core/utils/extensions/context_extension.dart';
import 'package:task_tracker/presentation/screens/profile/profile_screen.dart';
import 'package:task_tracker/presentation/screens/setting/setting_screen.dart';
import 'package:task_tracker/presentation/screens/task/task_screen.dart';
import 'package:task_tracker/presentation/screens/task/widgets/slider_widget.dart';
import 'package:task_tracker/presentation/screens/task/widgets/task_popup_widget.dart';
import 'package:task_tracker/presentation/screens/leaderboard/leaderboard_screen.dart';
import '../../core/services/device_settings_service.dart';
import '../../core/services/notification_service.dart';

import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';

class HomeDashboardView extends StatefulWidget {
  const HomeDashboardView({super.key});

  @override
  State<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<HomeDashboardView>
    with TickerProviderStateMixin, WidgetsBindingObserver, RestorationMixin {
  final GlobalKey<SliderDrawerState> _dKey = GlobalKey<SliderDrawerState>();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TabController _tabCnt;
  late TaskProvider _taskProvider;
  late AuthProvider _authProvider;
  late AppLocalizations? _localizations;

  // State Restoration
  final RestorableInt _restorableDrawerIndex = RestorableInt(0);

  @override
  String? get restorationId => 'home_dashboard_view';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableDrawerIndex, 'drawer_index');
    _taskProvider.drawerIndex.value = _restorableDrawerIndex.value;
  }

  void _syncDrawerIndexToRestoration() {
    _restorableDrawerIndex.value = _taskProvider.drawerIndex.value;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabCnt = TabController(length: 2, vsync: this);
    _taskProvider = context.read<TaskProvider>();
    _authProvider = context.read<AuthProvider>();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward(from: 0.0);
    _tabCnt.addListener(() {
      _taskProvider.setTabViewIndex(_tabCnt.index);
    });

    // Wire streak callback: when a task is completed, update the user's streak
    _taskProvider.onTaskCompleted = () {
      _authProvider.updateStreak();
    };
    
    // Wire streak callback: reverse streak if no other tasks remain completed today
    _taskProvider.onTaskIncomplete = (hasOtherTasks) {
      _authProvider.decrementStreakIfNoOtherTasksToday(hasOtherTasks);
    };

    // Set up sync listener to keep restoration state in sync with runtime changes
    _taskProvider.drawerIndex.addListener(_syncDrawerIndexToRestoration);

    // Startup notification permission check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermissionOnStartup();
    });
  }

  Future<void> _checkNotificationPermissionOnStartup() async {
    // Check and request notification permission on start (OS prompt if possible)
    final granted = await NotificationService.requestNotificationPermissionsIfNeeded();
    if (!granted && mounted) {
      final loc = AppLocalizations.of(context);
      final openSettings = await context.showAlertDialog(
        title: loc?.translate('notification_permission_title') ?? 'Allow Notifications',
        message: loc?.translate('notification_permission_message') ??
            'Task reminders need notification access. You can still save the task, but reminders will not appear until notifications are enabled.',
        confirmText: loc?.translate('open_settings') ?? 'Open Settings',
        cancelText: loc?.translate('later') ?? 'Later',
      );

      if (openSettings == true && mounted) {
        await DeviceSettingsService.openNotificationSettings();
      }
    }
  }

  @override
  void dispose() {
    _taskProvider.drawerIndex.removeListener(_syncDrawerIndexToRestoration);
    _restorableDrawerIndex.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    _tabCnt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await context.showExitDialog();
        if (shouldExit == true && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SliderDrawer(
            isDraggable: false,
            key: _dKey,
            animationDuration: 600,
            sliderOpenSize: (context.isTablet) ? context.screenWidth * 0.7 : context.screenWidth * 0.75,
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SliderAppBar(
              config: SliderAppBarConfig(
                backgroundColor: theme.scaffoldBackgroundColor,
                title: Center(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _taskProvider.drawerIndex,
                    builder: (context, index, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          _getTitle(index, _localizations),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
                drawerIconColor: theme.colorScheme.primary,
                drawerIconSize: (context.isTablet) ? 38 : 28
              ),
            ),
            slider: MySlider(
              onItemSelected: (index) {
                _taskProvider.drawerIndex.value = index;
                _dKey.currentState!.closeSlider();
              },
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: _taskProvider.drawerIndex,
              builder: (context, index, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: _getScreen(index),
                );
              },
            ),
          ),
        ),
        // FAB only visible on Home (index 0) — using ValueListenableBuilder
        // to avoid wrapping the entire Scaffold in Consumer<TaskProvider>
        floatingActionButton: ValueListenableBuilder<int>(
          valueListenable: _taskProvider.drawerIndex,
          builder: (context, index, _) {
            if (index != 0) return const SizedBox.shrink();
            return PopupItemLauncher(
              tag: "TaskCard",
              popUp: PopUpItem(
                tag: "TaskCard",
                color: theme.scaffoldBackgroundColor,
                padding: EdgeInsets.zero,
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: BorderSide(
                    color: theme.colorScheme.secondary,
                    width: 2.0,
                  ),
                ),
                child: AddTaskSheet(
                  provider: _taskProvider,
                  popupTitle: _localizations?.translate("add_task") ?? "",
                ),
              ),
              child: CircleAvatar(
                foregroundColor: theme.colorScheme.onSecondary,
                radius: (context.isTablet) ? 32 : 24,
                child: Icon(Icons.add_task_outlined,
                size: (context.isTablet) ? 40 : 32),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return TaskTabView(tabController: _tabCnt);
      case 1:
        return const ProfileScreen();
      case 2:
        return const LeaderboardScreen();
      case 3:
        return const SettingScreen();
      default:
        return const SizedBox();
    }
  }

  String _getTitle(int index, AppLocalizations? localizations) {
    switch (index) {
      case 0:
        return localizations?.taskScreen ?? "Task Tracker";
      case 1:
        return localizations?.profileScreen ?? "User Profile";
      case 2:
        return localizations?.translate('leaderboard') ?? "Leaderboard";
      case 3:
        return localizations?.settingScreen ?? "App Settings";
      default:
        return localizations?.defaultScreen ?? "Invalid Screen";
    }
  }
}
