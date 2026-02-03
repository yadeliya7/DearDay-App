import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poem_diary/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_lock_screen.dart';
import 'package:poem_diary/services/app_lock_manager.dart';

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
                onFinished: () async {
                  // Wait a tiny bit after typing finishes before checking auth
                  await Future.delayed(const Duration(milliseconds: 800));

                  if (!mounted) return;

                  // Check if app lock is enabled
                  final prefs = await SharedPreferences.getInstance();
                  final isLockEnabled =
                      prefs.getBool('app_lock_enabled') ?? false;

                  if (!mounted) return;

                  if (isLockEnabled) {
                    // Show authentication screen
                    // 1. Tell Manager we are showing it (prevents main.dart from interfering)
                    AppLockManager.isAuthScreenVisible = true;

                    final authenticated = await Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (context) => const AuthLockScreen(),
                          ),
                        );

                    // 2. Auth finished
                    AppLockManager.isAuthScreenVisible = false;

                    if (!mounted) return;

                    // Only proceed if authenticated
                    if (authenticated == true) {
                      AppLockManager.recordSuccess(); // 3. Record success time

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
                    }
                    // If not authenticated, user can retry or exit from AuthLockScreen
                  } else {
                    // No lock enabled, proceed normally
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
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
