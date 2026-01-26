import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import '../models/daily_entry_model.dart';
import '../models/insight_model.dart';
import '../l10n/app_localizations.dart';
import '../helpers/localization_helper.dart'; // Verified location needed

class RelationalAnalysisService {
  /// Main method to generate all insights
  List<InsightModel> generateInsights(
    BuildContext context,
    List<DailyEntry> data,
  ) {
    if (data.isEmpty) return [];

    final List<InsightModel> insights = [];

    // 1. Activity Correlations (Positive & Negative)
    insights.addAll(_analyzeActivities(context, data));

    // 2. Time-Based Analysis (Weekend vs Weekday)
    final timeInsight = _analyzeTime(context, data);
    if (timeInsight != null) {
      insights.add(timeInsight);
    }

    // 3. Sleep Factor Analysis
    final sleepInsight = _analyzeSleep(context, data);
    if (sleepInsight != null) {
      insights.add(sleepInsight);
    }

    // 4. Magic Duo Analysis
    final magicDuoInsight = _analyzeMagicDuo(context, data);
    if (magicDuoInsight != null) {
      insights.add(magicDuoInsight);
    }

    // 5. Best Day Pattern Analysis
    final bestDayInsight = _analyzeBestDayPattern(context, data);
    if (bestDayInsight != null) {
      insights.add(bestDayInsight);
    }

    // 6. Mood Stability Analysis
    final stabilityInsight = _analyzeMoodStability(context, data);
    if (stabilityInsight != null) {
      insights.add(stabilityInsight);
    }

    // Sort: Positive -> Negative -> Time -> Sleep -> MagicDuo -> BestDay -> Stability
    // We can just rely on the insertion order unless we want explicit sorting logic.
    // Order requested: Super Power (Pos), Kryptonite (Neg), Sleep/Time

    // Note: The UI will handle "locking" based on premium status.
    // Here we mark them as potentially lockable if they are not the "Super Power".

    // Let's ensure the list is sorted by "Impact" magnitude if possible,
    // but mixing types makes hard comparison.
    // Default order in list:
    // [PositiveActivity, NegativeActivity, Time, Sleep]

    return insights;
  }

  /// 1. Activity Analysis (Positive 'Super Power' & Negative 'Kryptonite')
  List<InsightModel> _analyzeActivities(
    BuildContext context,
    List<DailyEntry> data,
  ) {
    final Map<String, List<double>> activityMoods = {};

    // Flatten data
    for (var entry in data) {
      final moodVal = _getMoodValue(entry.moodCode);

      entry.activities.forEach((key, value) {
        if (key == 'header_date') return;

        if (value == true) {
          if (!activityMoods.containsKey(key)) activityMoods[key] = [];
          activityMoods[key]!.add(moodVal);
        } else if (value is List) {
          for (var item in value) {
            final itemKey = item.toString();
            if (!activityMoods.containsKey(itemKey)) {
              activityMoods[itemKey] = [];
            }
            activityMoods[itemKey]!.add(moodVal);
          }
        }
      });
    }

    // Calculate Global Average
    double globalSum = 0;
    int globalCount = 0;
    for (var e in data) {
      globalSum += _getMoodValue(e.moodCode);
      globalCount++;
    }
    final double globalAvg = globalCount == 0 ? 0 : globalSum / globalCount;

    String? bestActivity;
    double bestImpact = 0;

    String? worstActivity;
    double worstImpact = 0; // Will be negative

    // Analyze each activity
    activityMoods.forEach((activity, scores) {
      if (scores.length < 3) return; // Minimum sample size

      final avg = scores.reduce((a, b) => a + b) / scores.length;
      final impact = avg - globalAvg;

      // Check Positive
      if (impact > 0.5 && impact > bestImpact) {
        bestImpact = impact;
        bestActivity = activity;
      }

      // Check Negative
      if (impact < -0.5 && impact < worstImpact) {
        worstImpact = impact;
        worstActivity = activity;
      }
    });

    List<InsightModel> result = [];

    // Add Best (Positive)
    if (bestActivity != null) {
      final percent = (bestImpact * 10).toStringAsFixed(0);
      final name = LocalizationHelper.getActivityName(context, bestActivity!);

      result.add(
        InsightModel(
          type: InsightType.positiveActivity,
          title: AppLocalizations.of(context)!.insightPositiveTitle,
          description: AppLocalizations.of(
            context,
          )!.insightImpactMsg(name, percent),
          icon: LineIcons.lightningBolt,
          gradientColors: [Colors.greenAccent, Colors.teal],
          isLocked: false, // Usually free
        ),
      );
    }

    // Add Worst (Negative) - Kryptonite
    if (worstActivity != null) {
      final percent = (worstImpact.abs() * 10).toStringAsFixed(0);
      final name = LocalizationHelper.getActivityName(context, worstActivity!);

      result.add(
        InsightModel(
          type: InsightType.negativeActivity,
          title: AppLocalizations.of(context)!.insightNegativeTitle,
          description: AppLocalizations.of(
            context,
          )!.insightImpactMsg(name, percent), // "X affects mood by Y%"
          icon: LineIcons.exclamationTriangle,
          gradientColors: [Colors.redAccent, Colors.orange],
          isLocked: true, // Premium feature
        ),
      );
    }

    return result;
  }

