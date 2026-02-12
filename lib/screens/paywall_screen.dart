import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:poem_diary/services/notification_service.dart';
import 'package:poem_diary/services/purchase_service.dart';
import 'package:provider/provider.dart';
import 'package:poem_diary/core/providers.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:ui';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // RevenueCat state
  Offerings? _offerings;
  bool _isLoading = true;
  bool _isPurchasing = false;

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

    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await PurchaseService().getOfferings();
      if (mounted) {
        setState(() {
          _offerings = offerings;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading offerings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePurchase() async {
    if (_offerings?.current == null) {
      _showError(context, 'No offerings available');
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      Package? selectedPackage;

      switch (_selectedPlan) {
        case 'monthly':
          selectedPackage = _offerings!.current!.monthly;
          break;
        case 'yearly':
          selectedPackage = _offerings!.current!.annual;
          break;
        case 'lifetime':
          selectedPackage = _offerings!.current!.lifetime;
          break;
      }

      if (selectedPackage == null) {
        _showError(context, 'Selected plan not available');
        setState(() => _isPurchasing = false);
        return;
      }

      final success = await PurchaseService().purchasePackage(selectedPackage);

      if (success && mounted) {
        // Update premium status
        Provider.of<PremiumProvider>(context, listen: false).setPremium(true);

        // Schedule trial reminder if yearly
        if (_selectedPlan == 'yearly') {
          NotificationService().scheduleTrialEndingReminder(
            AppLocalizations.of(context)!.notificationTrialTitle,
            AppLocalizations.of(context)!.notificationTrialBody,
          );
        }

        // Show success and close
        _showSuccess(context);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      if (mounted) _showError(context, 'Purchase failed');
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);

    try {
      final success = await PurchaseService().restorePurchases();

      if (success && mounted) {
        Provider.of<PremiumProvider>(context, listen: false).setPremium(true);
        _showSuccess(
          context,
          message: AppLocalizations.of(context)!.restoreSuccess,
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      } else if (mounted) {
        _showError(
          context,
          AppLocalizations.of(context)!.restoreNoSubscription,
        );
      }
    } catch (e) {
      debugPrint('Restore error: $e');
      if (mounted) {
        _showError(context, AppLocalizations.of(context)!.restoreError);
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(BuildContext context, {String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Purchase successful! ✨'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
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
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Column(
                                  children: [
                                    _buildPlanCard(
                                      id: 'yearly',
                                      title: AppLocalizations.of(
                                        context,
                                      )!.planYearly,
                                      price:
                                          _offerings
                                              ?.current
                                              ?.annual
                                              ?.storeProduct
                                              .priceString ??
                                          AppLocalizations.of(
                                            context,
                                          )!.priceYearlyMock,
                                      subtitle:
                                          _offerings?.current?.annual != null
                                          ? (() {
                                              final product = _offerings!
                                                  .current!
                                                  .annual!
                                                  .storeProduct;
                                              final monthlyPrice =
                                                  product.price / 12;
                                              // Create a formatter that uses the currency code (e.g., 'USD', 'TRY')
                                              final formatter =
                                                  NumberFormat.simpleCurrency(
                                                    name: product.currencyCode,
                                                  );
                                              // Format the price (this handles symbol placement)
                                              return "${formatter.format(monthlyPrice)} ${AppLocalizations.of(context)!.perMonthSuffix}";
                                            })()
                                          : AppLocalizations.of(
                                              context,
                                            )!.priceMonthlyBreakdownMock,
                                      badgeText: AppLocalizations.of(
                                        context,
                                      )!.bestValue,
                                      trialText: AppLocalizations.of(
                                        context,
                                      )!.trialBadge,
                                      goldColor: goldColor,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildPlanCard(
                                      id: 'monthly',
                                      title: AppLocalizations.of(
                                        context,
                                      )!.planMonthly,
                                      price:
                                          _offerings
                                              ?.current
                                              ?.monthly
                                              ?.storeProduct
                                              .priceString ??
                                          AppLocalizations.of(
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
                                      price:
                                          _offerings
                                              ?.current
                                              ?.lifetime
                                              ?.storeProduct
                                              .priceString ??
                                          AppLocalizations.of(
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
                              // Removed as per request
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
                                    onPressed: _isPurchasing
                                        ? null
                                        : _handlePurchase,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isPurchasing
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.black,
                                                  ),
                                            ),
                                          )
                                        : Text(
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
                              const SizedBox(height: 12),
                              // Use Visibility with maintainSize to prevent layout shift
                              Visibility(
                                visible: _selectedPlan == 'yearly',
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: Text(
                                  AppLocalizations.of(context)!.trialGuarantee,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                              // Footer Links
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildFooterLink(
                                    AppLocalizations.of(
                                      context,
                                    )!.restorePurchase,
                                    onTap: _isPurchasing
                                        ? null
                                        : _handleRestore,
                                  ),
                                  _buildFooterDivider(),
                                  _buildFooterLink(
                                    AppLocalizations.of(context)!.termsOfUse,
                                    onTap: () async {
                                      final url = Uri.parse(
                                        'https://doc-hosting.flycricket.io/dearday/b2bf9bab-9ff3-445d-8973-9aef9fb49566/terms',
                                      );
                                      if (!await launchUrl(url)) {
                                        if (context.mounted) {
                                          _showError(
                                            context,
                                            'Could not launch $url',
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  _buildFooterDivider(),
                                  _buildFooterLink(
                                    AppLocalizations.of(context)!.privacyPolicy,
                                    onTap: () async {
                                      final url = Uri.parse(
                                        'https://doc-hosting.flycricket.io/dearday/efe4dc1a-e0f0-41af-a53f-d28e0e512237/privacy',
                                      );
                                      if (!await launchUrl(url)) {
                                        if (context.mounted) {
                                          _showError(
                                            context,
                                            'Could not launch $url',
                                          );
                                        }
                                      }
                                    },
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
    String? trialText,
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
                if (trialText != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trialText,
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

  Widget _buildFooterLink(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
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
}
