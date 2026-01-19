import 'package:flutter/material.dart';

class Poem {
  final String id;
  final String title;
  final String content;
  final String author;
  final String mood; // 'sad', 'happy', 'nostalgic' vb.
  final DateTime createdAt;
  final String
  backgroundImage; // New field for sequential background assignment
  final String? gradientId;
  final bool isFavorite;
  final List<String> mediaPaths;
  final List<String> tags; // Added for mood-based filtering

  Poem({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.mood,
    required this.createdAt,
    this.backgroundImage = '',
    this.gradientId,
    this.isFavorite = false,
    this.mediaPaths = const [],
    this.tags = const [],
  });

  // Favori durumunu güncellemek için kopya oluşturma metodu
  Poem copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    String? mood,
    DateTime? createdAt,
    String? backgroundImage,
    String? gradientId,
    bool? isFavorite,
    bool clearGradient = false,
    List<String>? mediaPaths,
    List<String>? tags,
  }) {
    return Poem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      gradientId: clearGradient ? null : (gradientId ?? this.gradientId),
      isFavorite: isFavorite ?? this.isFavorite,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      tags: tags ?? this.tags,
    );
  }

  factory Poem.fromJson(Map<String, dynamic> json) {
    return Poem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      mood: json['mood'] as String,
      backgroundImage:
          json['backgroundImage'] as String? ?? 'assets/images/bg_1.jpg',
      gradientId: json['gradientId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      mediaPaths:
          (json['mediaPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'mood': mood,
      'backgroundImage': backgroundImage,
      'gradientId': gradientId,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'mediaPaths': mediaPaths,
      'tags': tags,
    };
  }
}

class MoodCategory {
  final String id;
  final String code; // New field for filtering (e.g., 'sad', 'happy')
  final String name;
  final String emoji;
  final String description;
  final String backgroundGradient; // 'sad', 'happy' vb. referans
  final Color color; // New field for mood color

  MoodCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.emoji,
    required this.description,
    required this.backgroundGradient,
    required this.color,
  });
}
