import 'package:flutter/material.dart';

class PremiumEffects {
  // Museum-quality shadow
  static List<BoxShadow> museumShadow() => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  // Subtle text shadow for readability
  static List<Shadow> textShadow(Color baseColor) => [
    Shadow(
      blurRadius: 10,
      color: Colors.black.withValues(alpha: 0.4),
      offset: const Offset(0, 2),
    ),
  ];

  // Golden accent shadow
  static List<BoxShadow> goldenGlowShadow() => [
    BoxShadow(
      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
      blurRadius: 15,
      spreadRadius: 2,
    ),
  ];

  // Museum card border with subtle gradient
  static Border museumBorder() =>
      Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1);

  // Premium rounded corners
  static const BorderRadius premiumRadius = BorderRadius.all(
    Radius.circular(20),
  );
  static const BorderRadius subtleRadius = BorderRadius.all(
    Radius.circular(12),
  );
}

class AnimationConstants {
  // Premium animation durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 600);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Curves for premium feel
  static const Curve premiumCurve = Curves.easeInOutCubic;
  static const Curve smoothCurve = Curves.easeOut;
  static const Curve enterCurve = Curves.easeOutCubic;
}

// Helper to create gradient backgrounds
class GradientBackgrounds {
  static LinearGradient sadGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.grey[800]!, Colors.blue[900]!],
  );

  static LinearGradient happyGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.amber[600]!, Colors.orange[400]!],
  );

  static LinearGradient nostalgicGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.brown[800]!, Colors.amber[900]!],
  );

  static LinearGradient dreamyGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.indigo[900]!, Colors.purple[900]!],
  );

  static LinearGradient hopefulGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.pink[300]!, Colors.blue[300]!],
  );

  static LinearGradient peacefulGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.teal[700]!, Colors.cyan[600]!],
  );

  static LinearGradient mysticGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.indigo[900]!, Colors.purple[900]!],
  );

  static LinearGradient romanticGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFD32F2F), // Deep Red
      const Color(0xFFFF4081), // Pink Accent
    ],
  );

  static LinearGradient tiredGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.blueGrey[700]!, Colors.grey[600]!],
  );
}
