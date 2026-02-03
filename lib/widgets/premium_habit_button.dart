import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class PremiumHabitButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final int goalMax;
  final bool isDone;
  final bool isGoalReached;
  final Color? inactiveColor;
  final LinearGradient? gradient;
  final bool isDark;
  final VoidCallback onTap;

  const PremiumHabitButton({
    super.key,
    required this.label,
    required this.icon,
    required this.count,
    required this.goalMax,
    required this.isDone,
    required this.isGoalReached,
    required this.inactiveColor,
    required this.gradient,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Construct gradients for both states to ensure smooth interpolation
    // Inactive Gradient: Uniform gradient of the inactive color
    final inactiveGradient = LinearGradient(
      colors: [
        inactiveColor ?? Colors.transparent,
        inactiveColor ?? Colors.transparent,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Active Gradient: The passed gradient or Gold if goal reached
    final activeGradient = isGoalReached
        ? const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)], // Gold
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : (gradient ?? inactiveGradient); // Fallback to inactive if null

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Fast smooth transition
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // ALWAYS render a gradient to ensure smooth Gradient-to-Gradient interpolation
          // This prevents "grey" washout artifacts that happen when interpolating Color <-> Gradient
          gradient: isDone ? activeGradient : inactiveGradient,

          border: isDone
              ? null
              : (isDark
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      )
                    : null),
          boxShadow: isDone
              ? [
                  BoxShadow(
                    color: isGoalReached
                        ? Colors.amber.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.3),
                    blurRadius: isGoalReached ? 10 : 6,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isGoalReached ? LineIcons.trophy : icon,
              size: 20,
              color: isDone
                  ? Colors.white
                  : (isDark ? Colors.white38 : const Color(0xFF4E342E)),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF4E342E)),
                  ),
                ),
                if (count > 0)
                  Row(
                    children: [
                      Icon(
                        isGoalReached
                            ? Icons.star
                            : Icons.local_fire_department,
                        size: 10,
                        color: isDone
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.orangeAccent,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "$count/$goalMax",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isDone
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
