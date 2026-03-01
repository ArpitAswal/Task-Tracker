class AppConstants {
  // App Info
  static const String appName = 'Task Tracker';
  static const String appVersion = '1.0.0';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 20;

  // Regex Patterns
  static const String emailPattern = r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$';

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);
  static const Duration longDuration = Duration(milliseconds: 800);

  // Network
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Notification
  static const String notificationChannelId = 'task_tracker_channel';
  static const String notificationChannelName = 'Task Tracker Notifications';
  static const String notificationChannelDescription =
      'Notifications for task reminders';

  // WorkManager
  static const String taskReminderWork = 'taskReminderWork';
  static const String uniqueWorkName = 'periodicTaskReminder';

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String taskBox = 'user_tasks_box';
  static const String settingsBox = 'settings_box';

  // Image Assets
  static const String loginImage = 'assets/images/login_page.png';
  static const String signupImage = 'assets/images/signup_page.png';
  static const String onboardingImage = 'assets/images/onboarding_page.png';
  static const String appLogo = 'assets/images/app_logo.png';

  // Lottie Assets
  static const String splashLottie = "assets/lottie/splash.json";
  static const String taskLottie = "assets/lottie/doneTask.json";
}

class StorageKeys {
  // User Preferences
  static const String isLoggedIn = 'isLoggedIn';
  static const String isVerifiedEmail = 'isVerifiedEmail';
  static const String userId = 'userId';
  static const String userEmail = 'userEmail';
  static const String rememberMe = 'rememberMe';
  static const String savedEmail = 'savedEmail';
  static const String savedPassword = 'savedPassword';

  // Settings
  static const String themeMode = 'themeMode';
  static const String locale = 'locale';
  static const String notificationEnabled = 'notificationEnabled';
  static const String reminderFrequency = 'reminderFrequency';
  static const String onboardingCompleted = 'onboardingCompleted';

  // FCM
  static const String fcmToken = 'fcmToken';

  // Tasks
  static const String pendingTasks = 'pending_tasks';
  static const String completedTasks = 'completed_tasks';
}

class FirebaseCollections {
  static const String users = 'TaskTrackerUsers';
  static const String tasks = 'TaskTrackerTasks';
  static const String userTasks = 'UserTasks';
  static const String notifications = 'TaskTrackerNotifications';
}

enum ThemeType { light, dark, system }

enum ReminderFrequency {
  oneHour(1),
  twoHours(2),
  fourHours(4),
  sixHours(6),
  twelveHours(12),
  twentyFourHours(24);

  final int hours;
  const ReminderFrequency(this.hours);
}
