import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class StoryContentService {
  static final StoryContentService _instance = StoryContentService._internal();
  factory StoryContentService() => _instance;
  StoryContentService._internal();

  // Structure: { "tr": { "journal_sport": ["Story 1", "Story 2"] } }
  Map<String, Map<String, List<String>>> _contentMap = {};
  final Random _random = Random();

  /// Loads the stories.json file from assets and parses it.
  /// Should be called during app initialization (e.g., in main.dart).
  static Future<void> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/stories.json',
      );
      final Map<String, dynamic> decoded = jsonDecode(jsonString);

      final Map<String, Map<String, List<String>>> parsedContent = {};

      decoded.forEach((langCode, storiesMap) {
        if (storiesMap is Map<String, dynamic>) {
          parsedContent[langCode] = {};
          storiesMap.forEach((key, value) {
            if (value is List) {
              parsedContent[langCode]![key] = value
                  .map((e) => e.toString())
                  .toList();
            }
          });
        }
      });

      _instance._contentMap = parsedContent;
      print("Stories loaded successfully.");
    } catch (e) {
      print("Error loading stories.json: $e");
      // Initialize with empty map to prevent crashes
      _instance._contentMap = {};
    }
  }

  /// Returns a random story string for the given locale and key.
  /// Falls back to 'en' if the locale is not found, or returns an empty string if key not found.
  static String getRandomStory(String locale, String key) {
    // 1. Try requested locale
    if (_instance._contentMap.containsKey(locale)) {
      final stories = _instance._contentMap[locale]![key];
      if (stories != null && stories.isNotEmpty) {
        return stories[_instance._random.nextInt(stories.length)];
      }
    }

    // 2. Fallback to 'en' (or 'tr' if your primary is 'tr')
    // Let's try 'en' first as a generic fallback, or 'tr' if user prefers.
    // Given the request implies TR/EN support, we try the other if one fails maybe?
    // Let's stick to standard fallback logic -> Default to 'en' or 'tr' depending on what exists.
    const fallbackLocale = 'en';
    if (locale != fallbackLocale &&
        _instance._contentMap.containsKey(fallbackLocale)) {
      final stories = _instance._contentMap[fallbackLocale]![key];
      if (stories != null && stories.isNotEmpty) {
        return stories[_instance._random.nextInt(stories.length)];
      }
    }

    // 3. Last resort: Return empty string (so nothing is displayed)
    return "";
  }

  /// Returns the full list of variations for the given locale and key.
  static List<String> getVariations(String locale, String key) {
    if (_instance._contentMap.containsKey(locale)) {
      final stories = _instance._contentMap[locale]![key];
      if (stories != null && stories.isNotEmpty) {
        return stories;
      }
    }

    // Fallback
    const fallbackLocale = 'en';
    if (locale != fallbackLocale &&
        _instance._contentMap.containsKey(fallbackLocale)) {
      final stories = _instance._contentMap[fallbackLocale]![key];
      if (stories != null) {
        return stories;
      }
    }

    return [];
  }
}
