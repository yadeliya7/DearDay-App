import 'package:flutter/material.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/providers.dart';
import '../widgets/premium_poem_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.favorites,
          style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<PoemProvider>(
        builder: (context, poemProvider, child) {
          final favoritePoems = poemProvider.favoritePoems;

          if (favoritePoems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.emptyFavTitle,
                    style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 100,
              bottom: 20,
            ), // Top padding for AppBar
            itemCount: favoritePoems.length,
            itemBuilder: (context, index) {
              final poem = favoritePoems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 500, // Fixed height for the card in list view
                  child: PremiumPoemCard(
                    poem: poem,
                    onTap: () {
                      // Optional: Navigate to detail view or expand
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
