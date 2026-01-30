import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/providers.dart';
import '../models/daily_entry_model.dart';
import '../models/poem_model.dart';

import '../helpers/localization_helper.dart';
import '../core/language_provider.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'full_screen_gallery.dart';
import '../widgets/mood_entry_dialog.dart'; // For buildMediaThumbnail

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late DateTime _selectedMonth;
  List<DateTime> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _buildAvailableMonths(List<DailyEntry> allEntries) {
    final months = <DateTime>{};
    for (var entry in allEntries) {
      months.add(DateTime(entry.date.year, entry.date.month));
    }
    _availableMonths = months.toList()..sort((a, b) => b.compareTo(a));

    // Ensure current month is always included
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    if (!_availableMonths.contains(currentMonth)) {
      _availableMonths.insert(0, currentMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get all entries and build month list
    final allEntries = moodProvider.journal.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    _buildAvailableMonths(allEntries);

    // Filter entries for selected month
    final filteredEntries = allEntries.where((entry) {
      return entry.date.year == _selectedMonth.year &&
          entry.date.month == _selectedMonth.month;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. MONTH SELECTOR
            _buildMonthSelector(lang, isDark),

            // 2. TIMELINE CONTENT
            Expanded(
              child: filteredEntries.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 100,
                      ),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        final isLast = index == filteredEntries.length - 1;
                        return _buildTimelineEntry(
                          context,
                          entry,
                          moodProvider,
                          isDark,
                          isLast,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== MONTH SELECTOR =====
  Widget _buildMonthSelector(LanguageProvider lang, bool isDark) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _availableMonths.length,
        itemBuilder: (context, index) {
          final month = _availableMonths[index];
          final isSelected =
              month.year == _selectedMonth.year &&
              month.month == _selectedMonth.month;

          final monthFormat = lang.currentLanguage == 'tr'
              ? DateFormat('MMMM yyyy', 'tr_TR')
              : DateFormat('MMM yyyy', 'en_US');

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMonth = month;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withAlpha(200)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white.withAlpha(50),
                ),
              ),
              child: Center(
                child: Text(
                  monthFormat.format(month),
                  style: GoogleFonts.poppins(
                    fontSize: isSelected ? 16 : 14,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===== TIMELINE ENTRY =====
  Widget _buildTimelineEntry(
    BuildContext context,
    DailyEntry entry,
    MoodProvider provider,
    bool isDark,
    bool isLast,
  ) {
    final mood = provider.moods.firstWhere(
      (m) => m.code == entry.moodCode,
      orElse: () => provider.moods.first,
    );

    return Stack(
      children: [
        // LEFT: Timeline Column
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          width: 40,
          child: _buildTimelineColumn(mood, isLast),
        ),

        // RIGHT: Entry Card
        Padding(
          padding: const EdgeInsets.only(left: 56), // 40 (col) + 16 (gap)
          child: _JournalCard(entry: entry, mood: mood, provider: provider),
        ),
      ],
    );
  }

  // ===== TIMELINE COLUMN (Line + Node) =====
  Widget _buildTimelineColumn(MoodCategory mood, bool isLast) {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          // Top line (unless first - handle in builder)
          Container(width: 2, height: 20, color: Colors.grey.withAlpha(80)),

          // Node (colored circle)
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mood.color,
              border: Border.all(color: mood.color.withAlpha(150), width: 2),
            ),
          ),

          // Bottom line (extends to next entry)
          if (!isLast)
            Expanded(
              child: Container(width: 2, color: Colors.grey.withAlpha(80)),
            ),
        ],
      ),
    );
  }

  // ===== EMPTY STATE =====
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 80, color: Colors.grey.withAlpha(100)),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.journalEmptyMonth,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ===== STATEFUL JOURNAL CARD WIDGET =====
class _JournalCard extends StatefulWidget {
  final DailyEntry entry;
  final MoodCategory mood;
  final MoodProvider provider;

  const _JournalCard({
    required this.entry,
    required this.mood,
    required this.provider,
  });

  @override
  State<_JournalCard> createState() => _JournalCardState();
}

class _JournalCardState extends State<_JournalCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use custom story if available, otherwise generate
    // Use custom story if available, otherwise use SAVED story.
    // We do NOT auto-generate here anymore to respect the user's "No Story" choice.
    final displayStory =
        widget.entry.customStory ?? widget.entry.savedStory ?? '';

    final dayFormat = lang.currentLanguage == 'tr'
        ? DateFormat('d', 'tr_TR')
        : DateFormat('d', 'en_US');

    final dayNameFormat = lang.currentLanguage == 'tr'
        ? DateFormat('EEEE', 'tr_TR')
        : DateFormat('EEEE', 'en_US');

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [widget.mood.color.withAlpha(12), const Color(0xFF1C1C1E)]
                : [
                    widget.mood.color.withAlpha(
                      25,
                    ), // Soft mood color (10% opacity)
                    Colors.white, // Fade to white
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? widget.mood.color.withAlpha(20)
                  : widget.mood.color.withAlpha(30),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: widget.mood.color.withValues(alpha: 0.4),
            width: isDark ? 1 : 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Bold Date + Mood + Edit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: BOLD date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayFormat.format(widget.entry.date),
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 0.9,
                      ),
                    ),
                    Text(
                      dayNameFormat.format(widget.entry.date).toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: isDark ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),

                // Right: Mood + Edit
                Row(
                  children: [
                    Text(
                      widget.mood.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocalizationHelper.getMoodName(context, widget.mood.code),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.mood.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.grey.withAlpha(150),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showEditDialog(context, displayStory),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // BODY: Story text (expandable)
            // BODY: Story text (expandable) - Only if exists
            if (displayStory.isNotEmpty) ...[
              Text(
                displayStory,
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
                style: GoogleFonts.merriweather(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],

            // NOTE: User's manual note (Always show if exists)
            if (widget.entry.note != null && widget.entry.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.entry.note!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Read More indicator
            if (!_isExpanded && displayStory.length > 150)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Text(
                      lang.currentLanguage == 'tr'
                          ? 'Devamını Oku'
                          : 'Read More',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: widget.mood.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: widget.mood.color,
                    ),
                  ],
                ),
              ),

            // PHOTOS (Dynamic grid layout)
            if (widget.entry.mediaPaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPhotoSection(),
            ],

            // FOOTER: Activity chips
            if (widget.entry.activities.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _buildActivityChips(isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===== PHOTO SECTION =====
  Widget _buildPhotoSection() {
    final paths = widget.entry.mediaPaths;

    // Single photo: large thumbnail
    if (paths.length == 1) {
      return GestureDetector(
        onTap: () => _openGallery(0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: buildMediaThumbnail(
              paths[0],
              width: double.infinity,
              height: 200,
            ),
          ),
        ),
      );
    }

    // Multiple photos: grid layout
    return Row(
      children: List.generate(paths.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == paths.length - 1 ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => _openGallery(index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: buildMediaThumbnail(
                    paths[index],
                    width: 150,
                    height: 180,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _openGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          imagePaths: widget.entry.mediaPaths,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  List<Widget> _buildActivityChips(bool isDark) {
    final chips = <Widget>[];

    widget.entry.activities.forEach((key, value) {
      if (value == true) {
        chips.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.grey.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.grey.withAlpha(100),
              ),
            ),
            child: Text(
              LocalizationHelper.getActivityName(context, key),
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? Colors.grey : Colors.black54,
              ),
            ),
          ),
        );
      }
    });

    return chips;
  }

  void _showEditDialog(BuildContext context, String currentText) {
    final controller = TextEditingController(text: currentText);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        title: Text(
          lang.currentLanguage == 'tr' ? 'Hikayeni Düzenle' : 'Edit Your Story',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 8,
          style: GoogleFonts.merriweather(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: lang.currentLanguage == 'tr'
                ? 'Hikayeni buraya yaz...'
                : 'Write your story here...',
            hintStyle: TextStyle(color: Colors.grey.withAlpha(100)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(ctx).primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              lang.currentLanguage == 'tr' ? 'İptal' : 'Cancel',
              style: GoogleFonts.nunito(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newStory = controller.text.trim();
              widget.provider.updateCustomStory(
                widget.entry.date,
                newStory.isEmpty ? null : newStory,
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).primaryColor,
            ),
            child: Text(
              lang.currentLanguage == 'tr' ? 'Kaydet' : 'Save',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
