import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

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
                            vertical: 20,
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

                              const SizedBox(height: 20),

                              // Animated Icon
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
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
                                    size: 60,
                                    color: goldColor,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Title & Subtitle
                              Text(
                                "DearDay Premium",
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Potansiyelini keşfet, en iyi versiyonuna ulaş.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Feature List
                              _buildFeatureItem(
                                "Sınırsız Hikaye Varyasyonları 📝",
                                goldColor,
                              ),
                              _buildFeatureItem(
                                "İlişkisel & Detaylı Analizler 📊",
                                goldColor,
                              ),
                              _buildFeatureItem(
                                "Yıllık Piksel Haritası (Year in Pixels) 📅",
                                goldColor,
                              ),
                              _buildFeatureItem(
                                "PDF Günlük Çıktısı 📕",
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
                                id: 'weekly',
                                title: 'Haftalık Plan',
                                price: '₺29.99 / hafta',
                                subtitle: null,
                                isBestValue: false,
                                goldColor: goldColor,
                              ),
                              const SizedBox(height: 12),
                              _buildPlanCard(
                                id: 'monthly',
                                title: 'Aylık Plan',
                                price: '₺49.99 / ay',
                                subtitle: null,
                                isBestValue: false,
                                goldColor: goldColor,
                              ),
                              const SizedBox(height: 12),
                              _buildPlanCard(
                                id: 'yearly',
                                title: 'Yıllık Plan',
                                price: '₺299.99 / yıl',
                                subtitle: '₺24.99 / ay',
                                isBestValue: true,
                                goldColor: goldColor,
                              ),
                              const SizedBox(height: 12),
                              _buildPlanCard(
                                id: 'lifetime',
                                title: 'Ömür Boyu',
                                price: '₺999.99',
                                subtitle: 'Tek seferlik ödeme',
                                isBestValue: false,
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
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      _selectedPlan == 'weekly'
                                          ? "Premium Ol"
                                          : "Ücretsiz Denemeyi Başlat",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Footer Links
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildFooterLink("Restore Purchase"),
                                  _buildFooterDivider(),
                                  _buildFooterLink("Terms of Use"),
                                  _buildFooterDivider(),
                                  _buildFooterLink("Privacy Policy"),
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
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 32),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
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
    required bool isBestValue,
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
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: goldColor,
                        fontSize: 12,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isBestValue) ...[
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
                      "EN POPÜLER",
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
}
