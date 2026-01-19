import 'package:flutter/material.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/providers.dart';
import '../models/daily_entry_model.dart';
import '../models/poem_model.dart';

import 'mood_entry_dialog.dart';

class HomeMoodSelector extends StatefulWidget {
  final DailyEntry? todayEntry;

  const HomeMoodSelector({super.key, required this.todayEntry});

  @override
  State<HomeMoodSelector> createState() => _HomeMoodSelectorState();
}

class _HomeMoodSelectorState extends State<HomeMoodSelector> {
  Color _activeMoodColor = Colors.grey;
  String _selectedMoodCode = '';

  @override
  void initState() {
    super.initState();
    if (widget.todayEntry != null) {
      _selectedMoodCode = widget.todayEntry!.moodCode;
    }
  }

  @override
  void didUpdateWidget(covariant HomeMoodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.todayEntry != oldWidget.todayEntry) {
      if (widget.todayEntry != null) {
        _selectedMoodCode = widget.todayEntry!.moodCode;
      }
    }
  }

  String _getMoodName(BuildContext context, String code) {
    final loc = AppLocalizations.of(context)!;
    switch (code) {
      case 'happy':
        return loc.moodHappy;
      case 'sad':
        return loc.moodSad;
      case 'romantic':
        return loc.moodRomantic;
      case 'mystic':
        return loc.moodMystic;
      case 'tired':
        return loc.moodTired;
      case 'hopeful':
        return loc.moodHopeful;
      case 'peaceful':
        return loc.moodPeaceful;
      case 'nostalgic':
        return loc.moodNostalgic;
      case 'angry':
        return loc.moodAngry;
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ensure initial color matches selection if set
    if (_activeMoodColor == Colors.grey && _selectedMoodCode.isNotEmpty) {
      final mood = moodProvider.moods.firstWhere(
        (m) => m.code == _selectedMoodCode,
        orElse: () => MoodCategory(
          id: '',
          code: '',
          name: '',
          emoji: '',
          description: '',
          backgroundGradient: '',
          color: Colors.grey,
        ),
      );
      if (mood.code.isNotEmpty) {
        _activeMoodColor = mood.color;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.checkInPrompt,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: moodProvider.moods.where((m) => m.code.isNotEmpty).map((
              mood,
            ) {
              final isSelected = _selectedMoodCode == mood.code;
              return GestureDetector(
                onTap: () {
                  // 1. Immediate Visual Update
                  setState(() {
                    _activeMoodColor = mood.color;
                    _selectedMoodCode = mood.code;
                  });

                  // 2. Open Dialog
                  showMoodEntryDialog(
                    context,
                    date: DateTime.now(),
                    provider: moodProvider,
                    currentMood: mood.code,
                    currentNote: widget.todayEntry?.note,
                    currentMedia: widget.todayEntry?.mediaPaths ?? [],
                    currentActivities: widget.todayEntry?.activities ?? {},
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blueAccent.withValues(alpha: 0.1)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.grey.withValues(alpha: 0.3),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.blueAccent.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMoodName(context, mood.code),
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
