import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('tr'); // Default to Turkish

  LanguageProvider() {
    _loadLocale();
  }

  Locale get currentLocale => _currentLocale;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  void toggleLanguage() async {
    final newLocale = _currentLocale.languageCode == 'tr'
        ? const Locale('en')
        : const Locale('tr');

    setLocale(newLocale);
  }

  void setLocale(Locale locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
    }
  }

  // Legacy support for string-based checks (optional, helps transition)
  String get currentLanguage => _currentLocale.languageCode;
}
