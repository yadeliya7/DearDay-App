import 'package:flutter/material.dart';
import 'package:poem_diary/services/story_content_service.dart';
import '../models/daily_entry_model.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'dart:math';

class StoryGenerator {
  // Category Mappings
  static const _weather = [
    'sunny',
    'rainy',
    'cloudy',
    'snowy',
    'windy',
    'foggy',
    'hail',
  ];

  static String generateDailyStory(
    BuildContext context,
    DailyEntry entry, {
    bool isPremium = false,
    bool includeNote = true,
  }) {
    // Adapter to use the context-free generator with context-based localization
    final loc = AppLocalizations.of(context)!;

    return generateStory(
      entry,
      Localizations.localeOf(context).languageCode,
      isPremium: isPremium,
      includeNote: includeNote,
      weatherTranslator: (weatherKey) {
        switch (weatherKey) {
          case 'sunny':
            return loc.weatherSunny;
          case 'cloudy':
            return loc.weatherCloudy;
          case 'rainy':
            return loc.weatherRainy;
          case 'snowy':
            return loc.weatherSnowy;
          case 'windy':
            return loc.weatherWindy;
          case 'foggy':
            return loc.weatherFoggy;
          case 'hail':
            return loc.weatherHail;
          default:
            return weatherKey;
        }
      },
    );
  }

  /// Context-free generator for use in PDF/Background services
  static String generateStory(
    DailyEntry entry,
    String locale, {
    bool isPremium = false,
    bool includeNote = true,
    String Function(String)? weatherTranslator,
  }) {
    final sb = StringBuffer();

    // 1. Prepare Data
    final mood = entry.moodCode;
    final sleep = entry.activities['sleep'] as String? ?? '';

    // Extract weather
    String? weather;
    final rawWeather = entry.activities['weather'];
    if (rawWeather is List && rawWeather.isNotEmpty) {
      weather = rawWeather.first.toString();
    } else if (rawWeather is String) {
      weather = rawWeather;
    }

    // Helper for Selection
    String selectTemplate(List<String> variations) {
      if (variations.isEmpty) return "";

      if (isPremium) {
        // Premium: Pick a random sentence from the ENTIRE list to ensure variety
        return variations[Random().nextInt(variations.length)];
      } else {
        // Free: ALWAYS pick the first sentence (Index 0)
        return variations.first;
      }
    }

    // 2. INTRO (Mood + Sleep + Weather)
    String moodKey = _getMoodKey(mood);
    String moodSentence = selectTemplate(
      StoryContentService.getVariations(locale, moodKey),
    );

    // Append Sleep Sentence
    String sleepSentence = "";
    if (sleep == 'good') {
      sleepSentence = selectTemplate(
        StoryContentService.getVariations(locale, 'sleep_good'),
      );
    }
    if (sleep == 'bad') {
      sleepSentence = selectTemplate(
        StoryContentService.getVariations(locale, 'sleep_bad'),
      );
    }

    // Append Weather Sentence
    String weatherSentence = "";
    if (weather != null) {
      String wKey = _getWeatherKey(weather);
      weatherSentence = selectTemplate(
        StoryContentService.getVariations(locale, wKey),
      );
    }

    // Construct Intro paragraph
    sb.write(moodSentence);
    if (sleepSentence.isNotEmpty) sb.write(' $sleepSentence');
    if (weatherSentence.isNotEmpty) sb.write(' $weatherSentence');
    sb.write(' ');

    // 3. BODY (Activities)
    final activities = _flattenActivities(entry.activities);
    final activitySentences = <String>[];

    for (final actId in activities) {
      String key = "journal_$actId";
      String sentence = selectTemplate(
        StoryContentService.getVariations(locale, key),
      );

      if (sentence.isNotEmpty) {
        activitySentences.add(sentence);
      }
    }

    if (activitySentences.isNotEmpty) {
      sb.write(activitySentences.join(' '));
      sb.write(' ');
    }

    // 4. OUTRO / NOTE
    if (includeNote && entry.note != null && entry.note!.isNotEmpty) {
      String noteTemplate = selectTemplate(
        StoryContentService.getVariations(locale, 'dayNote'),
      );
      if (noteTemplate.isEmpty) noteTemplate = "Not: {note}"; // Fallback
      sb.write(noteTemplate.replaceAll('{note}', entry.note!));
    }

    // Global Parameter Replacement (e.g. {weather} in main text)
    String finalStory = sb.toString().trim();

    if (finalStory.contains('{weather}') && weather != null) {
      String weatherWord = weather;
      if (weatherTranslator != null) {
        try {
          weatherWord = weatherTranslator(weather);
        } catch (_) {}
      }
      finalStory = finalStory.replaceAll('{weather}', weatherWord);
    }

    return finalStory;
  }

  static List<String> _flattenActivities(Map<String, dynamic> actMap) {
    final list = <String>[];
    actMap.forEach((key, value) {
      if (value is List) {
        list.addAll(value.map((e) => e.toString()));
      } else if (value is bool && value == true) {
        list.add(key);
      } else if (value is String &&
          !_weather.contains(value) &&
          value != 'good' &&
          value != 'medium' &&
          value != 'bad') {
        list.add(value);
      }
    });
    return list;
  }

  static String _getMoodKey(String code) {
    switch (code) {
      case 'happy':
        return 'mood_sentence_nese';
      case 'sad':
        return 'mood_sentence_huzun';
      case 'romantic':
        return 'mood_sentence_romantik';
      case 'angry':
        return 'mood_sentence_sinirli';
      case 'tired':
        return 'mood_sentence_yorgun';
      case 'hopeful':
        return 'mood_sentence_umut';
      case 'peaceful':
        return 'mood_sentence_huzur';
      case 'nostalgic':
        return 'mood_sentence_nostaljik';
      case 'mystic':
        return 'mood_sentence_huzur'; // Map to peaceful
      default:
        return 'introNeutral';
    }
  }

  static String _getWeatherKey(String id) {
    // consistent with JSON keys: weather_sentence_sunny, etc.
    // Exception: 'snowy', 'windy', 'foggy', 'hail' in JSON are `weather_sentence_snowy` or `weatherSentenceSnowy`?
    // User JSON Input for TR: `weatherSentenceSnowy` (CamelCase)
    // But `weather_sentence_sunny` (snake_case).
    // Wait, let's check the JSON I wrote.
    // I wrote `weather_sentence_sunny` etc. for all.
    // NO, the USER INPUT had mixed cases. I should have normalized or check.
    // I wrote the JSON in Step 817.
    // Let's check Step 817 Content.
    // "weather_sentence_sunny", "weather_sentence_cloudy", "weather_sentence_rainy", "weather_sentence_snowy".
    // All snake_case in the JSON I created. Good.
    return 'weather_sentence_$id';
  }
}
