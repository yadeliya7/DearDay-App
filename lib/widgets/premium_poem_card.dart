import 'package:flutter/material.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Titreşim için
// import 'dart:ui'; // Unnecessary
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';

import '../core/theme.dart';
import '../core/premium_effects.dart';
import '../core/providers.dart';
import '../core/language_provider.dart';

import '../models/poem_model.dart';
import '../core/gradient_palette.dart';
import '../utils/content_utils.dart';
import 'shareable_poem_card.dart';
import '../screens/poem_detail_screen.dart';
import '../widgets/mood_entry_dialog.dart'; // For buildMediaThumbnail

// UYGULAMADAKİ TÜM RESİMLERİN LİSTESİ
const List<String> availableBackgrounds = [
  'assets/images/bg_1.jpg',
  'assets/images/bg_2.jpg',
  'assets/images/bg_3.jpg',
  'assets/images/bg_4.jpg',
  'assets/images/bg_5.jpg',
  'assets/images/bg_6.jpg',
];

class PremiumPoemCard extends StatefulWidget {
  final Poem poem;
  final VoidCallback onTap;
  final bool showUI;
  final bool isCleanStyle; // New parameter for clean white background style
  final bool showExpandButton;
  final bool showFavoriteButton;

  const PremiumPoemCard({
    super.key,
    required this.poem,
    required this.onTap,
    this.showUI = true,
    this.isCleanStyle = false,
    this.showExpandButton = true,
    this.showFavoriteButton = true,
  });

  @override
  State<PremiumPoemCard> createState() => _PremiumPoemCardState();
}

