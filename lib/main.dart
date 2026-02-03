import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers.dart';
import 'core/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_scaffold.dart';
import 'screens/setup_profile_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/auth_lock_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poem_diary/l10n/app_localizations.dart';

import 'package:poem_diary/services/story_content_service.dart';
import 'package:poem_diary/services/notification_service.dart';
import 'package:poem_diary/services/purchase_service.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'services/app_lock_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... (rest of main unchanged)

  // Initialize Hive
  await Hive.initFlutter();

  await initializeDateFormatting();
  await StoryContentService.load();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  // Initialize RevenueCat
  await PurchaseService().init();

  final prefs = await SharedPreferences.getInstance();

  // Restore daily notification if previously set
  final reminderEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
  final reminderHour = prefs.getInt('daily_reminder_hour');
  final reminderMinute = prefs.getInt('daily_reminder_minute');

  if (reminderEnabled && reminderHour != null && reminderMinute != null) {
    // Determine language logic
    final String languageCode = prefs.getString('language_code') ?? 'tr';
    String nTit;
    String nBody;

    if (languageCode == 'tr') {
      nTit = "Günün nasıl geçti? 🌙";
      nBody = "Kendine bir not bırakmak ister misin?";
    } else {
      nTit = "How was your day? 🌙";
      nBody = "Would you like to leave a note for yourself?";
    }

    await NotificationService().scheduleDailyReminder(
      TimeOfDay(hour: reminderHour, minute: reminderMinute),
      nTit,
      nBody,
    );
    debugPrint(
      '✅ Daily reminder restored: $reminderHour:$reminderMinute ($languageCode)',
    );
  }

  final bool isSetupDone = prefs.getBool('is_setup_done') ?? false;

  // Initialize ThemeProvider and wait for prefs to load
  final themeProvider = ThemeProvider();
  await themeProvider.loadInitialization();

  runApp(PoemDiaryApp(isSetupDone: isSetupDone, themeProvider: themeProvider));
}

class PoemDiaryApp extends StatefulWidget {
  final bool isSetupDone;
  final ThemeProvider themeProvider;

  const PoemDiaryApp({
    super.key,
    required this.isSetupDone,
    required this.themeProvider,
  });

  @override
  State<PoemDiaryApp> createState() => _PoemDiaryAppState();

  static Widget getMainScreen(bool isSetupDone) {
    return isSetupDone ? const MainScaffold() : const SetupProfileScreen();
  }
}

class _PoemDiaryAppState extends State<PoemDiaryApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Check if App Lock is enabled AND user is premium
      final prefs = await SharedPreferences.getInstance();
      final isLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
      final isPremium = prefs.getBool('is_premium') ?? false;

      // DEBUG: Print status
      debugPrint(
        '🔐 [MainActivity] App Resumed - Lock Enabled: $isLockEnabled, Premium: $isPremium',
      );

      // Check Grace Period & Visibility via Manager
      // If we recently authenticated OR the screen is already visible, don't show it again.
      if (!AppLockManager.shouldRequireAuth() ||
          AppLockManager.isAuthScreenVisible) {
        debugPrint(
          '⏭️ [MainActivity] Skipping auth (grace period or already visible)',
        );
        return;
      }

      // Only show auth if BOTH lock is enabled AND user is premium
      if (isLockEnabled && isPremium) {
        debugPrint('✅ [MainActivity] Showing auth lock screen');
        AppLockManager.isAuthScreenVisible = true;

        // Wait for auth result
        if (navigatorKey.currentState != null) {
          final result = await navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (_) => const AuthLockScreen()),
          );

          // If authentication was successful, update the timestamp
          if (result == true) {
            AppLockManager.recordSuccess();
          }
        }

        AppLockManager.isAuthScreenVisible = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ChangeNotifierProvider(create: (_) => PoemProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey, // KEY ADDED HERE
            title: 'DearDay',
            theme: themeProvider.currentLightTheme,
            darkTheme: themeProvider.currentDarkTheme,
            themeMode: themeProvider.themeMode,

            // Localization Setup
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('tr')],
            locale: languageProvider.currentLocale,

            home: IntroScreen(isSetupDone: widget.isSetupDone),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