  /// 2. Time Analysis (Weekend vs Weekday)
  InsightModel? _analyzeTime(BuildContext context, List<DailyEntry> data) {
    if (data.length < 7) return null; // Need almost a week of data

    List<double> weekendMoods = [];
    List<double> weekdayMoods = [];

    for (var e in data) {
      // weekday: 1 (Mon) .. 7 (Sun)
      if (e.date.weekday >= 6) {
        weekendMoods.add(_getMoodValue(e.moodCode));
      } else {
        weekdayMoods.add(_getMoodValue(e.moodCode));
      }
    }

    if (weekendMoods.isEmpty || weekdayMoods.isEmpty) return null;

    final avgWeekend =
        weekendMoods.reduce((a, b) => a + b) / weekendMoods.length;
    final avgWeekday =
        weekdayMoods.reduce((a, b) => a + b) / weekdayMoods.length;

    final diff = avgWeekend - avgWeekday;

    // Threshold: significant difference (e.g., 0.5 points out of 10)
    if (diff > 0.5) {
      // Happier on Weekends
      final percent = (diff * 10).toStringAsFixed(0);
      return InsightModel(
        type: InsightType.timeBased,
        title: AppLocalizations.of(context)!.insightWeekendTitle,
        description: AppLocalizations.of(context)!.insightWeekendDesc(percent),
        icon: LineIcons.calendarCheck,
        gradientColors: [Colors.blueAccent, Colors.purpleAccent],
        isLocked: true,
      );
    } else if (diff < -0.5) {
      // Happier on Weekdays (Rare but possible!)
      return InsightModel(
        type: InsightType.timeBased,
        title: AppLocalizations.of(context)!.insightWeekdayTitle,
        description: AppLocalizations.of(context)!.insightWeekdayDesc,
        icon: LineIcons.briefcase,
        gradientColors: [Colors.orangeAccent, Colors.deepOrange],
        isLocked: true,
      );
    }

    return null;
  }

