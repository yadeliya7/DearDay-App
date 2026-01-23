import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/providers.dart';
import 'core/language_provider.dart';
import 'screens/main_scaffold.dart';
import 'screens/setup_profile_screen.dart';
import 'screens/intro_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poem_diary/l10n/app_localizations.dart';

import 'package:poem_diary/services/story_content_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await StoryContentService.load();

  final prefs = await SharedPreferences.getInstance();
  final bool isSetupDone = prefs.getBool('is_setup_done') ?? false;

  runApp(PoemDiaryApp(isSetupDone: isSetupDone));
}

class PoemDiaryApp extends StatelessWidget {
  final bool isSetupDone;

  const PoemDiaryApp({super.key, required this.isSetupDone});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PoemProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return MaterialApp(
            title: 'DearDay',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

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
