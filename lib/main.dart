import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:task_tracker/presentation/providers/task_provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/storage_service.dart';
import 'core/constants/app_constants.dart';

import 'core/utils/exception_handling/effect_listener.dart';
import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Initialize Storage (only once, at app start)
  await StorageService().initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),

        // Locale Provider
        ChangeNotifierProvider(create: (_) => LocaleProvider()..initialize()),

        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
          lazy: false, // This forces the provider to instantiate immediately
        ),

        ChangeNotifierProvider(create: (_) => TaskProvider()..initialize()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Localization
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // ✨ Use onGenerateRoute
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: AppRoutes.splash,
            // 🔥 builder wraps the entire Navigator tree.
            //  This makes GlobalEffectListener available everywhere.
            builder: (context, child) {
              return GlobalEffectListener(child: child!);
            },
          );
        },
      ),
    );
  }
}
