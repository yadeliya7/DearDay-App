import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/providers.dart';
import '../core/language_provider.dart';

import 'package:poem_diary/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final poemProvider = Provider.of<PoemProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(
              AppLocalizations.of(context)!.darkMode,
              style: GoogleFonts.nunito(),
            ),
            value: themeProvider.isDarkMode,
            activeThumbColor: Colors.cyanAccent,
            onChanged: (value) {
              themeProvider.setDarkMode(value);
            },
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.settingsLanguage,
              style: GoogleFonts.nunito(),
            ),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: languageProvider.currentLocale,
                dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Nunito',
                  fontSize: 16,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                items: const [
                  DropdownMenuItem(
                    value: Locale('tr'),
                    child: Text('🇹🇷 Türkçe'),
                  ),
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('🇬🇧 English'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) languageProvider.setLocale(val);
                },
              ),
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.settingFontTitle,
              style: GoogleFonts.nunito(),
            ), // Font name usually stays same
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    [
                      'Nunito',
                      'Dancing Script',
                      'Merriweather',
                      'Lora',
                    ].contains(poemProvider.contentFontFamily)
                    ? poemProvider.contentFontFamily
                    : 'Nunito',
                dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Nunito',
                  fontSize: 16,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                items: ['Nunito', 'Dancing Script', 'Merriweather', 'Lora'].map(
                  (String font) {
                    return DropdownMenuItem<String>(
                      value: font,
                      child: Text(
                        font,
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    poemProvider.setContentFontFamily(newValue);
                  }
                },
              ),
            ),
          ),
          // Add more settings here
          const Divider(),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.blueAccent),
            title: Text(
              AppLocalizations.of(context)!.shareApp,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _shareApp(context),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    // Turkish marketing message
    final String message = AppLocalizations.of(context)!.shareMessage;
    //     + "https://example.com"; // Placeholder link

    // Share using share_plus
    try {
      Share.share(message);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.shareError(e.toString())),
        ),
      );
    }
  }
}
