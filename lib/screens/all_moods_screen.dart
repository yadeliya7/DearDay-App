import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/poem_model.dart'; // To access MoodCategory if needed, though we might define local UI data
import 'mood_results_screen.dart';
import '../helpers/localization_helper.dart';

import 'package:poem_diary/l10n/app_localizations.dart';

// Local data model for the screen
class _MoodItem {
  final String label; // Kept for reference, but UI uses localization
  final String code;
  final IconData icon;
  final List<Color> colors;

  const _MoodItem({
    required this.label,
    required this.code,
    required this.icon,
    required this.colors,
  });
}

class AllMoodsScreen extends StatelessWidget {
  const AllMoodsScreen({super.key});

  final List<_MoodItem> _moods = const [
    _MoodItem(
      label: 'Hüzünlü',
      code: 'sad',
      icon: Icons.cloud_outlined,
      colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
    ),
    _MoodItem(
      label: 'Neşeli',
      code: 'happy',
      icon: Icons.wb_sunny_outlined,
      colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
    ),
    _MoodItem(
      label: 'Romantik',
      code: 'romantic',
      icon: Icons.favorite_border,
      colors: [Color(0xFFEB3349), Color(0xFFF45C43)],
    ),
    _MoodItem(
      label: 'Gizemli',
      code: 'mystic',
      icon: Icons.nightlight_round,
      colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
    ),
    _MoodItem(
      label: 'Yorgun',
      code: 'tired',
      icon: Icons.coffee,
      colors: [Color(0xFF603813), Color(0xFFB29F94)],
    ),
    _MoodItem(
      label: 'Umutlu',
      code: 'hopeful',
      icon: Icons.spa_outlined,
      colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
    ),
    _MoodItem(
      label: 'Huzurlu',
      code: 'peaceful',
      icon: Icons.waves,
      colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
    ),
    _MoodItem(
      label: 'Nostaljik',
      code: 'nostalgic',
      icon: Icons.history_edu,
      colors: [Color(0xFFCC95C0), Color(0xFFDBD4B9)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.titleSelectMood,
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: _moods.length,
        itemBuilder: (context, index) {
          final mood = _moods[index];
          return GestureDetector(
            onTap: () {
              // Create a temporary MoodCategory to pass to results screen
              final category = MoodCategory(
                id: mood.code,
                code: mood.code,
                name: LocalizationHelper.getMoodName(context, mood.code),
                emoji: '', // Icon is used instead
                description: '',
                backgroundGradient:
                    'mystic', // Fallback, not used for list filtering
                color: mood.colors.first,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoodResultsScreen(mood: category),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: mood.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: mood.colors.first.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background Icon (Optional Decoration)
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      mood.icon,
                      size: 80,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(mood.icon, color: Colors.white, size: 36),
                        const Spacer(),
                        Text(
                          LocalizationHelper.getMoodName(context, mood.code),
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.btnSeePoems,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
