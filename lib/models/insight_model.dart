import 'package:flutter/material.dart';

enum InsightType { positiveActivity, negativeActivity, timeBased, sleepFactor }

class InsightModel {
  final InsightType type;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isLocked;

  InsightModel({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    this.isLocked = false,
  });
}
