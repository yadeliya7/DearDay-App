import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/daily_entry_model.dart';

class PdfExportService {
  /// Generate a beautifully designed PDF journal
  Future<Uint8List> generateJournalPdf(
    List<DailyEntry> entries, {
    String userName = 'My Journey',
    String locale = 'tr_TR',
  }) async {
    final pdf = pw.Document();

    // Sort entries by date
    final sortedEntries = entries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate Year Range
    String yearDisplay;
    if (sortedEntries.isNotEmpty) {
      final minYear = sortedEntries.first.date.year;
      final maxYear = sortedEntries.last.date.year;
      if (minYear == maxYear) {
        yearDisplay = '$minYear';
      } else {
        yearDisplay = '$minYear - $maxYear';
      }
    } else {
      yearDisplay = '${DateTime.now().year}';
    }

    // Load fonts for Turkish support
    final ttf = await PdfGoogleFonts.notoSerifRegular();
    final ttfBold = await PdfGoogleFonts.notoSerifBold();
    final ttfItalic = await PdfGoogleFonts.notoSerifItalic();

    // Load app icon
    final appIcon = await _loadAppIcon();

    // COVER PAGE
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'DearDay',
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 48,
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                userName,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 18,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                '$yearDisplay ${_t('journal_title', locale)}',
                style: pw.TextStyle(
                  font: ttfItalic,
                  fontSize: 24,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 60),
              // Decorative line
              pw.Container(width: 200, height: 2, color: PdfColors.grey400),
              pw.SizedBox(height: 40),
              pw.Text(
                _t('journal_subtitle', locale),
                style: pw.TextStyle(
                  font: ttfItalic,
                  fontSize: 14,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // CONTENT PAGES - Each entry
    for (var i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final dateStr = DateFormat(
        'dd MMMM yyyy, EEEE',
        locale,
      ).format(entry.date);

      // Load image if exists
      pw.ImageProvider? entryImage;
      if (entry.mediaPaths.isNotEmpty) {
        entryImage = await _loadImage(entry.mediaPaths.first);
      }

      // 1. Prep Story Text
      final storyText = entry.customStory ?? entry.savedStory;

      // Build page content
      final pageContent = <pw.Widget>[
        // Header: Date + Mood
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              dateStr,
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 16,
                color: PdfColors.grey800,
              ),
            ),
            // Mood indicator circle
            pw.Container(
              width: 20,
              height: 20,
              decoration: pw.BoxDecoration(
                color: _getMoodPdfColor(entry.moodCode),
                shape: pw.BoxShape.circle,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 16),

        // 1. THE STORY (Only if it exists)
        if (storyText != null && storyText.trim().isNotEmpty) ...[
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Text(
              storyText,
              style: pw.TextStyle(
                font: ttfItalic,
                fontSize: 10,
                color: PdfColors.grey700,
                fontStyle: pw.FontStyle.italic,
              ),
              textAlign: pw.TextAlign.justify,
            ),
          ),
          pw.SizedBox(height: 5), // Small gap after story
        ],

        // 2. THE MANUAL NOTE (Only if it exists)
        if (entry.note != null && entry.note!.trim().isNotEmpty) ...[
          pw.Text(
            entry.note!,
            style: pw.TextStyle(
              font: ttf, // Regular font
              fontSize: 11,
              color: PdfColors.black,
            ),
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 10),
        ],

        // Separator between text and media
        if (entry.mediaPaths.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
          pw.SizedBox(height: 20),
        ],

        pw.SizedBox(height: 20),

        // Photo if exists
        if (entryImage != null)
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Image(entryImage, height: 200, fit: pw.BoxFit.contain),
          ),

        pw.Spacer(),

        // Footer
        pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (appIcon != null) ...[
                pw.Image(
                  appIcon,
                  width: 16,
                  height: 16,
                  fit: pw.BoxFit.contain,
                ),
                pw.SizedBox(width: 6),
              ],
              pw.Text(
                'Created with DearDay  •  ${_t('page', locale)} ${i + 2}',
                style: pw.TextStyle(
                  font: ttfItalic,
                  fontSize: 10,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: pageContent,
          ),
        ),
      );
    }

    // SUMMARY PAGE
    final moodCounts = <String, int>{};
    for (var entry in sortedEntries) {
      moodCounts[entry.moodCode] = (moodCounts[entry.moodCode] ?? 0) + 1;
    }

