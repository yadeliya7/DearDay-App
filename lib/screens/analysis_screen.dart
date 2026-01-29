import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/relational_analysis_service.dart';
// import '../models/insight_model.dart'; // Unused import removal
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:line_icons/line_icons.dart';
import '../helpers/localization_helper.dart';

import 'package:poem_diary/l10n/app_localizations.dart';
import '../core/providers.dart';
import '../models/daily_entry_model.dart';
import 'package:intl/intl.dart';
import '../core/language_provider.dart';
import 'paywall_screen.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check Premium Status
    final isPremium = Provider.of<PremiumProvider>(context).isPremium;
    final provider = Provider.of<MoodProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Data Preparation
    final entries = provider.journal.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // Oldest first for charts

    final last7Days = entries.length > 7
        ? entries.sublist(entries.length - 7)
        : entries;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.analysisTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Mood Trend (Line Chart)
            _buildSection(
              context,
              AppLocalizations.of(context)!.analysisMoodTrend,
              _buildMoodChart(context, last7Days, isDark),
              isDark,
            ),
            const SizedBox(height: 20),

            // 1.5 Smart Insights Carousel
            _buildSection(
              context,
              AppLocalizations.of(context)!.analysisInsightsTitle,
              _buildInsightsCarousel(context, entries, isDark),
              isDark,
              showPremiumBadge: !isPremium,
            ),
            const SizedBox(height: 20),

            // 2. Sleep Analysis (Pie Chart)
            _buildSection(
              context,
              AppLocalizations.of(context)!.analysisSleepQuality,
              _buildSleepPieChart(context, entries, isDark),
              isDark,
              isLocked: !isPremium, // Show lock if not premium
              showPremiumBadge: !isPremium,
            ),
            const SizedBox(height: 20),

            // 3. Daily Goals
            _buildSection(
              context,
              AppLocalizations.of(context)!.dailyGoals,
              _buildGoalStats(context, entries, isDark),
              isDark,
            ),
            const SizedBox(height: 20),

            // 4. Top Activities (List/Bar)
            _buildSection(
              context,
              AppLocalizations.of(context)!.mostFrequentActivities,
              _buildActivityList(context, entries, isDark),
              isDark,
              onSeeAll: () => _showAllActivitiesModal(context, entries, isDark),
            ),
            // Bottom padding for nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    Widget content,
    bool isDark, {
    VoidCallback? onSeeAll,
    bool isLocked = false,
    bool showPremiumBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Use theme card color
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (showPremiumBadge) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.amber.shade800,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isLocked && !showPremiumBadge) ...[
                    const SizedBox(width: 8),
                    Icon(
                      LineIcons.lock,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                  ],
                ],
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.btnSeeAll,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  // --- CHART 1: LINE CHART (MOOD) ---
  Widget _buildMoodChart(
    BuildContext context,
    List<DailyEntry> data,
    bool isDark,
  ) {
    if (data.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.analysisNoData));
    }

    return SizedBox(
      height: 220, // Slightly taller for emojis
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            // Left Titles: Emojis
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if ((value - 5).abs() < 0.1) {
                    return const Center(
                      child: Text('🤩', style: TextStyle(fontSize: 20)),
                    );
                  } else if ((value - 3).abs() < 0.1) {
                    return const Center(
                      child: Text('😐', style: TextStyle(fontSize: 20)),
                    );
                  } else if ((value - 1).abs() < 0.1) {
                    return const Center(
                      child: Text('😔', style: TextStyle(fontSize: 20)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // Show exactly one label per data point
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat(
                          'E',
                          Provider.of<LanguageProvider>(
                            context,
                          ).currentLanguage,
                        ).format(data[index].date), // Pzt, Sal
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0.5,
          maxY: 5.5,
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(
                  e.key.toDouble(),
                  _getMoodScore(e.value.moodCode),
                );
              }).toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.redAccent, Colors.amber, Colors.green],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: _getColorForScore(spot.y),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMoodScore(String code) {
    switch (code) {
      case 'happy':
        return 5;
      case 'hopeful':
        return 5;

      case 'peaceful':
        return 4;
      case 'romantic':
        return 4;

      case 'nostalgic':
        return 3;
      case 'neutral':
        return 3;

      case 'tired':
        return 2;

      case 'sad':
        return 1;
      case 'angry':
        return 1;

      default:
        return 3;
    }
  }

  Color _getColorForScore(double score) {
    if (score >= 4.5) return Colors.green;
    if (score >= 3.5) return Colors.lightGreen;
    if (score >= 2.5) return Colors.amber;
    if (score >= 1.5) return Colors.orange;
    return Colors.red;
  }

  // --- CHART 2: PIE CHART (SLEEP) ---
  Widget _buildSleepPieChart(
    BuildContext context,
    List<DailyEntry> data,
    bool isDark,
  ) {
    // Check Premium Status
    final isPremium = Provider.of<PremiumProvider>(context).isPremium;

    // Non-Premium: Solid Lock State (Teaser Style)
    if (!isPremium) {
      // Black gradient for locked Sleep Status card
      final gradientColors = [Colors.grey.shade800, Colors.black];

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaywallScreen()),
          );
        },
        child: Container(
          height: 140, // Match typical insight card height or compact it
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LineIcons.moon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.insightTeaserSleepAnalysisTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.insightTeaserSleepAnalysisDesc,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Arrow indicator at bottom right
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Premium: Show Real Data
    int good = 0, medium = 0, bad = 0;

    for (var e in data) {
      final sleep = e.activities['sleep'];
      if (sleep == 'good') {
        good++;
      } else if (sleep == 'medium') {
        medium++;
      } else if (sleep == 'bad') {
        bad++;
      }
    }

    final total = good + medium + bad;
    if (total == 0) {
      return Center(
        child: Text(AppLocalizations.of(context)!.analysisNoSleepData),
      );
    }

    // Calculate dominant
    final dominantValue = [good, medium, bad].reduce((a, b) => a > b ? a : b);
    final dominantPercentage = ((dominantValue / total) * 100).toInt();
    String dominantLabel;
    if (dominantValue == good) {
      dominantLabel = AppLocalizations.of(context)!.legendSleepGood;
    } else if (dominantValue == medium) {
      dominantLabel = AppLocalizations.of(context)!.legendSleepMedium;
    } else {
      dominantLabel = AppLocalizations.of(context)!.legendSleepBad;
    }

    return SizedBox(
      height: 270,
      child: Column(
        children: [
          // Chart with center content
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: [
                      if (good > 0)
                        PieChartSectionData(
                          value: good.toDouble(),
                          color: Colors.orangeAccent,
                          title: '',
                          radius: 60,
                        ),
                      if (medium > 0)
                        PieChartSectionData(
                          value: medium.toDouble(),
                          color: Colors.blueAccent,
                          title: '',
                          radius: 60,
                        ),
                      if (bad > 0)
                        PieChartSectionData(
                          value: bad.toDouble(),
                          color: const Color(0xFFEF5350),
                          title: '',
                          radius: 60,
                        ),
                    ],
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$dominantPercentage%',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      dominantLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Legend below
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(
                Colors.orangeAccent,
                AppLocalizations.of(context)!.legendSleepGood,
              ),
              const SizedBox(width: 20),
              _buildLegend(
                Colors.blueAccent,
                AppLocalizations.of(context)!.legendSleepMedium,
              ),
              const SizedBox(width: 20),
              _buildLegend(
                const Color(0xFFEF5350),
                AppLocalizations.of(context)!.legendSleepBad,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // --- SMART INSIGHTS CAROUSEL ---
  Widget _buildInsightsCarousel(
    BuildContext context,
    List<DailyEntry> data,
    bool isDark,
  ) {
    // Check Premium Status
    final isPremium = Provider.of<PremiumProvider>(context).isPremium;

    // 1. Generate Insights using Service
    final service = RelationalAnalysisService();
    final insights = service.generateInsights(context, data);

    // 2. Handle Non-Premium UI (Teaser Cards) - Always show this if not premium
    if (!isPremium) {
      return Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // 1. Super Power Card (Locked Placeholder)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildInsightCard(
                      context,
                      title: AppLocalizations.of(
                        context,
                      )!.insightTeaserSuperPowerTitle,
                      description: AppLocalizations.of(
                        context,
                      )!.insightTeaserSuperPowerDesc,
                      icon: LineIcons.lightningBolt,
                      gradientColors: [
                        Colors.grey.shade800,
                        Colors.black,
                      ], // Black Gradient
                      isLocked: true,
                      width: 280, // Wider card
                    ),
                  ),

                  // 2. Go Premium Card (CTA)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildInsightCard(
                      context,
                      title: AppLocalizations.of(
                        context,
                      )!.insightTeaserGoPremiumTitle,
                      description: AppLocalizations.of(
                        context,
                      )!.insightPremiumDesc,
                      icon: Icons.workspace_premium, // Premium Icon
                      gradientColors: [
                        Colors.grey.shade800,
                        Colors.black,
                      ], // Black Gradient
                      isLocked: false,
                      isTeaser: true,
                      width: 280, // Wider card
                      onTap: () => _openPaywall(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 3. Handle Premium User - Empty State
    if (insights.isEmpty) {
      // Premium User: Should NEVER see teaser. If empty, show "No Data / Finding Patterns"
      if (isPremium) {
        return _buildNoDataCard(context, isDark);
      }
      // Free User Logic Removed (Handled above)
      return _buildNoDataCard(context, isDark); // Fallback
    }

    // 2. Filter/Modify for Display
    // We want to show:
    // - Positive: Always Visible
    // - Locked items (Negative/Time/Sleep):
    //    - If Premium: Visible
    //    - If Free: Show as Locked/Blurred or Teaser

    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 160, // Increased height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:
                insights.length + (!isPremium ? 1 : 0), // Add Teaser if free
            itemBuilder: (context, index) {
              final margin = index == 0
                  ? const EdgeInsets.only(left: 0, right: 16)
                  : const EdgeInsets.only(right: 16);

              if (index < insights.length) {
                final item = insights[index];

                // Logic: If user is FREE and item is LOCKED, show it as locked shell
                final bool showLockedUI = !isPremium && item.isLocked;

                return Container(
                  margin: margin,
                  child: _buildInsightCard(
                    context,
                    title: item.title,
                    description: showLockedUI
                        ? "Premium Feature" // Or obscure text
                        : item.description,
                    icon: item.icon,
                    gradientColors: item.gradientColors,
                    isLocked: showLockedUI,
                  ),
                );
              } else {
                // Premium Teaser Card (Only for Free users)
                return Container(
                  margin: margin,
                  child: _buildInsightCard(
                    context,
                    title: AppLocalizations.of(context)!.insightPremiumTitle,
                    description: AppLocalizations.of(
                      context,
                    )!.insightPremiumDesc,
                    icon: LineIcons.lock,
                    gradientColors: [
                      Colors.grey.shade700,
                      Colors.grey.shade900,
                    ],
                    isLocked: true,
                    isTeaser: true, // Special flag for the CTA
                    onTap: () => _openPaywall(context),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    List<Color>? gradientColors, // Changed from isPositive
    bool isLocked = false,
    bool isTeaser = false, // Added isTeaser
    VoidCallback? onTap,
    double? width = 280, // Default width increased to 280
  }) {
    // Default gradients if not provided
    final colors = gradientColors ?? [Colors.blueAccent, Colors.purpleAccent];

    final cardContent = Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLocked && !isTeaser
              ? [Colors.grey.shade800, Colors.grey.shade900] // Dark/Locked look
              : colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    isLocked && !isTeaser
                        ? Container(
                            // Blurred dummy text for locked items
                            height: 10,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            description,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines:
                                4, // Increased lines for long descriptions (Magic Duo)
                            overflow: TextOverflow.ellipsis,
                          ),
                  ],
                ),
              ),
            ],
          ),

          // Lock Overlay for non-teaser locked items
          // Blur Overlay only (No icon, no text)
          // Blur Overlay removed

          // Teaser 'Upgrade' arrow
          if (isTeaser)
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            ),
        ],
      ),
    );

    // Wrap with GestureDetector if onTap is provided
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }
    return cardContent;
  }

  // --- BUILD NO DATA CARD (FOR PREMIUM USERS WITH INSUFFICIENT DATA) ---
  Widget _buildNoDataCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LineIcons.hourglassHalf,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.dataCollectionTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.dataCollectionDesc,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- OPEN PAYWALL SCREEN ---
  void _openPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaywallScreen()),
    );
  }

  // --- SHOW ALL ACTIVITIES MODAL ---
  void _showAllActivitiesModal(
    BuildContext context,
    List<DailyEntry> data,
    bool isDark,
  ) {
    // 1. Calculate Counts (Same logic as _buildActivityList)
    final Map<String, int> counts = {};
    final currentYear = DateTime.now().year;

    for (var e in data) {
      // Filter: Only count entries from this year
      if (e.date.year != currentYear) continue;

      e.activities.forEach((key, value) {
        if (key == 'sleep' || key == 'weather') return; // Skip

        if (value == true) {
          if (_goalIds.contains(key)) return; // Filter Goals
          counts[key] = (counts[key] ?? 0) + 1;
        } else if (value is List) {
          for (var item in value) {
            if (_goalIds.contains(item.toString())) continue; // Filter Goals
            counts[item.toString()] = (counts[item.toString()] ?? 0) + 1;
          }
        }
      });
    }

    // 2. Sort
    final sortedKeys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    final maxCount = sortedKeys.isNotEmpty ? counts[sortedKeys.first]! : 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // Use theme card color
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.analysisAllActivities,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // List
              Expanded(
                child: sortedKeys.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!.analysisNoActivities,
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: sortedKeys.length,
                        itemBuilder: (context, index) {
                          final key = sortedKeys[index];
                          final count = counts[key]!;

                          // --- LOCALIZATION MAP ---
                          // Removed hardcoded map

                          // Consolidating icons if needed, or keeping them.
                          // Ideally icons should be in a helper too, but let's keep them here or assume shared helper.
                          // For now, I will keep the icon map but replace label logic.

                          final Map<String, IconData> icons = {
                            // Habits
                            'drink_water': Icons.water_drop,
                            'journaling': Icons.book,
                            'eary_rise': Icons.alarm,
                            'no_sugar': Icons.no_food,
                            '10k_steps': Icons.directions_walk,
                            'read_book': Icons.menu_book,
                            'meditation': Icons.self_improvement,
                            'no_smoking': Icons.smoke_free,
                            'social_media_detox': Icons.phonelink_erase,
                            // Partial mapping for others - fallback to circle
                            'sport': Icons.directions_run,
                            'walking': Icons.directions_walk,
                            'sunny': Icons.wb_sunny,
                            'rainy': Icons.grain,
                          };

                          String label = LocalizationHelper.getActivityName(
                            context,
                            key,
                          );
                          IconData icon = icons[key] ?? Icons.circle; // Default
                          Color color =
                              Colors.primaries[key.hashCode %
                                  Colors
                                      .primaries
                                      .length]; // Random color based on key

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color.withValues(alpha: 0.1),
                                  child: Icon(icon, color: color, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            label, // Using proper label
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.timesCount(count),
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Progress Bar (THICKER)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: count / maxCount,
                                          backgroundColor: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.1,
                                                )
                                              : Colors.grey.shade100,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                color,
                                              ),
                                          minHeight: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- GOAL IDS ---
  static const Set<String> _goalIds = {
    'no_smoking',
    'social_media_detox',
    'read_book',
    'drink_water',
    'meditation',
    'early_rise',
    'no_sugar',
    'journaling',
    '10k_steps',
  };

  // --- CHART 3: TOP ACTIVITIES (LIST) ---
  Widget _buildActivityList(
    BuildContext context,
    List<DailyEntry> data,
    bool isDark,
  ) {
    // Count frequencies for CURRENT YEAR
    final Map<String, int> counts = {};
    final currentYear = DateTime.now().year;

    for (var e in data) {
      // Filter: Only count entries from this year
      if (e.date.year != currentYear) continue;

      e.activities.forEach((key, value) {
        if (key == 'header_date') return;
        if (_goalIds.contains(key)) return; // Filter out GOALS

        if (value == true) {
          counts[key] = (counts[key] ?? 0) + 1;
        } else if (value is List) {
          for (var item in value) {
            if (_goalIds.contains(item.toString()))
              continue; // Filter out GOALS from lists if any
            counts[item.toString()] = (counts[item.toString()] ?? 0) + 1;
          }
        }
      });
    }

    if (counts.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.analysisNoActivityData),
      );
    }

    // Sort descending
    final sortedKeys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    final top5 = sortedKeys.take(5).toList();

    return Column(
      children: top5.map((key) {
        final count = counts[key]!;
        final max = counts[top5.first]!;
        final color = _getColorForKey(key);
        final icon = _getIconForKey(key);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label + Count ABOVE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 20, color: color),
                      const SizedBox(width: 10),
                      Text(
                        LocalizationHelper.getActivityName(context, key),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${count}x',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // THICK ROUNDED BAR
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: count / max,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- GOAL STATS ---
  Widget _buildGoalStats(
    BuildContext context,
    List<DailyEntry> data,
    bool isDark,
  ) {
    // Count frequencies for CURRENT YEAR
    final Map<String, int> counts = {};
    final currentYear = DateTime.now().year;

    for (var e in data) {
      if (e.date.year != currentYear) continue;

      e.activities.forEach((key, value) {
        if (!_goalIds.contains(key)) return; // Only count GOALS

        if (value == true) {
          counts[key] = (counts[key] ?? 0) + 1;
        }
      });
    }

    if (counts.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.analysisNoActivityData),
      );
    }

    // Sort descending
    final sortedKeys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    return Column(
      children: sortedKeys.map((key) {
        final count = counts[key]!;
        // Assuming max possible is 365 or similar, but relative to max in list is better for visuals
        final max = sortedKeys.isNotEmpty ? counts[sortedKeys.first]! : 1;

        // Goals usually have specific colors or we can use the same helper
        final color = _getColorForKey(key);
        final icon = _getIconForKey(key);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 20, color: color),
                      const SizedBox(width: 10),
                      Text(
                        LocalizationHelper.getActivityName(context, key),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${count}x',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: count / max,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Use LocalizationHelper instead of local map
  // Removed _getHumanLabel call

  Color _getColorForKey(String key) {
    // Consistent colors with HomeTab where possible
    const colorMap = {
      'sport': Colors.green,
      'walking': Colors.green,
      'healthy_food': Colors.greenAccent,
      'fast_food': Colors.orangeAccent,
      'water': Colors.blueAccent,
      'doctor': Colors.red,

      'friends': Colors.purple,
      'family': Colors.brown,
      'party': Colors.deepPurple,
      'partner': Colors.red,

      'gaming': Colors.indigoAccent,
      'reading': Colors.brown,
      'movie': Colors.redAccent,
      'art': Colors.pinkAccent,
      'coding': Colors.teal,

      'cleaning': Colors.teal,
      'cooking': Colors.deepOrange,

      'manicure': Colors.pink,
      'skincare': Colors.lightGreen,

      // Goal Colors
      'no_smoking': Colors.redAccent,
      'social_media_detox': Colors.purpleAccent,
      'read_book': Colors.brown,
      'drink_water': Colors.blue,
      'meditation': Colors.tealAccent,
      'early_rise': Colors.amber,
      'no_sugar': Colors.green,
      'journaling': Colors.deepPurple,
      '10k_steps': Colors.orange,
    };

    if (colorMap.containsKey(key)) return colorMap[key]!;

    // Fallback deterministic colors
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
    ];
    return colors[key.hashCode.abs() % colors.length];
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      // Sleep
      case 'good':
        return LineIcons.sun;
      case 'medium':
        return LineIcons.cloudWithMoon;
      case 'bad':
        return LineIcons.moon;

      // Health
      case 'sport':
        return LineIcons.running;
      case 'healthy_food':
        return LineIcons.carrot;
      case 'fast_food':
        return LineIcons.hamburger;
      case 'water':
        return LineIcons.tint;
      case 'walking':
        return LineIcons.walking;
      case 'vitamins':
        return LineIcons.pills;
      case 'sleep_health':
        return LineIcons.bed;
      case 'doctor':
        return LineIcons.stethoscope;

      // Social
      case 'friends':
        return LineIcons.userFriends;
      case 'family':
        return LineIcons.home;
      case 'party':
        return LineIcons.cocktail;
      case 'partner':
        return LineIcons.heartAlt;
      case 'guests':
        return Icons.people_outline;
      case 'colleagues':
        return LineIcons.briefcase;
      case 'travel':
        return LineIcons.plane;
      case 'volunteer':
        return LineIcons.heart;

      // Hobbies
      case 'gaming':
        return LineIcons.gamepad;
      case 'reading':
        return LineIcons.book;
      case 'movie':
        return LineIcons.video;
      case 'art':
        return LineIcons.palette;
      case 'music':
        return LineIcons.music;
      case 'coding':
        return LineIcons.code;
      case 'photography':
        return LineIcons.camera;
      case 'crafts':
        return LineIcons.brush;

      // Chores
      case 'cleaning':
        return LineIcons.broom;
      case 'shopping':
        return LineIcons.shoppingCart;
      case 'laundry':
        return LineIcons.tShirt;
      case 'cooking':
        return LineIcons.utensils;
      case 'ironing':
        return Icons.iron;
      case 'dishes':
        return Icons.kitchen;
      case 'repair':
        return LineIcons.tools;
      case 'plants':
        return LineIcons.leaf;

      // Self Care
      case 'manicure':
        return LineIcons.handHoldingHeart;
      case 'skincare':
        return LineIcons.spa;
      case 'hair':
        return LineIcons.cut;
      case 'massage':
        return Icons.spa;
      case 'facemask':
        return Icons.face;
      case 'bath':
        return LineIcons.bath;
      case 'digital_detox':
        return Icons.phonelink_off;

      // Weather
      case 'sunny':
        return LineIcons.sun;
      case 'rainy':
        return LineIcons.cloudWithRain;
      case 'cloudy':
        return LineIcons.cloud;
      case 'snowy':
        return LineIcons.snowflake;
      case 'windy':
        return LineIcons.wind;
      case 'foggy':
        return Icons.foggy;
      case 'hail':
        return Icons.ac_unit;

      // Goals
      case 'no_smoking':
        return LineIcons.smokingBan;
      case 'social_media_detox':
        return LineIcons.mobilePhone;
      case 'read_book':
        return LineIcons.book;
      case 'drink_water':
        return LineIcons.tint;
      case 'meditation':
        return LineIcons.spa;
      case 'early_rise':
        return LineIcons.bell;
      case 'no_sugar':
        return Icons.no_food;
      case 'journaling':
        return LineIcons.bookOpen;
      case '10k_steps':
        return LineIcons.shoePrints;

      default:
        return Icons.circle;
    }
  }
}