class _PremiumPoemCardState extends State<PremiumPoemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _uiVisible = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationConstants.mediumAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AnimationConstants.smoothCurve,
      ),
    );
    _uiVisible = widget.showUI;

    // Always fade in the content
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleUI() {
    if (_uiVisible) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _uiVisible = !_uiVisible;
    });
  }

  Future<void> _handleShare(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Provider.of<ThemeProvider>(context).isDarkMode
              ? AppTheme.darkBackground
              : AppTheme.lightBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: Text(AppLocalizations.of(context)!.shareText),
                onTap: () async {
                  Navigator.pop(ctx);
                  // ignore: deprecated_member_use
                  await Share.share(
                    '${widget.poem.content}\n\n- ${widget.poem.author}',
                    subject: 'Şiir: ${widget.poem.id}',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(AppLocalizations.of(context)!.shareImage),
                subtitle: Text(
                  AppLocalizations.of(context)!.shareImageSubtitle,
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _sharePoemAsImage(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sharePoemAsImage(BuildContext context) async {
    setState(() => _isSharing = true);

    try {
      final activeImage = widget.poem.backgroundImage.isNotEmpty
          ? widget.poem.backgroundImage
          : 'assets/images/bg_1.jpg';

      if (!context.mounted) return;

      // Get font family from provider BEFORE the off-screen capture
      final fontFamily = Provider.of<PoemProvider>(
        context,
        listen: false,
      ).contentFontFamily;

      final currentLocale = Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).currentLanguage;

      // Split content into pages using smart pagination
      final pages = splitContentIntoPages(widget.poem.content);
      final List<XFile> filesToShare = [];

      // Generate an image for each page
      for (int i = 0; i < pages.length; i++) {
        if (!context.mounted) return;
        final pageContent = pages[i];
        final pageNumber = i + 1;
        final totalPages = pages.length;

        // Capture this page as an image
        final Uint8List imageBytes = await _screenshotController
            .captureFromWidget(
              ShareablePoemCard(
                poem: widget.poem,
                pageContent: pageContent,
                pageNumber: pageNumber,
                totalPages: totalPages,
                backgroundImage: activeImage,
                fontFamily: fontFamily,
                locale: currentLocale,
              ),
              delay: const Duration(milliseconds: 100),
              context: context,
            );

        // Save to temp file
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/poem_share_${widget.poem.id}_page_$pageNumber.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);

        // Add to share list
        filesToShare.add(XFile(imagePath));
      }

      // Share all pages at once
      final shareText = pages.length > 1
          ? 'Bu harika şiiri oku! (${pages.length} sayfa) ✨'
          : 'Bu harika şiiri oku! ✨';

      await Share.shareXFiles(filesToShare, text: shareText);
    } catch (e) {
      debugPrint('Paylaşım hatası: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.shareError} $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    final accentColor = isDarkMode ? AppTheme.darkAccent : AppTheme.lightAccent;

    // Determine colors based on style
    final textColor = widget.isCleanStyle
        ? (isDarkMode ? Colors.white : Colors.black)
        : Colors.white;
    final secondaryTextColor = widget.isCleanStyle
        ? (isDarkMode ? Colors.white70 : Colors.black54)
        : Colors.white70;
    final backgroundColor = widget.isCleanStyle
        ? (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white)
        : null; // Null means use decoration image

    // Aktif Resmi Belirle
    String activeImage = widget.poem.backgroundImage.isNotEmpty
        ? widget.poem.backgroundImage
        : 'assets/images/bg_1.jpg';

    return GestureDetector(
      onTap: _toggleUI,
      child: Container(
        height: 500,
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ), // Kenar boşluklarını azalttık
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: PremiumEffects.premiumRadius,
          boxShadow: PremiumEffects.museumShadow(),
        ),
        child: ClipRRect(
          borderRadius: PremiumEffects.premiumRadius,
          child: Stack(
            children: [
              // 1. & 2. KATMAN BİRLEŞTİRİLDİ (Resim/Gradient + Karartma Filtresi)
              if (!widget.isCleanStyle)
                Positioned.fill(
                  child: Container(
                    decoration: widget.poem.gradientId != null
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: GradientPalette.getById(
                                widget.poem.gradientId,
                              ).colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          )
                        : BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(activeImage),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.4),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                  ),
                ),
              // 3. KATMAN: İçerik (Şiir vs.)
              // 3. KATMAN: İçerik (Şiir vs.)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row (Date + Icons)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              _formatDate(widget.poem.createdAt),
                              style: GoogleFonts.montserrat(
                                color: secondaryTextColor,
                                letterSpacing: 2.0,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              /* Favorite button removed from header as per user request */
                              if (widget.poem.mediaPaths.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.attach_file,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                ),
                              if (widget.showExpandButton)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PoemDetailScreen(poem: widget.poem),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.open_in_full,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            widget.poem.title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont(
                              Provider.of<PoemProvider>(
                                context,
                              ).contentFontFamily,
                              color: textColor,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              shadows: widget.isCleanStyle
                                  ? []
                                  : PremiumEffects.textShadow(Colors.white),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Expanded Body
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Center(
                            child: Text(
                              widget.poem.content,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.getFont(
                                Provider.of<PoemProvider>(
                                  context,
                                ).contentFontFamily,
                                color: textColor,
                                fontSize: 18,
                                height: 1.6,
                                fontWeight: FontWeight.w600,
                                shadows: widget.isCleanStyle
                                    ? []
                                    : PremiumEffects.textShadow(Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- Media Gallery ---
                      if (widget.poem.mediaPaths.isNotEmpty)
                        Container(
                          height: 120,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.poem.mediaPaths.length,
                            itemBuilder: (context, index) {
                              final path = widget.poem.mediaPaths[index];
                              final isImage = [
                                'jpg',
                                'jpeg',
                                'png',
                                'heic',
                                'webp',
                              ].contains(path.split('.').last.toLowerCase());

                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (isImage) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: InteractiveViewer(
                                            child: Image.file(File(path)),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: buildMediaThumbnail(path),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Footer Signature
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            '~ ${widget.poem.author}',
                            style: GoogleFonts.nunito(
                              color: secondaryTextColor,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              shadows: widget.isCleanStyle
                                  ? []
                                  : PremiumEffects.textShadow(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. KATMAN: UI Butonları (EN AŞAĞIDA)
              if (_uiVisible)
                Positioned(
                  bottom: 30, // DÜZELTME: En alttan 30px yukarıda sabit
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    // <-- Animasyon içeride
                    opacity: _fadeAnimation,
                    child: Center(
                      child: _buildUIControls(context, accentColor),
                    ),
                  ),
                ),

              if (_isSharing)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUIControls(BuildContext context, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.5,
        ), // Arka planı biraz daha koyu yaptık
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        // Glassmorphism etkisi için blur eklenebilir ama şu an sade kalsın
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // BEĞEN BUTONU
          _buildIconButton(
            icon: widget.poem.isFavorite
                ? Icons.favorite
                : Icons.favorite_border,
            onPressed: () {
              HapticFeedback.lightImpact();
              Provider.of<PoemProvider>(
                context,
                listen: false,
              ).toggleFavorite(widget.poem.id);
            },
            color: widget.poem.isFavorite ? Colors.redAccent : accentColor,
            size: 28,
          ),
          const SizedBox(width: 30), // İkonlar arası boşluğu açtık
          // PAYLAŞ BUTONU
          _buildIconButton(
            icon: Icons.share_outlined, // iOS tarzı şık paylaş butonu
            onPressed: () {
              HapticFeedback.lightImpact();
              _handleShare(context);
            },
            color: accentColor,
            size: 28,
          ),
          const SizedBox(width: 30),

          // RESİM DEĞİŞTİR BUTONU
          _buildIconButton(
            icon: Icons.style, // Daha anlamlı ikon
            onPressed: () {
              HapticFeedback.lightImpact();
              _showDesignMenu(context);
            },
            color: accentColor,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    double size = 24,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(icon, color: color, size: size),
    );
  }

  // ALT MENÜ (TASARIM SEÇİCİ) - GÜNCELLENDİ (Tabs: Gallery & Colors)
  void _showDesignMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7, // Bir tık artırdık
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
          return Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkBackground.withValues(alpha: 0.98)
                  : AppTheme.lightBackground.withValues(alpha: 0.98),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    // Handle Bar
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Başlık ve TabBar
                    Text(
                      AppLocalizations.of(context)!.designBgTitle,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    TabBar(
                      labelColor: isDark
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      unselectedLabelColor: isDark
                          ? Colors.white54
                          : Colors.black54,
                      indicatorColor: isDark
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          text: AppLocalizations.of(context)!.tabGallery,
                          icon: const Icon(Icons.image),
                        ),
                        Tab(
                          text: AppLocalizations.of(context)!.tabColors,
                          icon: const Icon(Icons.color_lens),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tab Views
                    Expanded(
                      child: Consumer<PoemProvider>(
                        builder: (context, poemProvider, child) {
                          final currentPoem =
                              poemProvider.getPoemById(widget.poem.id) ??
                              widget.poem;

                          return TabBarView(
                            children: [
                              // TAB 1: GALERİ (Mevcut Grid Logic)
                              GridView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 0.6,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                itemCount: 50,
                                itemBuilder: (context, index) {
                                  final imagePath =
                                      'assets/images/bg_${index + 1}.jpg';
                                  final isSelected =
                                      currentPoem.backgroundImage == imagePath;

                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      poemProvider.updatePoemBackground(
                                        widget.poem.id,
                                        imagePath,
                                      );
                                      // Navigator.pop(context); // Keep menu open to show selection
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: isSelected
                                            ? Border.all(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                width: 3,
                                              )
                                            : null,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          imagePath,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey.withValues(
                                                    alpha: 0.2,
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                    ),
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // TAB 2: RENKLER (Gradient Logic)
                              GridView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1.0, // Kare
                                      crossAxisSpacing: 15,
                                      mainAxisSpacing: 15,
                                    ),
                                itemCount: GradientPalette.gradients.length,
                                itemBuilder: (context, index) {
                                  final gradient =
                                      GradientPalette.gradients[index];
                                  final isSelected =
                                      currentPoem.gradientId == gradient.id;

                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      poemProvider.updatePoemGradient(
                                        widget.poem.id,
                                        gradient.id,
                                      );
                                      // Navigator.pop(context); // Keep menu open to show selection
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: gradient.colors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.white,
                                                width: 4,
                                              ) // Seçiliyken beyaz kalın çerçeve
                                            : null,
                                        boxShadow: [
                                          BoxShadow(
                                            color: gradient.colors.first
                                                .withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 30,
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      final langCode = Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).currentLanguage;
      final locale = langCode == 'tr' ? 'tr_TR' : 'en_US';
      return DateFormat('d MMMM yyyy, EEEE', locale).format(date).toUpperCase();
    } catch (e) {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
