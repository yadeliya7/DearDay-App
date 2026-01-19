import 'dart:io';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../core/providers.dart';

import '../models/poem_model.dart';

class ComposePoemScreen extends StatefulWidget {
  const ComposePoemScreen({super.key});

  @override
  State<ComposePoemScreen> createState() => _ComposePoemScreenState();
}

class _ComposePoemScreenState extends State<ComposePoemScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _selectedMedia = []; // Store selected media paths

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // --- Media Picking Logic ---
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (!mounted) return;
      if (images.isNotEmpty) {
        setState(() {
          _selectedMedia.addAll(images.map((img) => img.path));
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Resim seçilirken hata oluştu')));
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (!mounted) return;
      if (video != null) {
        setState(() {
          _selectedMedia.add(video.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Video seçilirken hata oluştu')));
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  // --- Thumbnail Builder (Local Safe Version) ---
  Widget _buildMediaThumbnail(String path) {
    final ext = path.split('.').last.toLowerCase();
    final isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
    final isImage = ['jpg', 'jpeg', 'png', 'heic', 'webp'].contains(ext);

    if (isVideo) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.black87,
            child: const Center(
              child: Icon(Icons.videocam, color: Colors.white54, size: 32),
            ),
          ),
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
        ],
      );
    } else if (isImage) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    } else {
      // Fallback for other files (PDF, Audio, etc.)
      return Container(
        color: Colors.grey[800],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.white54),
            const SizedBox(height: 4),
            Text(
              ext.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _savePoem() {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen başlık ve şiir içeriğini girin.',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newPoem = Poem(
      id: DateTime.now().toString(),
      title: _titleController.text,
      content: _contentController.text,
      author: _authorController.text.trim().isEmpty
          ? 'Ben'
          : _authorController.text.trim(),
      mood: 'happy', // Default mood
      createdAt: DateTime.now(),
      mediaPaths: _selectedMedia, // Save selected media
    );

    Provider.of<PoemProvider>(context, listen: false).addUserPoem(newPoem);
    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Şiirin günlüğüne eklendi! ✨',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fontName = Provider.of<PoemProvider>(context).contentFontFamily;

    // Light Mode Gradient: Cyan/Turquoise -> Soft Purple
    final lightModeColors = [const Color(0xFF5EE7DF), const Color(0xFFB490CA)];

    // Dark Mode Gradient: Deep Indigo -> Dark Midnight Blue
    final darkModeColors = [
      const Color(0xFF0F2027), // Deep Indigo
      const Color(0xFF203A43), // Dark Violet
      const Color(0xFF2C5364), // Midnight Blue
    ];

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow gradient to go behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _savePoem,
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.white70 : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.save,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode ? darkModeColors : lightModeColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              children: [
                // Title Input
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontFamily: fontName,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.titlePlaceholder,
                    hintStyle: TextStyle(
                      fontFamily: fontName,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 10),

                // Author Input
                TextField(
                  controller: _authorController,
                  style: TextStyle(
                    fontFamily: fontName,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.poetPlaceholder,
                    hintStyle: TextStyle(
                      fontFamily: fontName,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                const SizedBox(height: 10),

                // --- Media Toolbar ---
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image, size: 18),
                      label: Text(AppLocalizations.of(context)!.addPhoto),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.videocam, size: 18),
                      label: Text(AppLocalizations.of(context)!.addVideo),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),

                // --- Media Preview Area ---
                if (_selectedMedia.isNotEmpty)
                  Container(
                    height: 90,
                    margin: const EdgeInsets.only(top: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedMedia.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: _buildMediaThumbnail(
                                    _selectedMedia[index],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeMedia(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 10),

                // Content Input
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: null, // Unlimited lines
                    expands: true, // Fill available space
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      fontFamily: fontName,
                      fontSize: 18,
                      height: 1.6, // Better line height for reading
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.hintPoemBody,
                      hintStyle: TextStyle(
                        fontFamily: fontName,
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
