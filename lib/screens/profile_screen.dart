import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../core/providers.dart';
import '../providers/theme_provider.dart';
import 'setup_profile_screen.dart';
import 'about_screen.dart';
import 'paywall_screen.dart';

import '../core/language_provider.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import '../services/pdf_export_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodProvider = Provider.of<MoodProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),

            // Header
            Center(
              child: GestureDetector(
                onTap: () {
                  // Navigate to SetupProfileScreen for Editing
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SetupProfileScreen(isEditMode: true),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.withValues(alpha: 0.1),
                          backgroundImage: moodProvider.profileImagePath != null
                              ? FileImage(File(moodProvider.profileImagePath!))
                              : null,
                          child: moodProvider.profileImagePath == null
                              ? const Icon(
                                  LineIcons.user,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          moodProvider.userName ==
                                  AppLocalizations.of(context)!.guestUser
                              ? AppLocalizations.of(context)!.guestUser
                              : moodProvider.userName,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ...existing code...
            // --- GÖRÜNÜM (APPEARANCE) ---
            Text(
              AppLocalizations.of(context)!.sectionAppearance,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            // Theme Switch
            Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).cardColor, // Use card color instead of transparent
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.purpleAccent,
                    size: 20,
                  ),
                ),
                title: Text(
                  AppLocalizations.of(context)!.darkMode,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                value: themeProvider.isDarkMode,
                activeTrackColor: Colors.purpleAccent,
                activeThumbColor: Colors.white,
                onChanged: (val) => themeProvider.setDarkMode(val),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // App Lock Switch
            Builder(
              builder: (context) {
                final isPremium = Provider.of<PremiumProvider>(
                  context,
                ).isPremium;
                final isLocked = !isPremium;

                return GestureDetector(
                  onTap: isLocked
                      ? () {
                          // Redirect to paywall when tapped and locked
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaywallScreen(),
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LineIcons.lock,
                          color: isLocked ? Colors.grey : Colors.deepOrange,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.appLock,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: isLocked
                              ? Colors.grey
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      subtitle: Text(
                        isLocked
                            ? '🔒 ${AppLocalizations.of(context)!.premiumFeatureLocked}'
                            : AppLocalizations.of(context)!.appLockDesc,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      value: isPremium ? moodProvider.isLockEnabled : false,
                      activeTrackColor: Colors.deepOrange,
                      activeThumbColor: Colors.white,
                      onChanged: isLocked
                          ? null // Disable switch for non-premium
                          : (val) async {
                              if (val) {
                                // Check if device is supported (Secure Lock / Biometrics)
                                final authService = AuthService();
                                final isSupported = await authService
                                    .isDeviceSupported();

                                if (!mounted) return;

                                if (!isSupported) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.biometricNotAvailable,
                                      ),
                                    ),
                                  );
                                  return;
                                }
                              }
                              moodProvider.setLockEnabled(val);
                            },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Theme Selection
            Text(
              AppLocalizations.of(context)!.themeSelectionTitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Use card color
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.themeColorTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 90, // Fixed height for horizontal scroll
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildThemeCircle(
                          context,
                          themeKey: 'peach',
                          color: const Color(0xFFFF7043),
                          label: AppLocalizations.of(context)!.themePeach,
                          isSelected: themeProvider.selectedThemeKey == 'peach',
                        ),
                        const SizedBox(width: 16),
                        _buildThemeCircle(
                          context,
                          themeKey: 'coffee',
                          color: const Color(0xFF6D4C41),
                          label: AppLocalizations.of(context)!.themeCoffee,
                          isSelected:
                              themeProvider.selectedThemeKey == 'coffee',
                        ),
                        const SizedBox(width: 16),
                        _buildThemeCircle(
                          context,
                          themeKey: 'ocean',
                          color: const Color(0xFF0277BD),
                          label: AppLocalizations.of(context)!.themeOcean,
                          isSelected: themeProvider.selectedThemeKey == 'ocean',
                        ),
                        const SizedBox(width: 16),
                        _buildThemeCircle(
                          context,
                          themeKey: 'nature',
                          color: const Color(0xFF2E7D32),
                          label: AppLocalizations.of(context)!.themeNature,
                          isSelected:
                              themeProvider.selectedThemeKey == 'nature',
                        ),
                        const SizedBox(width: 16),
                        _buildThemeCircle(
                          context,
                          themeKey: 'berry',
                          color: const Color(0xFFAD1457),
                          label: AppLocalizations.of(context)!.themeBerry,
                          isSelected: themeProvider.selectedThemeKey == 'berry',
                        ),
                        const SizedBox(width: 16),
                        _buildThemeCircle(
                          context,
                          themeKey: 'midnight',
                          color: const Color(0xFF424242),
                          label: AppLocalizations.of(context)!.themeMidnight,
                          isSelected:
                              themeProvider.selectedThemeKey == 'midnight',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Language Switch
            Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).cardColor, // Use card color for visibility
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.language,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                ),
                title: Text(
                  '${AppLocalizations.of(context)!.settingsLanguage}: ${languageProvider.currentLanguage == 'tr' ? 'Türkçe' : 'English'}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                value: languageProvider.currentLanguage == 'en',
                activeTrackColor: Colors.blueAccent,
                activeThumbColor: Colors.white,
                onChanged: (val) => languageProvider.toggleLanguage(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- AYARLAR (SETTINGS) ---
            Text(
              AppLocalizations.of(context)!.sectionOther,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            // Goal Duration Setting
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Use card color
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LineIcons.bullseye,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.goalDuration,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final options = [7, 14, 21, 30];
                      // Calculate width for 4 items with spacing
                      final itemWidth = (constraints.maxWidth - (3 * 8)) / 4;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: options.map((days) {
                          final isSelected = moodProvider.goalDuration == days;
                          return InkWell(
                            onTap: () => moodProvider.setGoalDuration(days),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: itemWidth,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : (isDark
                                          ? Colors.white10
                                          : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.daysSuffix(days),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white70
                                              : Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Export to PDF (Premium Feature)
            _buildSettingTile(
              context,
              icon: Icons.picture_as_pdf,
              title: AppLocalizations.of(context)!.exportToPdf,
              subtitle: Provider.of<PremiumProvider>(context).isPremium
                  ? AppLocalizations.of(context)!.exportToPdfDesc
                  : '🔒 ${AppLocalizations.of(context)!.premiumFeatureLocked}',
              onTap: () => _exportToPdf(context),
              isDark: isDark,
              isPremiumFeature: true,
            ),

            const SizedBox(height: 10),

            // Share
            _buildSettingTile(
              context,
              icon: LineIcons.share,
              title: AppLocalizations.of(context)!.shareApp,
              onTap: () => _shareApp(context),
              isDark: isDark,
            ),

            const SizedBox(height: 10),

            // About
            _buildSettingTile(
              context,
              icon: LineIcons.infoCircle,
              title: AppLocalizations.of(context)!.about,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
              isDark: isDark,
            ),

            const SizedBox(
              height: 120,
            ), // Extra padding for bottom navigation bar
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isPremiumFeature = false,
  }) {
    final isPremium = Provider.of<PremiumProvider>(context).isPremium;
    final isLocked = isPremiumFeature && !isPremium;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Use card color
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isLocked
                ? Colors.grey
                : (isDark ? Colors.white70 : Colors.black54),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isLocked
                ? Colors.grey
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              )
            : null,
        trailing: Icon(
          isLocked ? LineIcons.lock : Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _exportToPdf(BuildContext context) async {
    final isPremium = Provider.of<PremiumProvider>(
      context,
      listen: false,
    ).isPremium;

    // Premium gate
    if (!isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PaywallScreen()),
      );
      return;
    }

    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final entries = moodProvider.journal.values.toList();

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.noEntriesForPdf,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.generatingPdf,
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final pdfBytes = await PdfExportService().generateJournalPdf(
        entries,
        userName: moodProvider.userName,
        locale: languageProvider.currentLocale.toString(),
      );

      // Save to temp file to share
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/diary_export.pdf');
      await file.writeAsBytes(pdfBytes);

      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        await Share.shareXFiles([
          XFile(file.path),
        ], text: AppLocalizations.of(context)!.exportFileName);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _shareApp(BuildContext context) {
    Share.share(AppLocalizations.of(context)!.shareMessage);
  }

  Widget _buildThemeCircle(
    BuildContext context, {
    required String themeKey,
    required Color color,
    required String label,
    required bool isSelected,
  }) {
    final isPremium = Provider.of<PremiumProvider>(context).isPremium;
    // Premium Lock Check:
    // If user is NOT premium AND theme is NOT 'midnight' -> Locked
    final isLocked = !isPremium && themeKey != 'midnight';

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaywallScreen()),
          );
        } else {
          Provider.of<ThemeProvider>(context, listen: false).setTheme(themeKey);
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isLocked ? color.withOpacity(0.5) : color,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
                if (isLocked)
                  const Icon(LineIcons.lock, color: Colors.white, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isLocked
                  ? Colors.grey
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
