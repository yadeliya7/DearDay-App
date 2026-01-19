import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/providers.dart';
import '../models/daily_entry_model.dart';
import '../core/language_provider.dart';

import '../models/poem_model.dart';
import 'package:line_icons/line_icons.dart';

import '../widgets/mood_entry_dialog.dart';
import '../widgets/home_mood_selector.dart';
import '../helpers/localization_helper.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Get All Entries and Sort (Newest First)
    // FILTER: Current Month Only
    final now = DateTime.now();
    final entries = moodProvider.journal.values.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    // 2. Identify Today's Entry
    final todayEntry = moodProvider.getEntryForDate(now);

    // 3. Filter History (Exclude Today)
    final historyEntries = entries.where((e) {
      return !(e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Wrap in SafeArea to avoid notch issues, but careful with bottom padding
      body: SafeArea(
        bottom: false,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
          // Items:
          // 0: Header + Today's Selector
          // 1: Habits (Goals)
          // 2: Today's Card (If exists) - "Today like history"
          // 3: "Geçmiş Kayıtlar" Label
          // 4+: History Entries (excluding today)
          itemCount: 4 + historyEntries.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              // HEADER + SELECTOR
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(context, isDark, moodProvider),
                  const SizedBox(height: 24),
                  HomeMoodSelector(todayEntry: todayEntry),
                  const SizedBox(height: 24),
                ],
              );
            } else if (index == 1) {
              // HABITS / GOALS
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildGoalsSection(
                  context,
                  todayEntry,
                  moodProvider,
                  isDark,
                ),
              );
            } else if (index == 2) {
              // TODAY'S CARD (Timeline Card)
              if (todayEntry != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.today,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTimelineCard(
                      context,
                      todayEntry,
                      moodProvider,
                      isDark,
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            } else if (index == 3) {
              // HISTORY LABEL
              if (historyEntries.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  AppLocalizations.of(context)!.pastRecords,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              );
            } else {
              // HISTORY LIST
              final entry = historyEntries[index - 4];
              return _buildTimelineCard(context, entry, moodProvider, isDark);
            }
          },
        ),
      ),
      // Settings FAB Removed (Moved to Profile Tab)
    );
  }

  // --- GOALS LOGIC & UI ---

  // --- HABIT TRACKER LOGIC & UI ---

  Future<void> _toggleActivity(
    BuildContext context,
    MoodProvider provider,
    DailyEntry? entry,
    String key,
  ) async {
    // 1. Check if entry exists (Mood must be selected)
    if (entry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen önce yukarıdan ruh halinizi seçin 👆"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 2. Clone and Toggle
    final newActivities = Map<String, dynamic>.from(entry.activities);

    // Toggle logic: If strictly 'true', remove or set false.
    // Usually purely boolean habits: true vs null/false.
    if (newActivities[key] == true) {
      newActivities.remove(key);
    } else {
      newActivities[key] = true;
    }

    // 3. Save Immediate
    // We keep existing mood, note, media.
    await provider.saveDailyEntry(
      entry.date,
      entry.moodCode,
      entry.note,
      entry.mediaPaths,
      newActivities,
    );

    // 4. Check for Celebration (Goal Reached)
    if (newActivities[key] == true) {
      // We just marked it as done. Check the streak.
      // Note: We use DateTime.now() because we are editing today/current entry usually.
      // If editing past, this might trigger celebration for past, which is acceptable.

      // Calculate streak INCLUDING this new completion
      // Since we just saved it, getStreakFor logic (which usually looks back from yesterday)
      // needs to be careful.
      // ACTUALLY: provider.getStreakFor() looks at YESTERDAY and counts back.
      // So if we just finished TODAY, we assume streak = previous + 1.

      final baseStreak = provider.getStreakFor(key, entry.date);
      // Logic from _buildGoalsSection:
      final currentStreak = baseStreak + 1;

      // Check against the *current* goal before any potential upgrade
      final currentGoal = provider.goalDuration;

      if (currentStreak == currentGoal) {
        // --- AUTO-LEVEL UP LOGIC ---
        int? nextLevel;
        if (currentGoal == 7) {
          nextLevel = 14;
        } else if (currentGoal == 14)
          nextLevel = 21;
        else if (currentGoal == 21)
          nextLevel = 30;

        // If there is a next level, upgrade immediately
        if (nextLevel != null) {
          await provider.setGoalDuration(nextLevel);
        }

        if (mounted) {
          _showCelebrationDialog(
            context,
            key,
            currentStreak,
            nextLevel: nextLevel,
          );
        }
      } else if (currentGoal == 30 && currentStreak > 30) {
        // --- INFINITE MODE (Mastery) ---
        // Celebrate every 15 days after 30 (45, 60, 75...)
        if (currentStreak % 15 == 0) {
          if (mounted) {
            _showCelebrationDialog(context, key, currentStreak);
          }
        }
      }
    }

    // Optional: Haptic Feedback
    // HapticFeedback.lightImpact(); // Requires services import
  }

  void _showCelebrationDialog(
    BuildContext context,
    String activityKey,
    int days, {
    int? nextLevel,
  }) {
    // Should mapped activity label from config?
    // Quick lookup or pass label. Let's do a quick lookup mapping here or pass it.
    // Ideally we pass it, but _toggleActivity signature is fixed.
    // Let's rely on a simple mapping or just use the key prettified if needed,
    // OR we can grab it from our Config map if we make it static/member.
    // For now, let's use a generic message or just the key.
    // Actually, let's copy the config map briefly or move it to a getter.
    // Better: Just hardcoded lookup for the 9 habits we know.

    String label = LocalizationHelper.getActivityName(context, activityKey);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orangeAccent, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🏆", style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: days > 30 ? "Durmak Yok! 🚀\n" : "Tebrikler! ",
                          style: GoogleFonts.nunito(
                            fontSize: days > 30 ? 24 : 16,
                            fontWeight: days > 30
                                ? FontWeight.w900
                                : FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        if (days <= 30) ...[
                          TextSpan(
                            text: AppLocalizations.of(
                              context,
                            )!.streakCompleted(days, label),
                            style: const TextStyle(
                              fontWeight: FontWeight
                                  .bold, // Applying bold to the whole sentence
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ] else ...[
                          TextSpan(text: "İnanılmaz! "),
                          TextSpan(
                            text: label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(text: " alışkanlığında "),
                          TextSpan(
                            text: "$days. güne ",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Colors.yellowAccent,
                            ),
                          ),
                          TextSpan(
                            text:
                                "ulaştın.\nHer 15 günde bir yeni zaferini kutlayacağız!",
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (nextLevel != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "🚀 Hedefin otomatik olarak $nextLevel güne yükseltildi!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:
                          Colors.deepOrange, // Matches gradient end
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      nextLevel != null ? "Yeni Hedefe Başla" : "Harika!",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: child,
        );
      },
    );
  }

  Widget _buildGoalsSection(
    BuildContext context,
    DailyEntry? entry,
    MoodProvider provider,
    bool isDark,
  ) {
    // Defined Habit List
    // Defined Habit List with Localized Labels
    final habits = [
      {
        'key': 'drink_water',
        'label': LocalizationHelper.getActivityName(context, 'drink_water'),
        'icon': LineIcons.tint,
      },
      {
        'key': 'journaling',
        'label': LocalizationHelper.getActivityName(context, 'journaling'),
        'icon': LineIcons.bookOpen,
      },
      {
        'key': 'early_rise',
        'label': LocalizationHelper.getActivityName(context, 'early_rise'),
        'icon': LineIcons.bell,
      },
      {
        'key': 'no_sugar',
        'label': LocalizationHelper.getActivityName(context, 'no_sugar'),
        'icon': Icons.no_food,
      },
      {
        'key': '10k_steps',
        'label': LocalizationHelper.getActivityName(context, '10k_steps'),
        'icon': LineIcons.shoePrints,
      },
      {
        'key': 'read_book',
        'label': LocalizationHelper.getActivityName(context, 'read_book'),
        'icon': LineIcons.book,
      },
      {
        'key': 'meditation',
        'label': LocalizationHelper.getActivityName(context, 'meditation'),
        'icon': LineIcons.spa,
      },
      {
        'key': 'no_smoking',
        'label': LocalizationHelper.getActivityName(context, 'no_smoking'),
        'icon': LineIcons.smokingBan,
      },
      {
        'key': 'social_media_detox',
        'label': LocalizationHelper.getActivityName(
          context,
          'social_media_detox',
        ),
        'icon': LineIcons.mobilePhone,
      },
    ];

    // Helper to get muted/dusty gradient per habit
    LinearGradient getGradient(String key) {
      switch (key) {
        case 'drink_water':
          return const LinearGradient(
            colors: [Color(0xFF81D4FA), Color(0xFF29B6F6)], // Soft Sky Blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'journaling':
          return const LinearGradient(
            colors: [Color(0xFF9FA8DA), Color(0xFF5C6BC0)], // Muted Indigo
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'early_rise':
          return const LinearGradient(
            colors: [Color(0xFFFFCC80), Color(0xFFFFA726)], // Soft Apricot/Sun
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'no_sugar':
          return const LinearGradient(
            colors: [Color(0xFFEF9A9A), Color(0xFFEF5350)], // Muted Red
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case '10k_steps':
          return const LinearGradient(
            colors: [Color(0xFFA5D6A7), Color(0xFF66BB6A)], // Soft Green
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'meditation':
          return const LinearGradient(
            colors: [Color(0xFF80CBC4), Color(0xFF26A69A)], // Muted Teal
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'read_book':
          return const LinearGradient(
            colors: [Color(0xFFDCE775), Color(0xFF9E9D24)], // Muted Olive/Paper
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'no_smoking':
          return const LinearGradient(
            colors: [
              Color(0xFFB0BEC5),
              Color(0xFF78909C),
            ], // Cool Blue-Grey (Ash)
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'social_media_detox':
          return const LinearGradient(
            colors: [Color(0xFFCE93D8), Color(0xFFAB47BC)], // Muted Lavender
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        default:
          return const LinearGradient(
            colors: [Color(0xFFA1887F), Color(0xFF8D6E63)], // Default Earth
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
      }
    }

    return SizedBox(
      height: 70,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final item = habits[index];
          final key = item['key'] as String;
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;

          // Status Check
          final isDone = entry?.activities[key] == true;

          // Streak Calculation
          final baseStreak = provider.getStreakFor(key, DateTime.now());
          // If done today, add 1
          int displayStreak = baseStreak + (isDone ? 1 : 0);
          final goalMax = provider.goalDuration;

          // Clamp only if NOT in infinite mode (goal < 30)
          // If goal is 30, we allow streaks to go beyond (31, 32...) to show mastery.
          if (goalMax < 30 && displayStreak > goalMax) {
            displayStreak = goalMax;
          }
          // Note: If goalMax == 30, displayStreak can be 45, etc.

          final bool isGoalReached = displayStreak >= goalMax;

          // Active Decoration
          final gradient = getGradient(key);

          // Inactive Color logic (Dark Matte)
          final inactiveColor = isDark
              ? const Color(0xFF1E2228) // Deep Matte Grey
              : const Color(0xFFEFF3F6); // Soft Light Grey

          final inactiveBorder = isDark
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                )
              : null; // No border in light mode or faint

          return Padding(
            padding: const EdgeInsets.only(right: 12), // Spacing between items
            child: InkWell(
              onTap: () => _toggleActivity(context, provider, entry, key),
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  // Active: Gradient, Inactive: Soft solid / glass
                  gradient: isDone
                      ? (isGoalReached
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFFFA000),
                                ], // Gold
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : gradient)
                      : null,
                  color: isDone ? null : inactiveColor,
                  border: isDone ? null : inactiveBorder,
                  boxShadow: isDone
                      ? [
                          BoxShadow(
                            color: isGoalReached
                                ? Colors.amber.withValues(alpha: 0.4)
                                : Colors.black.withValues(
                                    alpha: 0.3,
                                  ), // Dark shadow
                            blurRadius: isGoalReached ? 10 : 6,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGoalReached ? LineIcons.trophy : icon,
                      size: 20,
                      color: isDone
                          ? Colors.white
                          : (isDark ? Colors.white38 : Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDone
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        if (displayStreak > 0)
                          Row(
                            children: [
                              Icon(
                                isGoalReached
                                    ? Icons.star
                                    : Icons.local_fire_department,
                                size: 10,
                                color: isDone
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.orangeAccent,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "$displayStreak/$goalMax",
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  color: isDone
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- EXISTING WIDGETS ---

  void _showFullScreenImage(BuildContext context, List<String> paths) {
    if (paths.isEmpty) return;

    // Current page index for the indicator
    // Using a simpler approach: Dialog with PageView
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            final PageController pageController = PageController();
            int currentPage = 0;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Swipable Image Gallery
                PageView.builder(
                  controller: pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: paths.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.file(
                        File(paths[index]),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Dosya bulunamadı",
                                style: GoogleFonts.nunito(
                                  color: Colors.white70,
                                  decoration: TextDecoration.none,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Page Indicator (Dots) - Only if multiple images
                if (paths.length > 1)
                  Positioned(
                    bottom: 40,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(paths.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                          ),
                        );
                      }),
                    ),
                  ),

                // Close Button
                Positioned(
                  top: 40,
                  right: 20,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    bool isDark,
    MoodProvider provider,
  ) {
    final lang = Provider.of<LanguageProvider>(context);
    final now = DateTime.now();
    final firstName = provider.userName.split(' ').first;

    // Format date based on language
    final dateFormat = lang.currentLanguage == 'tr'
        ? DateFormat('d MMMM, EEEE', 'tr_TR')
        : DateFormat('d MMM, EEEE', 'en_US');
    final formattedDate = dateFormat.format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Greeting + Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.currentLanguage == 'tr'
                  ? 'Merhaba, $firstName 👋'
                  : 'Hello, $firstName 👋',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),

        // Right side: Profile Avatar
        GestureDetector(
          onTap: () {
            // For now, profile navigation would require accessing MainScaffold
            // This is a placeholder - proper implementation would use a callback or state management
            // Navigator.pushNamed doesn't work well with tab-based navigation
          },
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
            backgroundImage: provider.profileImagePath != null
                ? FileImage(File(provider.profileImagePath!))
                : null,
            child: provider.profileImagePath == null
                ? Text(
                    _getInitials(firstName),
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    DailyEntry entry,
    MoodProvider provider,
    bool isDark,
  ) {
    // Resolve Mood
    final mood = provider.moods.firstWhere(
      (m) => m.code == entry.moodCode,
      orElse: () => MoodCategory(
        id: '?',
        code: '?',
        name: '?',
        emoji: '❓',
        description: '',
        backgroundGradient: '',
        color: Colors.grey,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mood.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mood.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat(
                  'd MMM yyyy, EEEE',
                  Provider.of<LanguageProvider>(context).currentLanguage,
                ).format(entry.date),
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // PHOTO INDICATOR
                  if (entry.mediaPaths.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          // Show Full-Screen Image (Pass all paths)
                          _showFullScreenImage(context, entry.mediaPaths);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black12,
                            ),
                          ),
                          child: Icon(
                            Icons.image, // Or LineIcons.image
                            size: 16,
                            color: isDark ? Colors.white70 : Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                    onPressed: () {
                      showMoodEntryDialog(
                        context,
                        date: entry.date,
                        provider: provider,
                        currentMood: entry.moodCode,
                        currentNote: entry.note,
                        currentMedia: entry.mediaPaths,
                        currentActivities: entry.activities,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 10),

          // Main
          Row(
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationHelper.getMoodName(context, mood.code),
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (entry.note != null && entry.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          entry.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black45,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Chips
          if (entry.activities.isNotEmpty) _buildWrapIcons(entry),
        ],
      ),
    );
  }

  Widget _buildWrapIcons(DailyEntry entry) {
    // Configuration Map for all activities
    final Map<String, dynamic> activityConfig = {
      // Sleep
      'good': {'l': 'İyi Uyku', 'i': LineIcons.sun, 'c': Colors.orange},
      'medium': {
        'l': 'Orta Uyku',
        'i': LineIcons.cloudWithMoon,
        'c': Colors.blueGrey,
      },
      'bad': {'l': 'Kötü Uyku', 'i': LineIcons.moon, 'c': Colors.indigo},

      // Weather
      'sunny': {'l': 'Güneşli', 'i': LineIcons.sun, 'c': Colors.amber},
      'rainy': {
        'l': 'Yağmurlu',
        'i': LineIcons.cloudWithRain,
        'c': Colors.blue,
      },
      'cloudy': {'l': 'Bulutlu', 'i': LineIcons.cloud, 'c': Colors.grey},
      'snowy': {
        'l': 'Karlı',
        'i': LineIcons.snowflake,
        'c': Colors.lightBlueAccent,
      },
      'windy': {'l': 'Rüzgarlı', 'i': LineIcons.wind, 'c': Colors.blueGrey},
      'foggy': {'l': 'Sisli', 'i': Icons.foggy, 'c': Colors.blueGrey},
      'hail': {'l': 'Dolu', 'i': Icons.ac_unit, 'c': Colors.lightBlueAccent},

      // Health
      'sport': {'l': 'Spor', 'i': LineIcons.running, 'c': Colors.green},
      'healthy_food': {
        'l': 'Sağlıklı',
        'i': LineIcons.carrot,
        'c': Colors.greenAccent,
      },
      'fast_food': {
        'l': 'Fast Food',
        'i': LineIcons.hamburger,
        'c': Colors.orangeAccent,
      },
      'water': {'l': 'Su', 'i': LineIcons.tint, 'c': Colors.blueAccent},
      'walking': {'l': 'Yürüyüş', 'i': LineIcons.walking, 'c': Colors.green},
      'vitamins': {
        'l': 'Vitamin',
        'i': LineIcons.pills,
        'c': Colors.greenAccent,
      },
      'sleep_health': {'l': 'Uyku', 'i': LineIcons.bed, 'c': Colors.indigo},
      'doctor': {'l': 'Doktor', 'i': LineIcons.stethoscope, 'c': Colors.red},

      // Social
      'friends': {
        'l': 'Arkadaşlar',
        'i': LineIcons.userFriends,
        'c': Colors.purple,
      },
      'family': {'l': 'Aile', 'i': LineIcons.home, 'c': Colors.brown},
      'party': {'l': 'Parti', 'i': LineIcons.cocktail, 'c': Colors.deepPurple},
      'partner': {'l': 'Partner', 'i': LineIcons.heartAlt, 'c': Colors.red},
      'guests': {
        'l': 'Misafir',
        'i': Icons.people_outline,
        'c': Colors.purpleAccent,
      },
      'colleagues': {
        'l': 'İş Ark.',
        'i': LineIcons.briefcase,
        'c': Colors.brown,
      },
      'travel': {'l': 'Seyahat', 'i': LineIcons.plane, 'c': Colors.blue},
      'volunteer': {
        'l': 'Gönüllü',
        'i': LineIcons.heart,
        'c': Colors.redAccent,
      },

      // Hobbies
      'gaming': {'l': 'Oyun', 'i': LineIcons.gamepad, 'c': Colors.indigoAccent},
      'reading': {'l': 'Okuma', 'i': LineIcons.book, 'c': Colors.brown},
      'movie': {'l': 'Film', 'i': LineIcons.video, 'c': Colors.redAccent},
      'art': {'l': 'Sanat', 'i': LineIcons.palette, 'c': Colors.pinkAccent},
      'music': {
        'l': 'Müzik',
        'i': LineIcons.music,
        'c': Colors.deepPurpleAccent,
      },
      'coding': {'l': 'Kodlama', 'i': LineIcons.code, 'c': Colors.teal},
      'photography': {
        'l': 'Fotoğraf',
        'i': LineIcons.camera,
        'c': Colors.blueGrey,
      },
      'crafts': {'l': 'El İşi', 'i': LineIcons.brush, 'c': Colors.orange},

      // Chores
      'cleaning': {'l': 'Temizlik', 'i': LineIcons.broom, 'c': Colors.teal},
      'shopping': {
        'l': 'Alışveriş',
        'i': LineIcons.shoppingCart,
        'c': Colors.orange,
      },
      'laundry': {'l': 'Çamaşır', 'i': LineIcons.tShirt, 'c': Colors.blueGrey},
      'cooking': {
        'l': 'Yemek',
        'i': LineIcons.utensils,
        'c': Colors.deepOrange,
      },
      'ironing': {'l': 'Ütü', 'i': Icons.iron, 'c': Colors.grey},
      'dishes': {'l': 'Bulaşık', 'i': Icons.kitchen, 'c': Colors.teal},
      'repair': {'l': 'Tamirat', 'i': LineIcons.tools, 'c': Colors.brown},
      'plants': {'l': 'Bitkiler', 'i': LineIcons.leaf, 'c': Colors.green},

      // Selfcare
      'manicure': {
        'l': 'Manikür',
        'i': LineIcons.handHoldingHeart,
        'c': Colors.pink,
      },
      'skincare': {
        'l': 'Cilt Bakımı',
        'i': LineIcons.spa,
        'c': Colors.lightGreen,
      },
      'hair': {'l': 'Saç', 'i': LineIcons.cut, 'c': Colors.brown},
      'massage': {'l': 'Masaj', 'i': Icons.spa, 'c': Colors.purple},
      'facemask': {'l': 'Maske', 'i': Icons.face, 'c': Colors.pinkAccent},
      'bath': {'l': 'Banyo', 'i': LineIcons.bath, 'c': Colors.blue},
      'digital_detox': {
        'l': 'Detoks',
        'i': Icons.phonelink_off,
        'c': Colors.blueGrey,
      },

      // Booleans (Goals)
      'no_smoking': {
        'l': 'Sigara Yok',
        'i': LineIcons.smokingBan,
        'c': Colors.redAccent,
      },
      'social_media_detox': {
        'l': 'Sosyal Medya',
        'i': LineIcons.mobilePhone,
        'c': Colors.blueGrey,
      },
      'meditation': {
        'l': 'Meditasyon',
        'i': LineIcons.spa,
        'c': Colors.purpleAccent,
      },
      'read_book': {
        'l': 'Okuma',
        'i': LineIcons.book,
        'c': Colors.brown,
      }, // Reused key
      'drink_water': {
        'l': 'Su',
        'i': LineIcons.tint,
        'c': Colors.blueAccent,
      }, // Reused key
      'early_rise': {'l': 'Erken Kalk', 'i': LineIcons.bell, 'c': Colors.amber},
      'no_sugar': {'l': 'Şekersiz', 'i': Icons.no_food, 'c': Colors.pink},
      'journaling': {'l': 'Günlük', 'i': LineIcons.bookOpen, 'c': Colors.brown},
      '10k_steps': {
        'l': '10 Bin Adım',
        'i': LineIcons.shoePrints,
        'c': Colors.green,
      },
    };

    List<Widget> chips = [];

    Widget makeChip(IconData icon, Color color, String label) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    entry.activities.forEach((key, value) {
      // 1. String Value (e.g. sleep: 'good', weather: 'sunny')
      if (value is String && activityConfig.containsKey(value)) {
        final conf = activityConfig[value];
        // Use key (e.g. 'sleep') + value ('good') to get localized name
        final label = LocalizationHelper.getActivityName(context, key, value);
        chips.add(makeChip(conf['i'], conf['c'], label));
      }
      // 2. List Value (e.g. hobbies: ['gaming', 'reading'])
      else if (value is List) {
        for (var item in value) {
          if (activityConfig.containsKey(item)) {
            final conf = activityConfig[item];
            // Use item (e.g. 'gaming') as key
            final label = LocalizationHelper.getActivityName(context, item);
            chips.add(makeChip(conf['i'], conf['c'], label));
          }
        }
      }
      // 3. Boolean Value (e.g. sport: true)
      else if (value == true && activityConfig.containsKey(key)) {
        final conf = activityConfig[key];
        // Use key (e.g. 'sport')
        final label = LocalizationHelper.getActivityName(context, key);
        chips.add(makeChip(conf['i'], conf['c'], label));
      }
    });

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: chips,
    );
  }
}