    final topMood = moodCounts.entries.isEmpty
        ? 'Yok'
        : moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _t('year_summary', locale),
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 32,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 40),
            pw.Divider(color: PdfColors.grey300, thickness: 2),
            pw.SizedBox(height: 30),

            // Statistics
            _buildStat(
              _t('total_days', locale),
              '${sortedEntries.length}',
              ttf,
              ttfBold,
            ),
            pw.SizedBox(height: 20),
            _buildStat(
              _t('top_mood', locale),
              _getMoodName(topMood, locale),
              ttf,
              ttfBold,
            ),
            pw.SizedBox(height: 20),
            _buildStat(
              _t('first_entry', locale),
              sortedEntries.isNotEmpty
                  ? DateFormat(
                      'dd MMMM yyyy',
                      locale,
                    ).format(sortedEntries.first.date)
                  : '-',
              ttf,
              ttfBold,
            ),
            pw.SizedBox(height: 20),
            _buildStat(
              _t('last_entry', locale),
              sortedEntries.isNotEmpty
                  ? DateFormat(
                      'dd MMMM yyyy',
                      locale,
                    ).format(sortedEntries.last.date)
                  : '-',
              ttf,
              ttfBold,
            ),

            pw.Spacer(),

            // Footer quote
            pw.Center(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Text(
                  _t('quote', locale),
                  style: pw.TextStyle(
                    font: ttfItalic,
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  /// Preview and share PDF using native print/share dialog
  Future<void> previewAndSharePdf(
    List<DailyEntry> entries, {
    String userName = 'My Journey',
    String locale = 'tr_TR',
  }) async {
    await Printing.layoutPdf(
      onLayout: (format) =>
          generateJournalPdf(entries, userName: userName, locale: locale),
      name: 'gunlugum_${DateTime.now().year}.pdf',
    );
  }

  // Helper: Load image from file path
  Future<pw.ImageProvider?> _loadImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return pw.MemoryImage(bytes);
      }
    } catch (e) {
      // Ignore errors
    }
    return null;
  }

  // Helper: Load app icon from assets
  Future<pw.ImageProvider?> _loadAppIcon() async {
    try {
      final iconData = await rootBundle.load('assets/icon/app_icon2.png');
      return pw.MemoryImage(iconData.buffer.asUint8List());
    } catch (e) {
      // Ignore errors
    }
    return null;
  }

  // Helper: Get PDF color for mood
  PdfColor _getMoodPdfColor(String moodCode) {
    switch (moodCode) {
      case 'happy':
        return PdfColor.fromHex('#FFD54F');
      case 'sad':
        return PdfColor.fromHex('#64B5F6');
      case 'romantic':
        return PdfColor.fromHex('#F48FB1');
      case 'mystic':
        return PdfColor.fromHex('#BA68C8');
      case 'tired':
        return PdfColor.fromHex('#90A4AE');
      case 'hopeful':
        return PdfColor.fromHex('#81C784');
      case 'peaceful':
        return PdfColor.fromHex('#4DD0E1');
      case 'nostalgic':
        return PdfColor.fromHex('#FFB74D');
      case 'angry':
        return PdfColor.fromHex('#E57373');
      default:
        return PdfColors.grey;
    }
  }

  // Helper: Translate strings for PDF
  String _t(String key, String locale) {
    final isTr = locale.startsWith('tr');
    switch (key) {
      case 'journal_title':
        return isTr ? 'Günlüğüm' : 'My Journal';
      case 'journal_subtitle':
        return isTr
            ? 'Anılarım • Duygularım • Yolculuğum'
            : 'Memories • Feelings • Journey';
      case 'page':
        return isTr ? 'Sayfa' : 'Page';
      case 'year_summary':
        return isTr ? 'Yılın Özeti' : 'Year in Review';
      case 'total_days':
        return isTr ? 'Toplam Gün Sayısı' : 'Total Days';
      case 'top_mood':
        return isTr ? 'En Çok Hissedilen Duygu' : 'Dominant Mood';
      case 'first_entry':
        return isTr ? 'İlk Giriş' : 'First Entry';
      case 'last_entry':
        return isTr ? 'Son Giriş' : 'Last Entry';
      case 'quote':
        return isTr
            ? '"Her gün bir sayfa, her sayfa bir anı..."'
            : '"Every day is a page, every page is a memory..."';
      default:
        return key;
    }
  }

  // Helper: Get mood name in Turkish/English
  String _getMoodName(String code, String locale) {
    final isTr = locale.startsWith('tr');
    switch (code) {
      case 'happy':
        return isTr ? 'Mutlu' : 'Happy';
      case 'sad':
        return isTr ? 'Üzgün' : 'Sad';
      case 'romantic':
        return isTr ? 'Romantik' : 'Romantic';
      case 'mystic':
        return isTr ? 'Mistik' : 'Mystic';
      case 'tired':
        return isTr ? 'Yorgun' : 'Tired';
      case 'hopeful':
        return isTr ? 'Umutlu' : 'Hopeful';
      case 'peaceful':
        return isTr ? 'Huzurlu' : 'Peaceful';
      case 'nostalgic':
        return isTr ? 'Nostaljik' : 'Nostalgic';
      case 'angry':
        return isTr ? 'Kızgın' : 'Angry';
      default:
        return isTr ? 'Bilinmiyor' : 'Unknown';
    }
  }

  // Helper: Build stat row
  pw.Widget _buildStat(
    String label,
    String value,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: regular,
            fontSize: 14,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: bold,
            fontSize: 14,
            color: PdfColors.grey900,
          ),
        ),
      ],
    );
  }
}
