import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../core/providers.dart';

import '../widgets/premium_poem_card.dart';

import 'compose_poem_screen.dart';

import 'package:poem_diary/l10n/app_localizations.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // State for Inspiration Tab
  String? _displayPoemId;
  String _lastMoodCode = ''; // Track last mood to detect changes
  Key _poemKey = UniqueKey(); // To force rebuild/animation on refresh

  @override
  void initState() {
    super.initState();
    // Initial load will be handled in build via microtask if needed
    // or we can wait for dependencies.
  }

  void _loadPoemForMood(String moodCode) {
    final provider = Provider.of<PoemProvider>(context, listen: false);
    if (provider.poems.isNotEmpty) {
      final poem = provider.getPoemForMood(moodCode);
      if (mounted) {
        setState(() {
          _displayPoemId = poem.id;
          _poemKey = UniqueKey();
          _lastMoodCode = moodCode; // Update last mood
        });
      }
    }
  }

  void _loadCompletelyRandomPoem() {
    final provider = Provider.of<PoemProvider>(context, listen: false);
    if (provider.poems.isNotEmpty) {
      final poem = provider.getRandomPoem();
      if (mounted) {
        setState(() {
          _displayPoemId = poem.id;
          _poemKey = UniqueKey();
          // Reset mood code so we know it's a random selection (or use a special flag)
          // We can use a special code like 'random_refresh' to show a generic title
          _lastMoodCode = 'random_refresh';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final poemProvider = Provider.of<PoemProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);

    // Check for mood change to reload poem
    final todayMood =
        moodProvider.getEntryForDate(DateTime.now())?.moodCode ?? '';

    // If mood changed or no poem loaded, load new based on mood
    // EXCEPTION: If user explicitly requested a random poem (via button), don't override immediately on build
    // We can check if _lastMoodCode is 'random_refresh' to preserve the random selection until mood changes again?
    // OR simpler: just update if mood ACTUALLY changed from what we tracked.

    if (_lastMoodCode != todayMood && _lastMoodCode != 'random_refresh') {
      // Only auto-update if we are NOT in random refresh mode OR if the mood really changed to something new
      // Wait, if _lastMoodCode is 'random_refresh', we want to keep it UNLESS todayMood changes?
      // But todayMood is likely stable until user changes it.
      // So this block won't run if we set _lastMoodCode to 'random_refresh' and todayMood is still 'happy'.
      // CORRECT.

      if (_lastMoodCode != todayMood) {
        // If we were random, but mood changed?
        // Actually if we sort of 'detached' from mood, maybe we should stay detached?
        // BUT usually if user changes mood in home, they expect library to update.
        // So if real mood != stored mood, we update.
        // But if we stored 'random_refresh', distinct from real mood.
        // Let's just say: auto-load only on Init or Mood Change.

        // Initial load
        if (_displayPoemId == null) {
          Future.microtask(() => _loadPoemForMood(todayMood));
        } else if (_lastMoodCode != 'random_refresh' &&
            _lastMoodCode != todayMood) {
          // Real mood change detected
          _lastMoodCode = todayMood;
          Future.microtask(() => _loadPoemForMood(todayMood));
        }
      }
    } else if (_displayPoemId == null) {
      // Initial load fallback
      Future.microtask(() => _loadPoemForMood(todayMood));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: null,
          automaticallyImplyLeading: false,
          title: Text(
            AppLocalizations.of(context)!.libraryTitle,
            style: GoogleFonts.nunito(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: isDarkMode ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: isDarkMode ? Colors.white : Colors.black,
            labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                icon: const Icon(LineIcons.feather),
                text: AppLocalizations.of(context)!.tabInspiration,
              ),
              Tab(
                icon: const Icon(LineIcons.book),
                text: AppLocalizations.of(context)!.tabNotebook,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: İlham (Inspiration/Read)
            _buildInspirationTab(context, isDarkMode, poemProvider, todayMood),

            // Tab 2: Defterim (Notebook/Write)
            const _UserPoemsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInspirationTab(
    BuildContext context,
    bool isDark,
    PoemProvider provider,
    String currentMood,
  ) {
    if (_displayPoemId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Look up the poem dynamically
    final displayPoem = provider.getPoemById(_displayPoemId!);

    // Get Mood Details for UI
    String sectionTitle;
    if (_lastMoodCode == 'random_refresh') {
      sectionTitle = "Günün Şiiri"; // Generic title for random refresh
    } else {
      final moodDetails = provider.getDetailsForMood(currentMood);
      sectionTitle = moodDetails['message']!;
    }

    if (displayPoem == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            sectionTitle,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Center(
              child: SizedBox(
                height: 550,
                width: double.infinity,
                child: PremiumPoemCard(
                  key: _poemKey,
                  poem: displayPoem,
                  onTap: () {},
                  showUI: true,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: TextButton.icon(
            onPressed: () => _loadCompletelyRandomPoem(),
            icon: const Icon(Icons.refresh),
            label: Text(
              AppLocalizations.of(context)!.btnNewPoem,
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _UserPoemsTab extends StatelessWidget {
  const _UserPoemsTab();

  @override
  Widget build(BuildContext context) {
    final poemProvider = Provider.of<PoemProvider>(context);
    final userPoems = poemProvider.userPoems;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fab = Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ComposePoemScreen()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        child: const Icon(LineIcons.pen, color: Colors.white),
      ),
    );

    if (userPoems.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: fab,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LineIcons.pen,
                size: 64,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.msgNoPoemYet,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.msgStartWriting,
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: fab,
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          100,
        ), // Bottom padding for content
        itemCount: userPoems.length,
        itemBuilder: (context, index) {
          final poem = userPoems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              surfaceTintColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  poem.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      poem.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${poem.createdAt.day}.${poem.createdAt.month}.${poem.createdAt.year}",
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: isDark
                                ? const Color(0xFF2C2C2C)
                                : Colors.white,
                            title: Text(
                              AppLocalizations.of(context)!.titleDeletePoem,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.msgDeleteConfirmation,
                              style: GoogleFonts.nunito(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppLocalizations.of(context)!.btnCancel,
                                  style: GoogleFonts.nunito(color: Colors.grey),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  poemProvider.deletePoem(poem.id);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.btnDelete,
                                  style: GoogleFonts.nunito(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () {
                        // Open detailed view or edit view (using same card logic for now)
                        showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(20),
                            child: SizedBox(
                              height: 600,
                              // Use Consumer to get live updates for the specific poem
                              child: Consumer<PoemProvider>(
                                builder: (context, provider, child) {
                                  // Always look up the latest version of the poem
                                  final latestPoem =
                                      provider.getPoemById(poem.id) ?? poem;
                                  return PremiumPoemCard(
                                    poem: latestPoem,
                                    onTap: () {},
                                    showUI: true,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
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
}
