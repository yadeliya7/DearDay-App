import 'dart:io';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import '../models/poem_model.dart';
import '../core/providers.dart';
import '../core/language_provider.dart';

import 'package:intl/intl.dart';

Future<void> showMoodEntryDialog(
  BuildContext context, {
  required DateTime date,
  required MoodProvider provider,
  String? currentMood,
  String? currentNote,
  List<String> currentMedia = const [],
  Map<String, dynamic> currentActivities = const {},
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return MoodEntrySheet(
        date: date,
        provider: provider,
        initialMood: currentMood,
        initialNote: currentNote,
        initialMedia: currentMedia,
        initialActivities: currentActivities,
      );
    },
  );
}

class MoodEntrySheet extends StatefulWidget {
  final DateTime date;
  final MoodProvider provider;
  final String? initialMood;
  final String? initialNote;
  final List<String> initialMedia;
  final Map<String, dynamic> initialActivities;

  const MoodEntrySheet({
    super.key,
    required this.date,
    required this.provider,
    this.initialMood,
    this.initialNote,
    required this.initialMedia,
    required this.initialActivities,
  });

  @override
  State<MoodEntrySheet> createState() => _MoodEntrySheetState();
}

class _MoodEntrySheetState extends State<MoodEntrySheet> {
  late ValueNotifier<MoodCategory?> moodNotifier;
  late TextEditingController noteController;
  late List<String> selectedMedia;
  late Map<String, dynamic> activities;

  @override
  void initState() {
    super.initState();
    MoodCategory? selectedMood;
    if (widget.initialMood != null) {
      try {
        selectedMood = widget.provider.moods.firstWhere(
          (m) => m.code == widget.initialMood,
        );
      } catch (e) {
        selectedMood = null;
      }
    }
    moodNotifier = ValueNotifier<MoodCategory?>(selectedMood);
    noteController = TextEditingController(text: widget.initialNote);
    selectedMedia = List.from(widget.initialMedia);
    activities = Map.from(widget.initialActivities);
  }

  @override
  void dispose() {
    moodNotifier.dispose();
    noteController.dispose();
    super.dispose();
  }

  // Helper to get/set activity
  void _setSingleActivity(String category, String value) {
    setState(() {
      if (activities[category] == value) {
        activities.remove(category); // Toggle off if same
      } else {
        activities[category] = value;
      }
    });
  }

  void _toggleMultiActivity(String category, String item) {
    setState(() {
      final List<String> list = List<String>.from(
        activities[category] as List? ?? [],
      );
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
      if (list.isEmpty) {
        activities.remove(category);
      } else {
        activities[category] = list;
      }
    });
  }

