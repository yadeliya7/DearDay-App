import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:poem_diary/services/notification_service.dart';
import 'dart:ui';
import 'dart:math';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPlan = 'yearly'; // Default selection
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium Colors
    final goldColor = const Color(0xFFFFD700);
    final darkBg = const Color(0xFF121212);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Background Icon Pattern (Dark Mode Only)
          if (Theme.of(context).brightness == Brightness.dark)
            _buildIconBackground(context),

          // Background Gradient Mesh
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goldColor.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1. HEADER SECTION
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10, // Reduced from 20
                            horizontal: 16,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Close Button (Top Left)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),

                              const SizedBox(height: 10), // Reduced from 20
                              // Animated Icon
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    16,
                                  ), // Reduced from 20
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: goldColor.withValues(alpha: 0.1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: goldColor.withValues(alpha: 0.3),
                                        blurRadius: 40,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 48, // Reduced from 60
                                    color: goldColor,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12), // Reduced from 16
                              // Title & Subtitle
                              Text(
                                // Localized Title
                                AppLocalizations.of(
                                  context,
                                )!.paywallTitle, // "DearDay Premium"
                                style: GoogleFonts.outfit(
                                  fontSize: 24, // Reduced from 28
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4), // Reduced from 8
                              Text(
                                // Localized Subtitle
                                AppLocalizations.of(context)!.paywallSubtitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14, // Reduced from 16
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 16), // Reduced from 20
                              // Feature List
                              _buildFeatureItem(
                                AppLocalizations.of(
                                  context,
                                )!.featureUnlimitedStories,
                                goldColor,
                              ),
                              _buildFeatureItem(
                                AppLocalizations.of(
                                  context,
                                )!.featureDetailedAnalysis,
                                goldColor,
                              ),
                              _buildFeatureItem(
                                AppLocalizations.of(
                                  context,
                                )!.featureYearInPixels,
                                goldColor,
                              ),
                              _buildFeatureItem(
                                AppLocalizations.of(context)!.featurePdfExport,
                                goldColor,
                              ),
                            ],
                          ),
                        ),

                        // 2. SUBSCRIPTION OPTIONS
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildPlanCard(
                                id: 'yearly',
                                title: AppLocalizations.of(context)!.planYearly,
                                price: AppLocalizations.of(
                                  context,
                                )!.priceYearlyMock,
                                subtitle: AppLocalizations.of(
                                  context,
                                )!.priceMonthlyBreakdownMock,
                                badgeText: AppLocalizations.of(
                                  context,
                                )!.bestValue,
                                goldColor: goldColor,
                              ),
                              const SizedBox(height: 12),
                              _buildPlanCard(
                                id: 'monthly',
                                title: AppLocalizations.of(
                                  context,
                                )!.planMonthly,
                                price: AppLocalizations.of(
                                  context,
                                )!.priceMonthlyMock,
                                subtitle: null,
                                badgeText: null,
                                goldColor: goldColor,
                              ),
                              const SizedBox(height: 12),
                              _buildPlanCard(
                                id: 'lifetime',
                                title: AppLocalizations.of(
                                  context,
                                )!.planLifetime,
                                price: AppLocalizations.of(
                                  context,
                                )!.priceLifetimeMock,
                                subtitle: null,
                                badgeText: AppLocalizations.of(
                                  context,
                                )!.badgeOneTime,
                                goldColor: goldColor,
                              ),
                            ],
                          ),
                        ),

                        // 3. CTA & FOOTER
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Trial Timeline (Only for Yearly)
                              if (_selectedPlan == 'yearly')
                                _buildTrialTimeline(context, goldColor),

                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [goldColor, Colors.orangeAccent],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: goldColor.withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Perform Purchase Logic
                                      if (_selectedPlan == 'yearly') {
                                        NotificationService()
                                            .scheduleTrialEndingReminder(
                                              AppLocalizations.of(
                                                context,
                                              )!.notificationTrialTitle,
                                              AppLocalizations.of(
                                                context,
                                              )!.notificationTrialBody,
                                            );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      _selectedPlan == 'yearly'
                                          ? AppLocalizations.of(
                                              context,
                                            )!.btnStartTrial
                                          : AppLocalizations.of(
                                              context,
                                            )!.btnSubscribe,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_selectedPlan == 'yearly') ...[
                                const SizedBox(height: 12),
                                Text(
                                  AppLocalizations.of(context)!.trialGuarantee,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              // Footer Links
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildFooterLink(
                                    AppLocalizations.of(
                                      context,
                                    )!.restorePurchase,
                                  ),
                                  _buildFooterDivider(),
                                  _buildFooterLink(
                                    AppLocalizations.of(context)!.termsOfUse,
                                  ),
                                  _buildFooterDivider(),
                                  _buildFooterLink(
                                    AppLocalizations.of(context)!.privacyPolicy,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 24,
      ), // Vertical 6->4, Horizontal 32->24
      child: Row(
        children: [
          Icon(Icons.check_circle, color: iconColor, size: 18), // 20->18
          const SizedBox(width: 8), // 12->8
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13, // 14->13
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    String? subtitle,
    String? badgeText,
    required Color goldColor,
  }) {
    final isSelected = _selectedPlan == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? goldColor : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio Circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? goldColor : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? goldColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 16, color: Colors.black),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // 16->14
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1), // 2->1
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: goldColor,
                        fontSize: 11, // 12->11
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Price & Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13, // 15->13
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (badgeText != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: goldColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.grey,
          fontSize: 11,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildFooterDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 12,
      width: 1,
      color: Colors.grey.withOpacity(0.5),
    );
  }

  Widget _buildIconBackground(BuildContext context) {
    final icons = [
      Icons.wb_sunny_rounded,
      Icons.nightlight_round,
      Icons.cloud,
      Icons.sentiment_very_satisfied,
      Icons.sentiment_dissatisfied,
      Icons.favorite_rounded,
      Icons.book_rounded,
      Icons.fitness_center,
      Icons.brush_rounded,
      Icons.music_note_rounded,
      Icons.local_cafe_rounded,
      Icons.spa_rounded,
      Icons.self_improvement_rounded,
      Icons.shopping_bag_rounded,
      Icons.cleaning_services_rounded,
    ];

    final random = Random(42); // Fixed seed for consistent pattern

    return Stack(
      children: List.generate(20, (index) {
        final icon = icons[random.nextInt(icons.length)];
        final left = random.nextDouble() * MediaQuery.of(context).size.width;
        final top = random.nextDouble() * MediaQuery.of(context).size.height;
        final rotation = random.nextDouble() * 2 * pi;
        final size = 30.0 + random.nextDouble() * 20.0; // 30-50 size

        return Positioned(
          left: left,
          top: top,
          child: Transform.rotate(
            angle: rotation,
            child: Icon(
              icon,
              size: size,
              color: Colors.white.withValues(alpha: 0.03), // Very subtle ghost
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTrialTimeline(BuildContext context, Color goldColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Line
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
            child: Container(height: 2, color: goldColor.withOpacity(0.3)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineStep(
                title: AppLocalizations.of(context)!.trialToday,
                desc: AppLocalizations.of(context)!.trialTodayDesc,
                icon: Icons.lock_open_rounded,
                goldColor: goldColor,
              ),
              _buildTimelineStep(
                title: AppLocalizations.of(context)!.trialDay5,
                desc: AppLocalizations.of(context)!.trialDay5Desc,
                icon: Icons.notifications_active_rounded,
                goldColor: goldColor,
              ),
              _buildTimelineStep(
                title: AppLocalizations.of(context)!.trialDay7,
                desc: AppLocalizations.of(context)!.trialDay7Desc,
                icon: Icons.star_rounded,
                goldColor: goldColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String desc,
    required IconData icon,
    required Color goldColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF121212), // Match bg to hide line behind icon
            shape: BoxShape.circle,
            border: Border.all(color: goldColor, width: 2),
          ),
          child: Icon(icon, size: 16, color: goldColor),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }
}
