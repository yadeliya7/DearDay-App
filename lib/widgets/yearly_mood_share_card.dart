import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/poem_model.dart';

class YearlyMoodShareCard extends StatelessWidget {
  final int year;
  final Map<String, MoodCategory> dailyMoods; // "MM-DD" -> MoodCategory
  final String userName;
  final Map<String, MoodCategory> moodDefinitions;
  final Map<String, String> localizedLabels;
  final String locale;
  final String footerText;
  final String moodStatusLabel; // "MOOD STATUS" or "DUYGU DURUMU"

  const YearlyMoodShareCard({
    super.key,
    required this.year,
    required this.dailyMoods,
    this.userName = 'DearDay',
    required this.moodDefinitions,
    required this.localizedLabels,
    required this.locale,
    required this.footerText,
    required this.moodStatusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440, // Optimized width for 3 columns with better spacing
      padding: const EdgeInsets.all(20),
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
                    '$year',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    locale == 'tr_TR'
                        ? 'YILLIK DUYGU TAKVİMİ'
                        : 'YEARLY MOOD CALENDAR',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Year Grid (12 months in mini format)
          _buildYearGrid(),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // 3. Mood Legend
          Text(
            moodStatusLabel,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegend(),

          const SizedBox(height: 16),

          // 4. Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/app_icon2.png',
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                locale == 'tr_TR'
                    ? 'DearDay ile oluşturuldu'
                    : 'Created with DearDay',
                style: GoogleFonts.poppins(
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

  Widget _buildYearGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 months per row = 4 rows
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0, // Square boxes for better layout
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        return _buildMiniMonth(month);
      },
    );
  }

  Widget _buildMiniMonth(int month) {
    final monthName = DateFormat(
      'MMM',
      locale,
    ).format(DateTime(year, month, 1)).toUpperCase();
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon, 7=Sun
    final offset = firstWeekday - 1;

    // Calculate how many rows we need (important for 6-week months)
    final totalCells = offset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(4), // Reduced to 4 to prevent overflow
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ClipRect(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month name
            Text(
              monthName,
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(
              height: 0,
            ), // Removed spacing to prevent 1px overflow
            // Mini grid - Dynamic height based on row count
            SizedBox(
              height:
                  rowCount * 14.0 +
                  (rowCount - 1) * 1.0, // Reduced cell size to prevent overflow
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  if (index < offset) {
                    return const SizedBox(); // Empty
                  }

                  final day = index - offset + 1;
                  final dateKey =
                      '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                  final mood = dailyMoods[dateKey];

                  return Container(
                    decoration: BoxDecoration(
                      color: mood?.color ?? Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final totalEntries = dailyMoods.length;
    if (totalEntries == 0) return const SizedBox();

    final Map<String, int> counts = {};
    for (var mood in dailyMoods.values) {
      counts[mood.code] = (counts[mood.code] ?? 0) + 1;
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 10,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: sortedEntries.map((entry) {
        final code = entry.key;
        final count = entry.value;
        final mood = moodDefinitions[code];
        final name = localizedLabels[code] ?? mood?.name ?? code;
        final percentage = ((count / totalEntries) * 100).toInt();

        if (mood == null) return const SizedBox();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: mood.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: mood.color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: mood.color, size: 8),
              const SizedBox(width: 5),
              Text(
                "$name %$percentage",
                style: GoogleFonts.nunito(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