  /// 3. Sleep Factor Analysis
  InsightModel? _analyzeSleep(BuildContext context, List<DailyEntry> data) {
    // Find correlation between "Sleep: Good" and Mood
    List<double> goodSleepMoods = [];
    List<double> allMoods = [];

    for (var e in data) {
      final val = _getMoodValue(e.moodCode);
      allMoods.add(val);

      // Assuming sleep is stored in 'activities' or separate field depending on implementation.
      // Based on previous files, 'sleep_good' key in activities map.
      if (e.activities['sleep_good'] == true) {
        goodSleepMoods.add(val);
      }
    }

    if (goodSleepMoods.length < 3 || allMoods.isEmpty) return null;

    final globalAvg = allMoods.reduce((a, b) => a + b) / allMoods.length;
    final goodSleepAvg =
        goodSleepMoods.reduce((a, b) => a + b) / goodSleepMoods.length;

    final diff = goodSleepAvg - globalAvg;

    if (diff > 0.5) {
      final percent = (diff * 10).toStringAsFixed(0);
      return InsightModel(
        type: InsightType.sleepFactor,
        title: AppLocalizations.of(context)!.insightSleepTitle,
        description: AppLocalizations.of(context)!.insightSleepDesc(percent),
        icon: LineIcons.moon,
        gradientColors: [Colors.indigo, Colors.blueGrey],
        isLocked: true,
      );
    }

    return null;
  }

  /// 4. Magic Duo Analysis (Activity Pair Synergy)
  InsightModel? _analyzeMagicDuo(BuildContext context, List<DailyEntry> data) {
    if (data.length < 5) return null; // Need enough data

    // Build activity pair map
    final Map<String, List<double>> pairMoods = {};

    for (var entry in data) {
      final moodVal = _getMoodValue(entry.moodCode);

      // Extract all active activities for this entry
      final List<String> activeActivities = [];
      entry.activities.forEach((key, value) {
        if (key == 'header_date') return;

        if (value == true) {
          activeActivities.add(key);
        } else if (value is List) {
          for (var item in value) {
            activeActivities.add(item.toString());
          }
        }
      });

      // Generate pairs
      for (int i = 0; i < activeActivities.length; i++) {
        for (int j = i + 1; j < activeActivities.length; j++) {
          // Sort to ensure consistent key (A+B = B+A)
          final pair = [activeActivities[i], activeActivities[j]]..sort();
          final pairKey = '${pair[0]}|${pair[1]}';

          if (!pairMoods.containsKey(pairKey)) pairMoods[pairKey] = [];
          pairMoods[pairKey]!.add(moodVal);
        }
      }
    }

    // Calculate global average
    double globalSum = 0;
    for (var e in data) {
      globalSum += _getMoodValue(e.moodCode);
    }
    final globalAvg = globalSum / data.length;

    // Find best pair
    String? bestPair;
    double bestImpact = 0;

    pairMoods.forEach((pair, scores) {
      if (scores.length < 3) return; // Minimum occurrences

      final avg = scores.reduce((a, b) => a + b) / scores.length;
      final impact = avg - globalAvg;

      if (impact > 0.5 && impact > bestImpact) {
        bestImpact = impact;
        bestPair = pair;
      }
    });

    if (bestPair == null) return null;

    // Parse and localize activity names
    final activities = bestPair!.split('|');
    final name1 = LocalizationHelper.getActivityName(context, activities[0]);
    final name2 = LocalizationHelper.getActivityName(context, activities[1]);
    final percent = (bestImpact * 10).toStringAsFixed(0);

    return InsightModel(
      type: InsightType.magicDuo,
      title: AppLocalizations.of(context)!.insightMagicDuoTitle,
      description: AppLocalizations.of(
        context,
      )!.insightMagicDuoDesc(name1, name2, percent),
      icon: LineIcons.users,
      gradientColors: [Colors.pink, Colors.purple],
      isLocked: true,
    );
  }

