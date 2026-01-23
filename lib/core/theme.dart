import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // DARK MODE (Soft Dark)
  static const Color darkBackground = Color(0xFF181818);
  static const Color darkText = Color(0xFFF0F0F0);
  static const Color darkAccent = Color(0xFFE0C097);

  // LIGHT MODE (Soft White)
  static const Color lightBackground = Color(0xFFFFF9E5);
  static const Color lightText = Color(0xFF2D2D2D);
  static const Color lightAccent = Color(0xFFB59D7F);

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,

      // TÜM FONT AİLESİ: NUNITO
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            // Başlıklar (Kalın ve Yuvarlak)
            headlineLarge: GoogleFonts.nunito(
              fontSize: 30,
              fontWeight: FontWeight.w800, // Nunito kalınken çok tatlı durur
              color: darkText,
            ),
            // Şiir Metni (Okunaklı)
            headlineMedium: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w600, // Biraz dolgun olsun
              height: 1.6,
              color: darkText,
            ),
            // Menü ve Butonlar (Ayarlar, Hakkında vs.)
            bodyLarge: GoogleFonts.nunito(
              fontSize: 17, // Menüler rahat okunsun
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
            bodyMedium: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: darkText.withValues(alpha: 0.8),
            ),
          ),

      colorScheme: ColorScheme.dark(
        primary: darkAccent,
        surface: darkBackground,
        onSurface: darkText,
      ),
      iconTheme: const IconThemeData(color: darkText),
    );
  }

  // PEACH THEME (Warm & Premium)
  static const Color peachScaffold = Color(0xFFFFE0B2);
  static const Color peachSurface = Color(0xFFFFF3E0);
  static const Color peachTextPrimary = Color(0xFF3E2723);
  static const Color peachTextSecondary = Color(0xFF5D4037);
  static const Color peachAccent = Color(0xFFFF7043);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 1. Base Colors
      scaffoldBackgroundColor: peachScaffold,
      primaryColor: peachAccent,

      // 2. Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: peachScaffold,
        surface: peachSurface,
        onSurface: peachTextPrimary,
        primary: peachAccent,
        secondary: peachAccent,
      ),

      // 3. Card Theme
      cardTheme: CardThemeData(
        color: peachSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.brown.withValues(alpha: 0.1),
      ),

      // 4. Typography
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.nunito(
              color: peachTextPrimary,
              fontWeight: FontWeight.bold,
            ),
            headlineLarge: GoogleFonts.nunito(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: peachTextPrimary,
            ),
            headlineMedium: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.6,
              color: peachTextPrimary,
            ),
            titleLarge: GoogleFonts.nunito(
              color: peachTextPrimary,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: peachTextSecondary,
            ),
            bodyMedium: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: peachTextSecondary,
            ),
          ),

      // 5. AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: peachScaffold,
        elevation: 0,
        iconTheme: IconThemeData(color: peachTextPrimary),
        titleTextStyle: GoogleFonts.nunito(
          color: peachTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 6. Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: peachSurface,
        selectedItemColor: peachAccent,
        unselectedItemColor: peachTextSecondary,
        showUnselectedLabels: false, // Optional: clean look
      ),

      iconTheme: const IconThemeData(color: peachTextPrimary),
    );
  }
}
