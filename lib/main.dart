import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers.dart';
import 'core/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_scaffold.dart';
import 'screens/setup_profile_screen.dart';
import 'screens/intro_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poem_diary/l10n/app_localizations.dart';

import 'package:poem_diary/services/story_content_service.dart';
import 'package:poem_diary/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await StoryContentService.load();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  final prefs = await SharedPreferences.getInstance();

  // Restore daily notification if previously set
  final reminderEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
  final reminderHour = prefs.getInt('daily_reminder_hour');
  final reminderMinute = prefs.getInt('daily_reminder_minute');

  if (reminderEnabled && reminderHour != null && reminderMinute != null) {
    await NotificationService().scheduleDailyReminder(
      TimeOfDay(hour: reminderHour, minute: reminderMinute),
      'Günlük Hatırlatıcı',
      'Bugünün günlüğünü yazmayı unutma! ✨',
    );
    debugPrint('✅ Daily reminder restored: $reminderHour:$reminderMinute');
  }

  final bool isSetupDone = prefs.getBool('is_setup_done') ?? false;

  // Initialize ThemeProvider and wait for prefs to load
  final themeProvider = ThemeProvider();
  await themeProvider.loadInitialization();

  runApp(PoemDiaryApp(isSetupDone: isSetupDone, themeProvider: themeProvider));
}

class PoemDiaryApp extends StatelessWidget {
  final bool isSetupDone;
  final ThemeProvider themeProvider;

  const PoemDiaryApp({
    super.key,
    required this.isSetupDone,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => PoemProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return MaterialApp(
            title: 'DearDay',
            theme: themeProvider.currentLightTheme,
            darkTheme: themeProvider.currentDarkTheme,
            themeMode: themeProvider.themeMode,

            // Localization Setup
            // Localization Setup
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('tr')],
            locale: languageProvider.currentLocale,

            home: IntroScreen(isSetupDone: isSetupDone),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  static Widget getMainScreen(bool isSetupDone) {
    return isSetupDone ? const MainScaffold() : const SetupProfileScreen();
  }
}
