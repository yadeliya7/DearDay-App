class DailyEntry {
  final String moodCode;
  final String? note;
  final String? customStory;
  final String? savedStory; // Persisted story text (auto-generated or edited)
  final DateTime date;
  final List<String> mediaPaths;
  final Map<String, dynamic> activities;

  DailyEntry({
    required this.moodCode,
    this.note,
    this.customStory,
    this.savedStory,
    required this.date,
    this.mediaPaths = const [],
    this.activities = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'moodCode': moodCode,
      'note': note,
      'customStory': customStory,
      'savedStory': savedStory,
      'date': date.toIso8601String(),
      'mediaPaths': mediaPaths,
      'activities': activities,
    };
  }

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      moodCode: json['moodCode'] as String,
      note: json['note'] as String?,
      customStory: json['customStory'] as String?,
      savedStory: json['savedStory'] as String?,
      date: DateTime.parse(json['date'] as String),
      mediaPaths:
          (json['mediaPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      activities: (json['activities'] as Map<String, dynamic>?) ?? {},
    );
  }
}
