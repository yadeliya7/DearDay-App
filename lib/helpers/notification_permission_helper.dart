import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';

class NotificationPermissionHelper {
  /// Shows a dialog explaining why exact alarm permission is needed
  static Future<void> showExactAlarmPermissionDialog(
    BuildContext context,
  ) async {
    if (!Platform.isAndroid) return;

    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '⏰ Bildirim İzni Gerekli',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Günlük hatırlatıcıların tam zamanında çalışması için "Alarmlar ve Hatırlatıcılar" iznine ihtiyaç var.\n\n'
          'Sonraki ekranda:\n'
          '1. "DearDay" uygulamasını bul\n'
          '2. "Alarms & reminders" iznini AÇ\n'
          '3. Geri dön',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(
              'Ayarlara Git',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldProceed == true && Platform.isAndroid) {
      try {
        const AndroidIntent intent = AndroidIntent(
          action: 'android.settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM',
        );
        await intent.launch();
      } catch (e) {
        // Fallback to app settings
        const AndroidIntent fallbackIntent = AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:com.ydliya.poem_diary',
        );
        await fallbackIntent.launch();
      }
    }
  }

  /// Shows battery optimization dialog
  static Future<void> showBatteryOptimizationDialog(
    BuildContext context,
  ) async {
    if (!Platform.isAndroid) return;

    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '🔋 Pil Optimizasyonu',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bildirimlerin arka planda çalışması için pil optimizasyonunu kapatmalısın.\n\n'
          'Sonraki ekranda:\n'
          '1. "All apps" veya "Tüm uygulamalar" seç\n'
          '2. "DearDay" uygulamasını bul\n'
          '3. "Don\'t optimize" veya "Optimizasyon yapma" seç',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text(
              'Ayarlara Git',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldProceed == true && Platform.isAndroid) {
      const AndroidIntent intent = AndroidIntent(
        action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        data: 'package:com.ydliya.poem_diary',
      );
      await intent.launch();
    }
  }
}
