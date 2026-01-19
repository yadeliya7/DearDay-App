import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/poem_model.dart';

class MonthlyMoodShareCard extends StatelessWidget {
  final DateTime month;
  final Map<int, MoodCategory> dailyMoods;
  // final Map<int, List<String>> dailyActivities; // REMOVED per user request
  final String userName; // Optional: "Yadeliya's Mood Diary"
  final Map<String, MoodCategory> moodDefinitions; // For colors/icons
  final Map<String, String> localizedLabels; // For translated names
  final String locale; // e.g. 'tr' or 'en'
  final String footerText; // "Created with Habitual"

  const MonthlyMoodShareCard({
    super.key,
    required this.month,
    required this.dailyMoods,
    // this.dailyActivities = const {},
    this.userName = 'Habitual',
    required this.moodDefinitions,
    required this.localizedLabels,
    required this.locale,
    required this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // Fixed width
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM', locale).format(month).toUpperCase(),
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy', locale).format(month),
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Icon(Icons.auto_awesome, color: Colors.amber, size: 32),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Calendar Grid
          _buildCalendarGrid(),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // 3. Mood Legend (ALL Moods)
          Text(
            "DUYGU DURUMU",
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          _buildLegend(),

          // if (dailyActivities.isNotEmpty) ...[
          //   const SizedBox(height: 20),
          //   Text(
          //     "AKTİVİTELER",
          //     style: GoogleFonts.nunito(
          //       fontSize: 10,
          //       fontWeight: FontWeight.bold,
          //       color: Colors.grey,
          //       letterSpacing: 1.2,
          //     ),
          //   ),
          //   const SizedBox(height: 10),
          //   _buildActivityLegend(),
          // ],
          const SizedBox(height: 24),

          // 4. Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_note, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                locale == 'tr'
                    ? 'Habitual ile oluşturuldu'
                    : 'Created with Habitual',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ... _buildCalendarGrid remains same ...

  Widget _buildCalendarGrid() {
    // Calendar logic
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    // 1 = Monday, 7 = Sunday (DateTime standard)
    final firstWeekday = firstDayOfMonth.weekday; // 1 (Mon) to 7 (Sun)

    final int offset = firstWeekday - 1;
    final int totalCells = offset + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 Days a week
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < offset) {
          return const SizedBox(); // Empty cell
        }

        final dayNum = index - offset + 1;
        final mood = dailyMoods[dayNum];

        return Container(
          decoration: BoxDecoration(
            color: mood?.color ?? Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: mood == null
                ? Border.all(color: Colors.grey.withValues(alpha: 0.2))
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$dayNum',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: mood != null ? Colors.white : Colors.grey[700],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    final totalEntries = dailyMoods.length;
    if (totalEntries == 0) return const SizedBox();

    final Map<String, int> counts = {};
    for (var mood in dailyMoods.values) {
      counts[mood.code] = (counts[mood.code] ?? 0) + 1;
    }

    // Sort: High % first
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Show ALL (No take limit)
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: sortedEntries.map((entry) {
        final code = entry.key;
        final count = entry.value;
        final mood = moodDefinitions[code];
        final name = localizedLabels[code] ?? mood?.name ?? code;
        final percentage = ((count / totalEntries) * 100).toInt();

        if (mood == null) return const SizedBox();

        return IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: mood.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: mood.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: mood.color, size: 8),
                const SizedBox(width: 6),
                Text(
                  "$name %$percentage",
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
