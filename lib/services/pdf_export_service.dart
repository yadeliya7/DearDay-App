import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets' as pw;
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

    // Get year from entries
    final year = sortedEntries.isNotEmpty
        ? sortedEntries.first.date.year
        : DateTime.now().year;

    // Load fonts for Turkish support
    final ttf = await PdfGoogleFonts.notoSerifRegular();
    final ttfBold = await PdfGoogleFonts.notoSerifBold();
    final ttfItalic = await PdfGoogleFonts.notoSerifItalic();

    // COVER PAGE
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                userName,
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 48,
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                '$year Günlüğüm',
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
                'Anılarım • Duygularım • Yolculuğum',
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

        // Story text
        if (entry.customStory != null && entry.customStory!.isNotEmpty)
          pw.Text(
            entry.customStory!,
            style: pw.TextStyle(
              font: ttf,
              fontSize: 12,
              height: 1.6,
              color: PdfColors.grey900,
            ),
            textAlign: pw.TextAlign.justify,
          ),

        // Note if no story
        if ((entry.customStory == null || entry.customStory!.isEmpty) &&
            entry.note != null &&
            entry.note!.isNotEmpty)
          pw.Text(
            entry.note!,
            style: pw.TextStyle(
              font: ttfItalic,
              fontSize: 12,
              height: 1.6,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.justify,
          ),

        pw.SizedBox(height: 20),

        // Photo if exists
        if (entry.mediaPaths.isNotEmpty)
          pw.FutureBuilder<pw.ImageProvider?>(
            future: _loadImage(entry.mediaPaths.first),
            builder: (context, data) {
              if (data.data != null) {
                return pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Image(
                    data.data!,
                    height: 200,
                    fit: pw.BoxFit.contain,
                  ),
                );
              }
              return pw.SizedBox();
            },
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
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Sayfa ${i + 2}',
              style: pw.TextStyle(
                font: ttfItalic,
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
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
              'Yılın Özeti',
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
              'Toplam Gün Sayısı',
              '${sortedEntries.length}',
              ttf,
              ttfBold,
            ),
            pw.SizedBox(height: 20),
            _buildStat(
              'En Çok Hissedilen Duygu',
              _getMoodName(topMood),
              ttf,
              ttfBold,
            ),
            pw.SizedBox(height: 20),
            _buildStat(
              'İlk Giriş',
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
              'Son Giriş',
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
                  '"Her gün bir sayfa, her sayfa bir anı..."',
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

  // Helper: Get mood name in Turkish
  String _getMoodName(String code) {
    switch (code) {
      case 'happy':
        return 'Mutlu';
      case 'sad':
        return 'Üzgün';
      case 'romantic':
        return 'Romantik';
      case 'mystic':
        return 'Mistik';
      case 'tired':
        return 'Yorgun';
      case 'hopeful':
        return 'Umutlu';
      case 'peaceful':
        return 'Huzurlu';
      case 'nostalgic':
        return 'Nostaljik';
      case 'angry':
        return 'Kızgın';
      default:
        return 'Bilinmiyor';
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
