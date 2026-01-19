import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../models/poem_model.dart';
import '../core/premium_effects.dart';

/// A beautiful shareable card widget for poems.
///
/// Supports pagination for long poems - displays page numbers when multiple pages exist.
class ShareablePoemCard extends StatelessWidget {
  final Poem poem;
  final String pageContent;
  final int pageNumber;
  final int totalPages;
  final String backgroundImage;
  final String fontFamily;
  final String locale;

  const ShareablePoemCard({
    super.key,
    required this.poem,
    required this.pageContent,
    required this.pageNumber,
    required this.totalPages,
    required this.backgroundImage,
    required this.fontFamily,
    required this.locale,
  });

  String _formatDate(DateTime date) {
    final months = [
      'OCAK',
      'ŞUBAT',
      'MART',
      'NİSAN',
      'MAYIS',
      'HAZİRAN',
      'TEMMUZ',
      'AĞUSTOS',
      'EYLÜL',
      'EKİM',
      'KASIM',
      'ARALIK',
    ];
    final weekdays = [
      'PAZARTESİ',
      'SALI',
      'ÇARŞAMBA',
      'PERŞEMBE',
      'CUMA',
      'CUMARTESİ',
      'PAZAR',
    ];
    return '${date.day} ${months[date.month - 1]}, ${weekdays[date.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 1000, // Fixed height for consistent image capture
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section: Date and Title
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDate(poem.createdAt),
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    letterSpacing: 2.0,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  poem.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.getFont(
                    fontFamily,
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    shadows: PremiumEffects.textShadow(Colors.white),
                  ),
                ),
              ],
            ),

            // Middle section: Poem content (flexible space)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: AutoSizeText(
                    pageContent,
                    textAlign: TextAlign.center,
                    minFontSize: 14,
                    maxFontSize: 22, // Original size
                    stepGranularity: 0.5,
                    maxLines: 25, // Safety limit
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      fontFamily,
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      shadows: PremiumEffects.textShadow(Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom section: Author and Footer
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '- ${poem.author}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    fontFamily,
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    shadows: PremiumEffects.textShadow(Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
                // Page indicator (only if multiple pages)
                if (totalPages > 1) ...[
                  Text(
                    'Sayfa $pageNumber / $totalPages',
                    style: GoogleFonts.montserrat(
                      color: Colors.white60,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                // Branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white54, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      locale == 'tr'
                          ? 'Habitual ile oluşturuldu'
                          : 'Created with Habitual',
                      style: GoogleFonts.montserrat(
                        color: Colors.white54,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
