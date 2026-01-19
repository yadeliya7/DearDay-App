import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuroraButton extends StatefulWidget {
  final String? label; // Nullable for Orb mode
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final List<Color>? gradientColors;

  const AuroraButton({
    super.key,
    this.label, // Optional
    required this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.gradientColors,
  });

  @override
  State<AuroraButton> createState() => _AuroraButtonState();
}

class _AuroraButtonState extends State<AuroraButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
    ]).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Varsayılan Mavi Tonları
    final defaultColors = [
      const Color(0xFF89CFF0), // Bebek Mavisi
      const Color(0xFF00C6FF), // Canlı Mavi
      const Color(0xFF89CFF0),
    ];

    final activeColors = widget.gradientColors ?? defaultColors;
    final isOrbMode = widget.label == null || widget.label!.isEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0, // Daha belirgin basma efekti
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Container(
              // Orb Mode: Sabit boyut (48x48), Normal Mode: İçeriğe göre
              width: isOrbMode ? 48 : null,
              height: isOrbMode ? 48 : null,
              padding: isOrbMode
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // Şekil: Orb ise Circle, değilse Rounded Rectangle
                shape: isOrbMode ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isOrbMode
                    ? null
                    : BorderRadius.circular(25), // Daha oval
                // GRADIENT
                gradient: widget.isPrimary
                    ? LinearGradient(
                        colors: activeColors,
                        begin: _topAlignmentAnimation.value,
                        end: _bottomAlignmentAnimation.value,
                      )
                    : null,

                // Primary değilse (Glass/Outline)
                color: widget.isPrimary
                    ? null
                    : Colors.grey.withValues(alpha: 0.1),
                border: widget.isPrimary
                    ? null
                    : Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      ),

                // GÖLGE
                boxShadow: widget.isPrimary
                    ? [
                        BoxShadow(
                          color: activeColors[0].withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: isOrbMode
                  ? Center(
                      child: Icon(
                        widget.icon,
                        color: widget.isPrimary ? Colors.white : Colors.grey,
                        size: 24,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.isPrimary ? Colors.white : Colors.grey,
                          size: 18,
                        ),
                        if (widget.label != null &&
                            widget.label!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            widget.label!,
                            style: GoogleFonts.nunito(
                              color: widget.isPrimary
                                  ? Colors.white
                                  : Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