  /// 5. Best Day Pattern Analysis
  InsightModel? _analyzeBestDayPattern(
    BuildContext context,
    List<DailyEntry> data,
  ) {
    if (data.length < 14) return null; // Need at least 2 weeks

    Map<int, List<double>> weekdayMoods = {};

    for (var entry in data) {
      final weekday = entry.date.weekday; // 1=Mon, 7=Sun
      if (!weekdayMoods.containsKey(weekday)) weekdayMoods[weekday] = [];
      weekdayMoods[weekday]!.add(_getMoodValue(entry.moodCode));
    }

    // Calculate averages per day
    Map<int, double> weekdayAverages = {};
    weekdayMoods.forEach((day, moods) {
      if (moods.length >= 2) {
        // Need at least 2 occurrences
        weekdayAverages[day] = moods.reduce((a, b) => a + b) / moods.length;
      }
    });

    if (weekdayAverages.isEmpty) return null;

    // Calculate global average
    double globalSum = 0;
    for (var e in data) {
      globalSum += _getMoodValue(e.moodCode);
    }
    final globalAvg = globalSum / data.length;

    // Find best day
    int bestDay = 1;
    double bestAvg = 0;

    weekdayAverages.forEach((day, avg) {
      if (avg > bestAvg && avg > globalAvg) {
        bestAvg = avg;
        bestDay = day;
      }
    });

    if (bestAvg <= globalAvg) return null;

    // Get localized day name
    final dayNames = LocalizationHelper.getWeekdayNames(context);
    final dayName = dayNames[bestDay - 1]; // weekday is 1-indexed

    return InsightModel(
      type: InsightType.bestDayPattern,
      title: AppLocalizations.of(context)!.insightBestDayTitle,
      description: AppLocalizations.of(context)!.insightBestDayDesc(dayName),
      icon: LineIcons.calendar,
      gradientColors: [Colors.orange, Colors.deepOrange],
      isLocked: true,
    );
  }

  /// 6. Mood Stability Analysis
  InsightModel? _analyzeMoodStability(
    BuildContext context,
    List<DailyEntry> data,
  ) {
    if (data.isEmpty) return null;

    // Take last 30 entries or all if fewer
    final relevantData = data.length > 30
        ? data.sublist(data.length - 30)
        : data;

    if (relevantData.length < 5) return null; // Need minimum data

    // Calculate mean
    double sum = 0;
    for (var entry in relevantData) {
      sum += _getMoodValue(entry.moodCode);
    }
    final mean = sum / relevantData.length;

    // Calculate standard deviation
    double squaredDiffSum = 0;
    for (var entry in relevantData) {
      final diff = _getMoodValue(entry.moodCode) - mean;
      squaredDiffSum += diff * diff;
    }
    final variance = squaredDiffSum / relevantData.length;

    // Calculate sqrt of variance using Newton's method
    double finalStdDev = 0;
    if (variance > 0) {
      double guess = variance / 2;
      for (int i = 0; i < 10; i++) {
        guess = (guess + variance / guess) / 2;
      }
      finalStdDev = guess;
    }

    // Categorize
    String title;
    String description;
    List<Color> colors;
    IconData icon;

    if (finalStdDev < 0.8) {
      // Low volatility - Stable
      title = AppLocalizations.of(context)!.insightStabilityRockTitle;
      description = AppLocalizations.of(context)!.insightStabilityRockDesc;
      colors = [Colors.blue, Colors.cyan];
      icon = LineIcons.mountain;
    } else if (finalStdDev > 1.5) {
      // High volatility - Unstable
      title = AppLocalizations.of(context)!.insightStabilityWaveTitle;
      description = AppLocalizations.of(context)!.insightStabilityWaveDesc;
      colors = [Colors.amber, Colors.orange];
      icon = LineIcons.alternateWavyMoneyBill;
    } else {
      // Medium - don't show insight
      return null;
    }

    return InsightModel(
      type: InsightType.moodStability,
      title: title,
      description: description,
      icon: icon,
      gradientColors: colors,
      isLocked: true,
    );
  }

  double _getMoodValue(String moodCode) {
    switch (moodCode) {
      case 'happy':
        return 10.0;
      case 'hopeful':
        return 8.0;
      case 'peaceful':
        return 8.0;
      case 'romantic':
        return 8.0;
      case 'nostalgic':
        return 6.0;
      case 'tired':
        return 4.0;
      case 'sad':
        return 3.0;
      case 'angry':
        return 2.0;
      default:
        return 5.0;
    }
  }
}
