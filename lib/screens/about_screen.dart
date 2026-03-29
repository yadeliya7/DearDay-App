import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:poem_diary/l10n/app_localizations.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${info.version}';
    });
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'solyymos@gmail.com',
      query: 'subject=Mood Tracker Contact&body=Merhaba,',
    );
    try {
      if (!await launchUrl(emailLaunchUri)) {
        throw 'Could not launch $emailLaunchUri';
      }
    } catch (e) {
      debugPrint("Error launching email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.aboutTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/logo.png', // Assuming logo exists, fall back to icon if needed
                height: 80,
                width: 80,
                errorBuilder: (ctx, _, __) => Icon(
                  LineIcons.book,
                  size: 60,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "DearDay",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              _version,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey.withOpacity(0.2)),
            const SizedBox(height: 24),

            // Content Sections
            _buildSection(
              context,
              AppLocalizations.of(context)!.aboutWhatTitle,
              AppLocalizations.of(context)!.aboutWhatDesc,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.aboutPrivacyTitle,
              AppLocalizations.of(context)!.aboutPrivacyDesc,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.aboutContentTitle,
              AppLocalizations.of(context)!.aboutContentDesc,
            ),
            _buildSection(
              context,
              AppLocalizations.of(context)!.aboutLegalTitle,
              AppLocalizations.of(context)!.aboutLegalDesc,
            ),

            const SizedBox(height: 40),

            // Footer
            Text(
              AppLocalizations.of(context)!.aboutMadeWith,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _launchEmail,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LineIcons.envelope,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.aboutContact,
                      style: GoogleFonts.poppins(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String body, {
    bool isBold = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          // Simple bold handling for "offline" part if needed, or just plain text
          // Since existing text has markdown-like syntax (**), let's render it simply for now
          // or use RichText if we really want to parse it.
          // For simplicity given the requirement, simple Text is sufficient,
          // but I'll strip the ** markers if logic allows, or just display as is.
          // The query asked for "**çevrimdışı (offline)**" so I will leave it or display it clearly.
          Text(
            body.replaceAll(
              '**',
              '',
            ), // Removing markdown markers for cleaner plain text
            style: GoogleFonts.poppins(
              fontSize: 14, // Slightly adjusted for Poppins readability
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
