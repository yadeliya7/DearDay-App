import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/providers.dart';
import '../core/language_provider.dart';
import '../helpers/localization_helper.dart';

import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/poem_model.dart';
import '../models/daily_entry_model.dart';
import '../widgets/mood_entry_dialog.dart';
import '../widgets/monthly_mood_share_card.dart';
import 'package:line_icons/line_icons.dart';

enum CalendarViewMode { month, year }

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  CalendarViewMode _currentView = CalendarViewMode.month; // Added State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    // Determine theme brightness for text colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final offColor = isDarkMode ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor, // Explicit background color
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.calendarTitle,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(_isSharing ? Icons.hourglass_empty : Icons.ios_share),
            onPressed: () => _isSharing ? null : _shareMonth(context),
            tooltip: 'Ayı Paylaş',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<MoodProvider>(
          builder: (context, moodProvider, child) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1. View Switcher (Month / Year)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<CalendarViewMode>(
                        backgroundColor: isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                        thumbColor: isDarkMode
                            ? const Color(0xFF6C63FF)
                            : Colors.white,
                        groupValue: _currentView,
                        onValueChanged: (CalendarViewMode? value) {
                          if (value != null) {
                            setState(() {
                              _currentView = value;
                            });
                          }
                        },
                        children: {
                          CalendarViewMode.month: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 20,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.viewMonth,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: _currentView == CalendarViewMode.month
                                    ? (isDarkMode ? Colors.white : Colors.black)
                                    : (isDarkMode ? Colors.grey : Colors.black54),
                              ),
                            ),
                          ),
                          CalendarViewMode.year: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 20,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.viewYear,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: _currentView == CalendarViewMode.year
                                    ? (isDarkMode ? Colors.white : Colors.black)
                                    : (isDarkMode ? Colors.grey : Colors.black54),
                              ),
                            ),
                          ),
                        },
                      ),
                    ),
                  ),

                  // 2. Calendar Content (Month or Year)
                  if (_currentView == CalendarViewMode.year)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      child: _buildYearView(context, moodProvider),
                    )
                  else
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1C1C1E)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isDarkMode
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.2,
                              ), // Fixed alpha type
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.08,
                              ), // Fixed alpha type
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: TableCalendar(
                    locale:
                        Provider.of<LanguageProvider>(
                              context,
                            ).currentLanguage ==
                            'tr'
                        ? 'tr_TR'
                        : 'en_US',
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      // Future Check
                      if (selectedDay.isAfter(DateTime.now())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.futureWarning,
                              style: GoogleFonts.nunito(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      // Open Entry Dialog directly if no entry exists, or Details if exists
                      final hasEntry =
                          moodProvider.getEntryForDate(selectedDay) != null;

                      if (hasEntry) {
                        _showDayDetails(context, selectedDay, moodProvider);
                      } else {
                        showMoodEntryDialog(
                          context,
                          date: selectedDay,
                          provider: moodProvider,
                        );
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },

                    // STYLING UPDATES
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.nunito(color: offColor),
                      weekendStyle: GoogleFonts.nunito(color: Colors.redAccent),
                    ),

                    calendarStyle: CalendarStyle(
                      defaultTextStyle: GoogleFonts.nunito(color: textColor),
                      weekendTextStyle: GoogleFonts.nunito(
                        color: Colors.redAccent,
                      ),
                      outsideTextStyle: GoogleFonts.nunito(color: offColor),
                      todayTextStyle: GoogleFonts.nunito(
                        color: isDarkMode ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      todayDecoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white
                            : Colors.black, // White Moon
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.pinkAccent,
                        shape: BoxShape.circle,
                      ),
                    ),

                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      leftChevronIcon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withAlpha(25)
                              : Colors.black.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          size: 20,
                        ),
                      ),
                      rightChevronIcon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withAlpha(25)
                              : Colors.black.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),

                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return _buildMoodCell(context, day, moodProvider);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return _buildMoodCell(
                          context,
                          day,
                          moodProvider,
                          isSelected: true,
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildMoodCell(
                          context,
                          day,
                          moodProvider,
                          isToday: true,
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 20),
              // Legend - Wrapped Mood Chips (All visible)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: moodProvider.moods
                      .where((m) => m.code.isNotEmpty)
                      .map((mood) {
                        final color = _getMoodColor(mood.code);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(
                              alpha: isDarkMode ? 0.2 : 0.3,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withValues(
                                alpha: isDarkMode ? 0.5 : 0.6,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getMoodName(context, mood.code),
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
              ),

              const SizedBox(height: 30),
              // Monthly Summary
              _buildMonthlySummary(context, moodProvider, isDarkMode),
              const SizedBox(height: 30),

              // Daily Check-in Button (if not focused on past)
              // Actually, HomeScreen handles the check-in mostly, but nice to have here too maybe?
              // Leaving it clean for now as requested.
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    try {
      final langCode = Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).currentLanguage;
      final locale = langCode == 'tr' ? 'tr_TR' : 'en_US';
      // Create a dummy date for the month
      final date = DateTime(2024, month, 1);
      return DateFormat('MMMM', locale).format(date);
    } catch (e) {
      return '';
    }
  }

  Color _getMoodColor(String moodCode) {
    switch (moodCode) {
      case 'sad':
        return Colors.blue[300]!;
      case 'happy':
        return Colors.yellow[300]!; // Darker yellow for visibility
      case 'romantic':
        return Colors.pink[300]!;
      case 'mystic':
        return Colors.purple[300]!;
      case 'tired':
        return Colors.grey[400]!;
      case 'hopeful':
        return Colors.green[300]!;
      case 'peaceful':
        return Colors.cyan[300]!;
      case 'nostalgic':
        return Colors.orange[300]!;
      case 'angry':
        return Colors.redAccent;
      default:
        return Colors.blueGrey[200]!;
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

  Widget _buildMonthlySummary(
    BuildContext context,
    MoodProvider provider,
    bool isDark,
  ) {
    // Calculate dominant mood for current focused month
    final monthEntries = provider.journal.values.where((entry) {
      return entry.date.year == _focusedDay.year &&
          entry.date.month == _focusedDay.month;
    }).toList();

    if (monthEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Count mood occurrences
    final moodCounts = <String, int>{};
    for (var entry in monthEntries) {
      moodCounts[entry.moodCode] = (moodCounts[entry.moodCode] ?? 0) + 1;
    }

    // Find dominant mood
    String? dominantMoodCode;
    int maxCount = 0;
    moodCounts.forEach((code, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMoodCode = code;
      }
    });

    if (dominantMoodCode == null) {
      return const SizedBox.shrink();
    }

    final dominantMood = provider.moods.firstWhere(
      (m) => m.code == dominantMoodCode,
      orElse: () => provider.moods.first,
    );

    // final loc = AppLocalizations.of(context)!;
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final moodName = _getMoodName(context, dominantMood.code);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            lang.currentLanguage == 'tr'
                ? 'Bu ayın modu: '
                : 'This month\'s mood: ',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: isDark ? Colors.grey : Colors.black54,
            ),
          ),
          Text(
            moodName,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _getMoodColor(dominantMood.code),
            ),
          ),
          const SizedBox(width: 4),
          Text(dominantMood.emoji, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Future<void> _shareMonth(BuildContext context) async {
    setState(() => _isSharing = true);
    final provider = Provider.of<MoodProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    try {
      // 1. Gather Data for the Card
      final Map<int, MoodCategory> dailyMoods = {};

      final daysInMonth = DateUtils.getDaysInMonth(
        _focusedDay.year,
        _focusedDay.month,
      );

      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(_focusedDay.year, _focusedDay.month, i);
        final entry = provider.getEntryForDate(date);

        if (entry != null) {
          // Mood
          final mood = provider.moods.firstWhere(
            (m) => m.code == entry.moodCode,
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
            dailyMoods[i] = mood;
          }
        }
      }

      // 2. Build Legend Definition
      final Map<String, MoodCategory> definitions = {
        for (var m in provider.moods.where((x) => x.code.isNotEmpty)) m.code: m,
      };

      // 3. Build Localized Labels
      final Map<String, String> localizedLabels = {
        for (var m in provider.moods.where((x) => x.code.isNotEmpty))
          m.code: _getMoodName(context, m.code),
      };

      // 4. Generate Image
      final imageBytes = await _screenshotController.captureFromWidget(
        MonthlyMoodShareCard(
          month: _focusedDay,
          dailyMoods: dailyMoods,
          moodDefinitions: definitions,
          localizedLabels: localizedLabels,
          locale: lang.currentLanguage == 'tr' ? 'tr_TR' : 'en_US',
          footerText: "${AppLocalizations.of(context)!.createdWith} Habitual",
        ),
        delay: const Duration(milliseconds: 100),
        context: context,
      );

      // 4. Save to Temp
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/mood_calendar_${_focusedDay.year}_${_focusedDay.month}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // 5. Share
      if (!mounted) return;
      await Share.shareXFiles([
        XFile(imagePath),
      ], text: 'Bu ayki duygu takvimim! 📅✨ #PoemDiary');
    } catch (e) {
      debugPrint('Share Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Paylaşım hatası: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showDayDetails(
    BuildContext context,
    DateTime date,
    MoodProvider provider,
  ) {
    final entry = provider.getEntryForDate(date);
    if (entry == null && provider.getMoodForDate(date) == null) {
      // No Data
      return;
    }

    // Prepare Data
    final moodCode = entry?.moodCode ?? provider.getMoodForDate(date);
    final note = entry?.note;

    // Find Mood Object
    final mood = provider.moods.firstWhere(
      (m) => m.code == moodCode,
      orElse: () => MoodCategory(
        id: '',
        code: '',
        name: AppLocalizations.of(context)!.moodUnknown,
        emoji: '❓',
        description: '',
        backgroundGradient: '',
        color: Colors.grey,
      ),
    );

    if (mood.code.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // 1. Sticky Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dayDetail,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close details
                          showMoodEntryDialog(
                            context,
                            date: date,
                            provider: provider,
                            currentMood: moodCode,
                            currentNote: note,
                            currentMedia: entry?.mediaPaths ?? [],
                            currentActivities: entry?.activities ?? {},
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // 2. Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Mood Info
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _getMoodColor(mood.code),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                mood.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getMoodName(context, mood.code),
                                  style: GoogleFonts.nunito(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  "${date.day} ${_getMonthName(date.month)} ${date.year}",
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Activity Chips
                        if (entry != null && entry.activities.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: _buildWrapIcons(entry),
                          ),

                        // Note Content
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black12 : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            note != null && note.isNotEmpty
                                ? note
                                : AppLocalizations.of(context)!.noNote,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              height: 1.5,
                              fontStyle: note != null && note.isNotEmpty
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),

                        // Media Display
                        if (entry?.mediaPaths != null &&
                            entry!.mediaPaths.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: entry.mediaPaths.length,
                                itemBuilder: (context, index) {
                                  final path = entry.mediaPaths[index];
                                  final ext = path
                                      .split('.')
                                      .last
                                      .toLowerCase();
                                  final isImage = [
                                    'jpg',
                                    'jpeg',
                                    'png',
                                    'heic',
                                    'webp',
                                  ].contains(ext);

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!isImage) return;
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: InteractiveViewer(
                                              child: Image.file(File(path)),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: buildMediaThumbnail(path),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildMoodCell(
    BuildContext context,
    DateTime day,
    MoodProvider provider, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final String? moodCode = provider.getMoodForDate(day);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // "White Moon" Logic
    final todayColor = isDarkMode ? Colors.white : Colors.black;
    final todayTextColor = isDarkMode ? Colors.black : Colors.white;

    if (moodCode != null) {
      final color = _getMoodColor(moodCode);

      // CRITICAL: Determine text color based on mood color luminance
      final luminance = color.computeLuminance();
      final cellTextColor = luminance > 0.5 ? Colors.black87 : Colors.white;

      // Adjust opacity and glow for theme
      final bgAlpha = isDarkMode ? 0.3 : 0.5;
      final shadowAlpha = isDarkMode ? 0.5 : 0.3;
      final blurRadius = isDarkMode ? 8.0 : 4.0;
      final borderWidth = isDarkMode ? 2.0 : 1.5;

      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: bgAlpha),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: shadowAlpha),
              blurRadius: blurRadius,
              spreadRadius: isDarkMode ? 1 : 0.5,
            ),
          ],
        ),
        child: Text(
          '${day.day}',
          style: GoogleFonts.nunito(
            color: cellTextColor, // Dynamic based on luminance
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // No Mood
    if (isToday) {
      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: todayColor, // Solid White/Black
          shape: BoxShape.circle,
        ),
        child: Text(
          '${day.day}',
          style: GoogleFonts.nunito(
            color: todayTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (isSelected) {
      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          shape: BoxShape.circle,
        ),
        child: Text(
          '${day.day}',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return null; // Use default
  }

  // Copied from HomeTab for consistency. Consider moving to a shared widget.
  Widget _buildWrapIcons(DailyEntry entry) {
    List<Widget> chips = [];

    Widget makeChip(IconData icon, Color color, String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final act = entry.activities;

    if (act['sleep'] == 'good') {
      chips.add(
        makeChip(
          LineIcons.sun,
          Colors.orange,
          LocalizationHelper.getActivityName(context, 'sleep', 'good'),
        ),
      );
    }
    if (act['sleep'] == 'medium') {
      chips.add(
        makeChip(
          LineIcons.cloudWithMoon,
          Colors.blueGrey,
          LocalizationHelper.getActivityName(context, 'sleep', 'medium'),
        ),
      );
    }
    if (act['sleep'] == 'bad') {
      chips.add(
        makeChip(
          LineIcons.moon,
          Colors.indigo,
          LocalizationHelper.getActivityName(context, 'sleep', 'bad'),
        ),
      );
    }

    if (act['weather'] == 'sunny') {
      chips.add(
        makeChip(
          LineIcons.sun,
          Colors.amber,
          LocalizationHelper.getActivityName(context, 'weather', 'sunny'),
        ),
      );
    }
    if (act['weather'] == 'rainy') {
      chips.add(
        makeChip(
          LineIcons.cloudWithRain,
          Colors.blue,
          LocalizationHelper.getActivityName(context, 'weather', 'rainy'),
        ),
      );
    }
    if (act['weather'] == 'cloudy') {
      chips.add(
        makeChip(
          LineIcons.cloud,
          Colors.grey,
          LocalizationHelper.getActivityName(context, 'weather', 'cloudy'),
        ),
      );
    }
    if (act['weather'] == 'snowy') {
      chips.add(
        makeChip(
          LineIcons.snowflake,
          Colors.lightBlueAccent,
          LocalizationHelper.getActivityName(context, 'weather', 'snowy'),
        ),
      );
    }

    // LIST HELPERS
    List<String> listFrom(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? [];

    final health = listFrom(act['health']);
    if (health.contains('sport')) {
      chips.add(
        makeChip(
          LineIcons.running,
          Colors.green,
          LocalizationHelper.getActivityName(context, 'sport'),
        ),
      );
    }
    if (health.contains('healthy_food')) {
      chips.add(
        makeChip(
          LineIcons.carrot,
          Colors.greenAccent,
          LocalizationHelper.getActivityName(context, 'healthy_food'),
        ),
      );
    }
    if (health.contains('fast_food')) {
      chips.add(
        makeChip(
          LineIcons.hamburger,
          Colors.orangeAccent,
          LocalizationHelper.getActivityName(context, 'fast_food'),
        ),
      );
    }
    if (health.contains('water')) {
      chips.add(
        makeChip(
          LineIcons.tint,
          Colors.blueAccent,
          LocalizationHelper.getActivityName(context, 'water'),
        ),
      );
    }

    final social = listFrom(act['social']);
    if (social.contains('friends')) {
      chips.add(
        makeChip(
          LineIcons.userFriends,
          Colors.purple,
          LocalizationHelper.getActivityName(context, 'friends'),
        ),
      );
    }
    if (social.contains('family')) {
      chips.add(
        makeChip(
          LineIcons.home,
          Colors.brown,
          LocalizationHelper.getActivityName(context, 'family'),
        ),
      );
    }
    if (social.contains('party')) {
      chips.add(
        makeChip(
          LineIcons.cocktail,
          Colors.deepPurple,
          LocalizationHelper.getActivityName(context, 'party'),
        ),
      );
    }
    if (social.contains('partner')) {
      chips.add(
        makeChip(
          LineIcons.heartAlt,
          Colors.red,
          LocalizationHelper.getActivityName(context, 'partner'),
        ),
      );
    }

    final hobbies = listFrom(act['hobbies']);
    if (hobbies.contains('gaming')) {
      chips.add(
        makeChip(
          LineIcons.gamepad,
          Colors.indigoAccent,
          LocalizationHelper.getActivityName(context, 'gaming'),
        ),
      );
    }
    if (hobbies.contains('reading')) {
      chips.add(
        makeChip(
          LineIcons.book,
          Colors.brown,
          LocalizationHelper.getActivityName(context, 'reading'),
        ),
      );
    }
    if (hobbies.contains('movie')) {
      chips.add(
        makeChip(
          LineIcons.video,
          Colors.redAccent,
          LocalizationHelper.getActivityName(context, 'movie'),
        ),
      );
    }
    if (hobbies.contains('art')) {
      chips.add(
        makeChip(
          LineIcons.palette,
          Colors.pinkAccent,
          LocalizationHelper.getActivityName(context, 'art'),
        ),
      );
    }

    final chores = listFrom(act['chores']);
    if (chores.contains('cleaning')) {
      chips.add(
        makeChip(
          LineIcons.broom,
          Colors.teal,
          LocalizationHelper.getActivityName(context, 'cleaning'),
        ),
      );
    }
    if (chores.contains('shopping')) {
      chips.add(
        makeChip(
          LineIcons.shoppingCart,
          Colors.orange,
          LocalizationHelper.getActivityName(context, 'shopping'),
        ),
      );
    }
    if (chores.contains('laundry')) {
      chips.add(
        makeChip(
          LineIcons.tShirt,
          Colors.blueGrey,
          LocalizationHelper.getActivityName(context, 'laundry'),
        ),
      );
    }
    if (chores.contains('cooking')) {
      chips.add(
        makeChip(
          LineIcons.utensils,
          Colors.deepOrange,
          LocalizationHelper.getActivityName(context, 'cooking'),
        ),
      );
    }

    final selfcare = listFrom(act['selfcare']);
    if (selfcare.contains('manicure')) {
      chips.add(
        makeChip(
          LineIcons.handHoldingHeart,
          Colors.pink,
          LocalizationHelper.getActivityName(context, 'manicure'),
        ),
      );
    }
    if (selfcare.contains('skincare')) {
      chips.add(
        makeChip(
          LineIcons.spa,
          Colors.lightGreen,
          LocalizationHelper.getActivityName(context, 'skincare'),
        ),
      );
    }
    if (selfcare.contains('hair')) {
      chips.add(
        makeChip(
          LineIcons.cut,
          Colors.brown,
          LocalizationHelper.getActivityName(context, 'hair'),
        ),
      );
    }

    if (act['no_smoking'] == true) {
      chips.add(
        makeChip(
          LineIcons.smokingBan,
          Colors.redAccent,
          LocalizationHelper.getActivityName(context, 'no_smoking'),
        ),
      );
    }
    if (act['social_media_detox'] == true) {
      chips.add(
        makeChip(
          LineIcons.mobilePhone,
          Colors.blueGrey,
          LocalizationHelper.getActivityName(context, 'social_media_detox'),
        ),
      );
    }
    if (act['meditation'] == true) {
      chips.add(
        makeChip(
          LineIcons.spa,
          Colors.purpleAccent,
          LocalizationHelper.getActivityName(context, 'meditation'),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: chips,
    );
  }

  Widget _buildYearView(BuildContext context, MoodProvider moodProvider) {
    // 1. Check Premium Status
    final isPremium = Provider.of<PremiumProvider>(context).isPremium;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // The Actual Grid
        _buildYearlyGrid(context, moodProvider, isDarkMode),

        // Premium Lock Overlay
        if (!isPremium)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.6),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LineIcons.lock,
                        size: 48,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.yearPixelsTitle,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Trigger Premium Purchase Flow
                          // For now, toggle premium for testing if debugging, or show distinct dialog
                          // Assuming we have a way to open premium screen or just toggle for test
                          Provider.of<PremiumProvider>(
                            context,
                            listen: false,
                          ).togglePremium();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.unlockYearView,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildYearlyGrid(
    BuildContext context,
    MoodProvider moodProvider,
    bool isDarkMode,
  ) {
    // 3 Columns x 4 Rows = 12 Months

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          return _buildMiniMonth(
            context,
            moodProvider,
            index + 1,
            isDarkMode,
          );
        },
      ),
    );
  }

  Widget _buildMiniMonth(
    BuildContext context,
    MoodProvider moodProvider,
    int month,
    bool isDarkMode,
  ) {
    // Month Name
    final date = DateTime(DateTime.now().year, month, 1);
    final monthName = DateFormat.MMM(
      AppLocalizations.of(context)!.localeName,
    ).format(date);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dot size based on available width
        double dotSize = (constraints.maxWidth / 7) - 2;
        if (dotSize > 8) dotSize = 8; // Max size cap
        if (dotSize < 4) dotSize = 4; // Min size

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              monthName,
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // Dots
            Flexible(
              child: Center(
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  alignment: WrapAlignment.center,
                  children: List.generate(31, (dayIndex) {
                    return _buildMiniDot(
                      context,
                      moodProvider,
                      month,
                      dayIndex + 1,
                      isDarkMode,
                      dotSize,
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniDot(
    BuildContext context,
    MoodProvider moodProvider,
    int month,
    int day,
    bool isDarkMode,
    double size,
  ) {
    final year = DateTime.now().year;
    bool isValidDate = true;
    try {
      final d = DateTime(year, month, day);
      if (d.month != month || d.day != day) isValidDate = false;
    } catch (e) {
      isValidDate = false;
    }

    if (!isValidDate) {
      return SizedBox(
        width: size,
        height: size,
      ); // Invisible placeholder to keep shape
    }

    final date = DateTime(year, month, day);
    final entry = moodProvider.getEntryForDate(date);

    // Empty cell colors: visible in BOTH light and dark modes
    Color color = isDarkMode
        ? Colors.grey.shade800 // Solid grey visible on black
        : Colors.black.withValues(alpha: 0.05);

    if (entry != null) {
      // Mood entries: Full opacity for maximum visibility
      color = isDarkMode
          ? _getMoodColor(entry.moodCode).withValues(alpha: 1.0)
          : _getMoodColor(entry.moodCode);
    }

    final isFuture = date.isAfter(DateTime.now());
    if (isFuture) {
      // Future dates: Transparent
      color = Colors.transparent;
    }

    return GestureDetector(
      onTap: () {
        if (!isFuture &&
            entry != null &&
            Provider.of<PremiumProvider>(context, listen: false).isPremium) {
          _showDayDetails(context, date, moodProvider);
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
