import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/providers.dart';
import '../helpers/localization_helper.dart';

import '../models/poem_model.dart';
import '../widgets/premium_poem_card.dart';

import 'package:poem_diary/l10n/app_localizations.dart';

class MoodResultsScreen extends StatelessWidget {
  final MoodCategory mood;

  const MoodResultsScreen({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    // Access the full archive filtered by mood
    final poemProvider = Provider.of<PoemProvider>(context);
    final moodPoems = poemProvider.getPoemsByMood(mood.code);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${mood.emoji} ${LocalizationHelper.getMoodName(context, mood.code)}',
          style: GoogleFonts.nunito(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: moodPoems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.msgNoMoodPoems,
                    style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: moodPoems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                    height: 500, // Fixed height or adjust based on content
                    child: PremiumPoemCard(
                      poem: moodPoems[index],
                      onTap: () {},
                      showUI: false,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
