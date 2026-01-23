import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poem_diary/main.dart';

class IntroScreen extends StatefulWidget {
  final bool isSetupDone;
  const IntroScreen({super.key, required this.isSetupDone});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E5), // Cream background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/icon/app_icon.png'),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(24),
                // Optional: Shadow to make it pop slightly
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Typing Animation
            DefaultTextStyle(
              style: GoogleFonts.dancingScript(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A4A4A), // Soft dark grey for text
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Dear Day,',
                    speed: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                  ),
                ],
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
                onFinished: () {
                  // Wait a tiny bit after typing finishes before navigating
                  Future.delayed(const Duration(milliseconds: 800), () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            PoemDiaryApp.getMainScreen(widget.isSetupDone),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 800),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
