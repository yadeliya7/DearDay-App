import 'package:flutter/material.dart';

class GradientDefinition {
  final String id;
  final String name;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;

  const GradientDefinition({
    required this.id,
    required this.name,
    required this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });
}

class GradientPalette {
  static const List<GradientDefinition> gradients = [
    GradientDefinition(
      id: 'sunset',
      name: 'Sunset',
      colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
    ),
    GradientDefinition(
      id: 'ocean',
      name: 'Ocean',
      colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
    ),
    GradientDefinition(
      id: 'mystic',
      name: 'Mystic',
      colors: [Color(0xFF232526), Color(0xFF414345)],
    ),
    GradientDefinition(
      id: 'nature',
      name: 'Nature',
      colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
    ),
    GradientDefinition(
      id: 'royal',
      name: 'Royal',
      colors: [Color(0xFF141E30), Color(0xFF243B55)],
    ),
    GradientDefinition(
      id: 'love',
      name: 'Love',
      colors: [Color(0xFFcc2b5e), Color(0xFF753a88)],
    ),
    GradientDefinition(
      id: 'deep_space',
      name: 'Deep Space',
      colors: [Color(0xFF000000), Color(0xFF434343)],
    ),
    GradientDefinition(
      id: 'northern_lights',
      name: 'Aurora',
      colors: [Color(0xFF4568DC), Color(0xFFB06AB3)],
    ),
    GradientDefinition(
      id: 'lemon_twist',
      name: 'Lemon',
      colors: [Color(0xFF3CA55C), Color(0xFFB5AC49)],
    ),
    GradientDefinition(
      id: 'horizon',
      name: 'Horizon',
      colors: [Color(0xFF003973), Color(0xFFE5E5BE)],
    ),
    GradientDefinition(
      id: 'rose_water',
      name: 'Rose',
      colors: [Color(0xFFE55D87), Color(0xFF5FC3E4)],
    ),
    GradientDefinition(
      id: 'frozen',
      name: 'Frozen',
      colors: [Color(0xFF403B4A), Color(0xFFE7E9BB)],
    ),
    GradientDefinition(
      id: 'mango',
      name: 'Mango',
      colors: [Color(0xFFffe259), Color(0xFFffa751)],
    ),
    GradientDefinition(
      id: 'mauve',
      name: 'Mauve',
      colors: [Color(0xFF42275a), Color(0xFF734b6d)],
    ),
    GradientDefinition(
      id: 'aquamarine',
      name: 'Aqua',
      colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
    ),
  ];

  static GradientDefinition getById(String? id) {
    if (id == null) return gradients.first;
    return gradients.firstWhere(
      (g) => g.id == id,
      orElse: () => gradients.first,
    );
  }
}
