import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/providers.dart';
import '../core/language_provider.dart';
import '../widgets/mood_entry_dialog.dart';

/// DailyDetailScreen: Full-screen daily entry view with horizontal date timeline
/// Replaces the old modal entry dialog for a more immersive editing experience
class DailyDetailScreen extends StatefulWidget {
  final DateTime initialDate;
  final String? initialMoodCode;

  const DailyDetailScreen({
    super.key,
    required this.initialDate,
    this.initialMoodCode,
  });

  @override
  State<DailyDetailScreen> createState() => _DailyDetailScreenState();
}

class _DailyDetailScreenState extends State<DailyDetailScreen> {
  late DateTime _selectedDate;
  // Key to access MoodEntrySheet state for saving
  GlobalKey<MoodEntrySheetState> _sheetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Clamp initial date to Today if it's in the future
    if (widget.initialDate.isAfter(DateTime.now())) {
      _selectedDate = DateTime.now();
    } else {
      _selectedDate = widget.initialDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodProvider = Provider.of<MoodProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLocale = languageProvider.currentLanguage; // 'tr' or 'en'
    final currentEntry = moodProvider.getEntryForDate(_selectedDate);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Header showing selected Month/Year
        title: Text(
          DateFormat.yMMMM(currentLocale).format(_selectedDate),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Trigger save in child
          _sheetKey.currentState?.saveEntry();
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      body: Column(
        children: [
          // Horizontal Date Timeline
          _buildDateTimeline(isDark, currentLocale),

          const SizedBox(height: 16),

          // Entry Form Body
          Expanded(
            child: MoodEntrySheet(
              // Key ensures widget handles state reset on date change
              key: _sheetKey,
              isEmbedded: true, // Hide internal header
              date: _selectedDate,
              provider: moodProvider,
              initialMood: currentEntry?.moodCode ?? widget.initialMoodCode,
              initialNote: currentEntry?.note,
              initialMedia: currentEntry?.mediaPaths ?? [],
              initialActivities: currentEntry?.activities ?? {},
              initialSavedStory: currentEntry?.savedStory,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeline(bool isDark, String locale) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).cardColor
            : Theme.of(context).cardColor.withValues(alpha: 0.6),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.brown.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: EasyDateTimeLine(
        initialDate: _selectedDate,
        onDateChange: (selectedDate) {
          // Future Date Validation
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final selected = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );

          if (selected.isAfter(today)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Geleceğe henüz gidemezsin!",
                  style: GoogleFonts.nunito(color: Colors.white),
                ),
                backgroundColor: Colors.orangeAccent,
                duration: const Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          setState(() {
            _selectedDate = selectedDate;
            // Force recreation of MoodEntrySheet to reset its state for new date
            _sheetKey = GlobalKey();
          });
        },
        locale: locale,
        headerProps: const EasyHeaderProps(
          showHeader: false, // Hidden header
          showMonthPicker: false,
        ),
        // Disable future dates visually
        disabledDates: List.generate(
          365,
          (index) => DateTime.now().add(Duration(days: index + 1)),
        ),
        dayProps: EasyDayProps(
          height: 64.0, // Increased height for spacing
          width: 48.0,
          dayStructure: DayStructure.dayStrDayNum,

          // Disabled Future Day Styling
          disabledDayStyle: DayStyle(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            dayNumStyle: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white10 : Colors.black12,
              height: 1.0,
            ),
            dayStrStyle: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white10 : Colors.black12,
              height: 2.0, // Added spacing
            ),
          ),

          // Active (Selected) Day Styling - Vertical Capsule
          activeDayStyle: DayStyle(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(30.0), // Capsule shape
            ),
            dayNumStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
            dayStrStyle: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 2.0, // Added spacing
            ),
          ),

          // Inactive (Unselected) Day Styling - Transparent
          inactiveDayStyle: DayStyle(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30.0),
            ),
            dayNumStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.0,
            ),
            dayStrStyle: GoogleFonts.nunito(
              fontSize: 10,
              color: Colors.grey,
              height: 2.0, // Added spacing
            ),
          ),

          // Today's Day Styling (if not selected)
          todayStyle: DayStyle(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            dayNumStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              height: 1.0,
            ),
            dayStrStyle: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
              height: 2.0, // Added spacing
            ),
          ),
        ),
      ),
    );
  }
}
