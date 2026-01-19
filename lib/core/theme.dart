import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // DARK MODE (Soft Dark)
  static const Color darkBackground = Color(0xFF181818);
  static const Color darkText = Color(0xFFF0F0F0);
  static const Color darkAccent = Color(0xFFE0C097);

  // LIGHT MODE (Soft White)
  static const Color lightBackground = Color(0xFFF9F9F9);
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

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,

      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme)
          .copyWith(
            headlineLarge: GoogleFonts.nunito(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: lightText,
            ),
            headlineMedium: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.6,
              color: lightText,
            ),
            bodyLarge: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: lightText,
            ),
            bodyMedium: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: lightText.withValues(alpha: 0.8),
            ),
          ),

      colorScheme: ColorScheme.light(
        primary: lightAccent,
        surface: lightBackground,
        onSurface: lightText,
      ),
      iconTheme: const IconThemeData(color: lightText),
    );
  }
}