  // MISSING METHODS ADDED HERE
  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    if (image != null) {
      if (selectedMedia.length >= 5) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.maxMediaWarning)));
        return;
      }
      setState(() {
        selectedMedia.add(image.path);
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      selectedMedia.removeAt(index);
    });
  }

  String _getMoodName(BuildContext context, String code) {
    final loc = AppLocalizations.of(context)!;
    switch (code) {
      case 'happy':
        return loc.moodHappy;
      case 'sad':
        return loc.moodSad;
      case 'romantic':
        return loc.moodRomantic;
      case 'mystic':
        return loc.moodMystic;
      case 'tired':
        return loc.moodTired;
      case 'hopeful':
        return loc.moodHopeful;
      case 'peaceful':
        return loc.moodPeaceful;
      case 'nostalgic':
        return loc.moodNostalgic;
      case 'angry':
        return loc.moodAngry;
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // 1. Header
              _buildHeader(context, isDark),

              // 2. Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  children: [
                    // Mood Section
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.moodTitle,
                    ),
                    _buildMoodSelector(context, isDark),

                    const Divider(height: 32),

                    // Sleep (Single Select)
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.sectionSleep,
                    ),
                    Wrap(
                      spacing: 12,
                      children: [
                        _buildChoiceChip(
                          AppLocalizations.of(context)!.sleepGood,
                          LineIcons.sun,
                          'sleep',
                          'good',
                          activeColor: Colors.orangeAccent,
                        ),
                        _buildChoiceChip(
                          AppLocalizations.of(context)!.sleepMedium,
                          LineIcons.cloudWithMoon,
                          'sleep',
                          'medium',
                          activeColor: Colors.blueGrey,
                        ),
                        _buildChoiceChip(
                          AppLocalizations.of(context)!.sleepBad,
                          LineIcons.moon,
                          'sleep',
                          'bad',
                          activeColor: Colors.indigo,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Health (Multi)
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.sectionHealth,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          AppLocalizations.of(context)!.healthSport,
                          LineIcons.running,
                          'health',
                          'sport',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.healthHealthyFood,
                          LineIcons.carrot,
                          'health',
                          'healthy_food',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.healthFastFood,
                          LineIcons.hamburger,
                          'health',
                          'fast_food',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.healthWater,
                          LineIcons.tint,
                          'health',
                          'water',
                        ),
                        // New Items
                        _buildFilterChip(
                          AppLocalizations.of(context)!.healthWalking,
                          LineIcons.walking,
                          'health',
                          'walking',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.healthVitamins,
                          LineIcons.pills,
                          'health',
                          'vitamins',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.healthSleep,
                          LineIcons.bed,
                          'health',
                          'sleep_health',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.healthDoctor,
                          LineIcons.stethoscope,
                          'health',
                          'doctor',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Social (Multi)
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.sectionSocial,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          AppLocalizations.of(context)!.socialFriends,
                          LineIcons.userFriends,
                          'social',
                          'friends',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.socialFamily,
                          LineIcons.home,
                          'social',
                          'family',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.socialParty,
                          LineIcons.cocktail,
                          'social',
                          'party',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.socialPartner,
                          LineIcons.heartAlt,
                          'social',
                          'partner',
                        ),
                        // New Items
                        _buildFilterChip(
                          AppLocalizations.of(context)!.socialGuests,
                          Icons.people_outline,
                          'social',
                          'guests',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.socialColleagues,
                          LineIcons.briefcase,
                          'social',
                          'colleagues',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.socialTravel,
                          LineIcons.plane,
                          'social',
                          'travel',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.socialVolunteer,
                          LineIcons.heart,
                          'social',
                          'volunteer',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Hobbies (Multi)
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.sectionHobbies,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          AppLocalizations.of(context)!.hobbyGaming,
                          LineIcons.gamepad,
                          'hobbies',
                          'gaming',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.hobbyReading,
                          LineIcons.book,
                          'hobbies',
                          'reading',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.hobbyMovie,
                          LineIcons.video,
                          'hobbies',
                          'movie',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.hobbyArt,
                          LineIcons.palette,
                          'hobbies',
                          'art',
                        ),
                        // New Items
                        _buildFilterChip(
                          AppLocalizations.of(context)!.hobbyMusic,
                          LineIcons.music,
                          'hobbies',
                          'music',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.hobbyCoding,
                          LineIcons.code,
                          'hobbies',
                          'coding',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.hobbyPhotography,
                          LineIcons.camera,
                          'hobbies',
                          'photography',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.hobbyCrafts,
                          LineIcons.brush,
                          'hobbies',
                          'crafts',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Chores (Multi)
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.sectionChores,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          AppLocalizations.of(context)!.choreCleaning,
                          LineIcons.broom,
                          'chores',
                          'cleaning',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.choreShopping,
                          LineIcons.shoppingCart,
                          'chores',
                          'shopping',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.choreLaundry,
                          LineIcons.tShirt,
                          'chores',
                          'laundry',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.choreCooking,
                          LineIcons.utensils,
                          'chores',
                          'cooking',
                        ),
                        // New Items
                        _buildFilterChip(
                          AppLocalizations.of(context)!.choreIroning,
                          Icons.iron,
                          'chores',
                          'ironing',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.choreDishes,
                          Icons.kitchen,
                          'chores',
                          'dishes',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.choreRepair,
                          LineIcons.tools,
                          'chores',
                          'repair',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.chorePlants,
                          LineIcons.leaf,
                          'chores',
                          'plants',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Self Care (Multi)
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.sectionSelfCare,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          AppLocalizations.of(context)!.careManicure,
                          LineIcons.handHoldingHeart,
                          'selfcare',
                          'manicure',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.careSkincare,
                          LineIcons.spa,
                          'selfcare',
                          'skincare',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.careHair,
                          LineIcons.cut,
                          'selfcare',
                          'hair',
                        ),
                        // New Items
                        _buildFilterChip(
                          AppLocalizations.of(context)!.careMassage,
                          Icons.spa,
                          'selfcare',
                          'massage',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.careFaceMask,
                          Icons.face,
                          'selfcare',
                          'facemask',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.careBath,
                          LineIcons.bath,
                          'selfcare',
                          'bath',
                        ),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.careDetox,
                          Icons.phonelink_off,
                          'selfcare',
                          'digital_detox',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Weather (Single usually, but Multi ok)
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.sectionWeather,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChip(
                          AppLocalizations.of(context)!.weatherSunny,
                          LineIcons.sun,
                          'weather',
                          'sunny',
                          activeColor: Colors.amber,
                        ),
                        _buildChoiceChip(
                          AppLocalizations.of(context)!.weatherRainy,
                          LineIcons.cloudWithRain,
                          'weather',
                          'rainy',
                          activeColor: Colors.blue,
                        ),
                        _buildChoiceChip(
                          AppLocalizations.of(context)!.weatherCloudy,
                          LineIcons.cloud,
                          'weather',
                          'cloudy',
                          activeColor: Colors.grey,
                        ),
                        _buildChoiceChip(
                          AppLocalizations.of(context)!.weatherSnowy,
                          LineIcons.snowflake,
                          'weather',
                          'snowy',
                          activeColor: Colors.lightBlue,
                        ),
                        _buildChoiceChip(
                          AppLocalizations.of(context)!.weatherWindy,
                          LineIcons.wind,
                          'weather',
                          'windy',
                          activeColor: Colors.blueGrey,
                        ),
                        _buildChoiceChip(
                          AppLocalizations.of(context)!.weatherFoggy,
                          Icons
                              .foggy, // Ensure Icons.foggy exists or use alternative
                          'weather',
                          'foggy',
                          activeColor: Colors.blueGrey,
                        ),
                        _buildChoiceChip(
                          AppLocalizations.of(context)!.weatherHail,
                          Icons.ac_unit,
                          'weather',
                          'hail',
                          activeColor: Colors.lightBlueAccent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // HEADER: Daily Goals
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.dailyGoals,
                    ),
                    _buildHabitTile(
                      AppLocalizations.of(context)!.goalNoSmoking,
                      LineIcons.smokingBan,
                      'no_smoking',
                    ),
                    _buildHabitTile(
                      AppLocalizations.of(context)!.goalSocialDetox,
                      LineIcons.mobilePhone,
                      'social_media_detox',
                    ),
                    _buildHabitTile(
                      AppLocalizations.of(context)!.goalReadBook,
                      LineIcons.book,
                      'read_book',
                    ),
                    _buildHabitTile(
                      AppLocalizations.of(context)!.goalDrinkWater,
                      LineIcons.tint,
                      'drink_water',
                    ),
                    _buildHabitTile(
                      AppLocalizations.of(context)!.goalMeditation,
                      LineIcons.spa,
                      'meditation',
                    ),
                    // New Goal Items
                    _buildHabitTile(
                      AppLocalizations.of(context)!.goalEarlyRise,
                      LineIcons.bell,
                      'early_rise',
                    ),
                    _buildHabitTile(
                      AppLocalizations.of(context)!.goalNoSugar,
                      Icons.no_food,
                      'no_sugar',
                    ),
                    _buildHabitTile(
                      AppLocalizations.of(context)!.goalJournaling,
                      LineIcons.bookOpen,
                      'journaling',
                    ),
                    _buildHabitTile(
                      AppLocalizations.of(context)!.goalSteps,
                      LineIcons.shoePrints,
                      '10k_steps',
                    ),

                    const Divider(height: 32),

                    // Note & Media
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.sectionNotesMedia,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: noteController,
                        maxLines: 4,
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.notesHint,
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white30 : Colors.black38,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMediaSection(context, isDark),

                    const SizedBox(height: 80), // Space for fab/bottom area
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            DateFormat(
              'd MMMM yyyy',
              Provider.of<LanguageProvider>(context).currentLanguage,
            ).format(widget.date),
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () {
              if (moodNotifier.value == null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(loc.selectMoodWarning)));
                return;
              }
              widget.provider.saveDailyEntry(
                widget.date,
                moodNotifier.value!.code,
                noteController.text,
                selectedMedia,
                activities,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.saveSuccess),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              loc.save.toUpperCase(),
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.provider.moods.where((m) => m.code.isNotEmpty).map((
          mood,
        ) {
          final isSelected = moodNotifier.value?.code == mood.code;
          return GestureDetector(
            onTap: () {
              setState(() {
                moodNotifier.value = mood;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ), // Tighter margin
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getMoodColor(mood.code)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    mood.emoji,
                    style: TextStyle(fontSize: isSelected ? 30 : 22),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getMoodName(context, mood.code),
                  style: GoogleFonts.nunito(
                    fontSize: 9,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    IconData icon,
    String category,
    String value, {
    Color? activeColor,
  }) {
    final isSelected = activities[category] == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorToUse = activeColor ?? Theme.of(context).primaryColor;

    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black87),
      ),
      selected: isSelected,
      onSelected: (_) => _setSingleActivity(category, value),
      backgroundColor: isDark ? Colors.black26 : Colors.white,
      selectedColor: colorToUse,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    String category,
    String item,
  ) {
    final List list = (activities[category] as List?) ?? [];
    final isSelected = list.contains(item);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return FilterChip(
      showCheckmark: false,
      label: Text(label),
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black87),
      ),
      selected: isSelected,
      onSelected: (_) => _toggleMultiActivity(category, item),
      backgroundColor: isDark ? Colors.black26 : Colors.white,
      selectedColor: primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // Toggle boolean habit
  void _toggleHabit(String key) {
    setState(() {
      final current = activities[key] == true;
      if (current) {
        activities.remove(key);
      } else {
        activities[key] = true;
      }
    });
  }

  Widget _buildHabitTile(String label, IconData icon, String key) {
    final isDone = activities[key] == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate Streak
    // Note: getStreakFor counts PAST consecutive days.
    final streak = widget.provider.getStreakFor(key, widget.date);

    // UI logic:
    // If done today -> Streak includes today (technically +1 visually maybe?)
    // But usually "Streak" is completed days.
    // If I did it today, let's show "Streak: X Gün" where X includes today if we want, OR just show existing streak.
    // User request: "If streak > 0: Fire X Days. If 0: Start Streak"
    // If I check it now, does it become 1?
    // Let's assume we display (Past Streak + IsDoneToday ? 1 : 0).
    final int displayStreak = streak + (isDone ? 1 : 0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _toggleHabit(key),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.green.withValues(alpha: 0.15)
                    : (isDark ? Colors.white10 : Colors.grey[100]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isDone
                    ? Colors.green
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (displayStreak > 0)
                  Text(
                    '🔥 ${AppLocalizations.of(context)!.dailyStreak(displayStreak)}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  )
                else
                  Text(
                    AppLocalizations.of(context)!.startStreak,
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDone ? Colors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone
                      ? Colors.green
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedMedia.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedMedia.length,
              itemBuilder: (context, index) {
                final path = selectedMedia[index];
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: buildMediaThumbnail(path, width: 90, height: 90),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeMedia(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickMedia,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.grey[300]!,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.btnAddPhoto,
                  style: GoogleFonts.nunito(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Reusing helper methods from before
Widget buildMediaThumbnail(
  String path, {
  double width = 100,
  double height = 100,
}) {
  final ext = path.split('.').last.toLowerCase();

  // Video
  if (['mp4', 'mov', 'avi'].contains(ext)) {
    return Container(
      width: width,
      height: height,
      color: Colors.black87,
      child: Center(
        child: Icon(
          Icons.play_circle_fill,
          color: Colors.white,
          size: width * 0.4,
        ),
      ),
    );
  }

  // PDF
  if (['pdf'].contains(ext)) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red, size: width * 0.4),
        ],
      ),
    );
  }

  // Audio
  if (['mp3', 'm4a', 'wav'].contains(ext)) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.mic, color: Colors.blue, size: width * 0.4),
      ),
    );
  }

  // Image
  if (['jpg', 'jpeg', 'png', 'heic', 'webp'].contains(ext)) {
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: width * 0.4,
          ),
        );
      },
    );
  }

  return Container(
    width: width,
    height: height,
    color: Colors.grey[300],
    child: Icon(Icons.insert_drive_file, color: Colors.grey, size: width * 0.4),
  );
}

Color _getMoodColor(String moodCode) {
  switch (moodCode) {
    case 'sad':
      return Colors.blue[300]!;
    case 'happy':
      return Colors.yellow[300]!;
    case 'romantic':
      return Colors.pink[300]!;
    case 'mystic':
      return Colors.purple[300]!;
    case 'tired':
      return Colors.grey[400]!;
    case 'hopeful':
      return Colors.green[300]!;
    case 'peaceful':
      return Colors.cyan[300]!;
    case 'nostalgic':
      return Colors.orange[300]!;
    case 'angry':
      return Colors.redAccent;
    default:
      return Colors.blueGrey[200]!;
  }
}
