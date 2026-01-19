import 'package:flutter/material.dart';
import 'package:poem_diary/l10n/app_localizations.dart';

class LocalizationHelper {
  static String getActivityName(
    BuildContext context,
    String activityKey, [
    dynamic value,
  ]) {
    final loc = AppLocalizations.of(context)!;

    switch (activityKey) {
      // --- SLEEP ---
      case 'sleep':
        if (value == 'good') return loc.sleepGood;
        if (value == 'medium') return loc.sleepMedium;
        if (value == 'bad') return loc.sleepBad;
        return loc.sectionSleep; // Fallback or title

      // --- WEATHER ---
      case 'weather':
        if (value == 'sunny') return loc.weatherSunny;
        if (value == 'rainy') return loc.weatherRainy;
        if (value == 'cloudy') return loc.weatherCloudy;
        if (value == 'snowy') return loc.weatherSnowy;
        if (value == 'windy') return loc.weatherWindy;
        if (value == 'foggy') return loc.weatherFoggy;
        if (value == 'hail') return loc.weatherHail;
        return loc.sectionWeather;

      case 'sunny':
        return loc.weatherSunny;
      case 'rainy':
        return loc.weatherRainy;
      case 'cloudy':
        return loc.weatherCloudy;
      case 'snowy':
        return loc.weatherSnowy;
      case 'windy':
        return loc.weatherWindy;
      case 'foggy':
        return loc.weatherFoggy;
      case 'hail':
        return loc.weatherHail;

      // --- GOALS / HABITS ---
      case 'no_smoking':
        return loc.goalNoSmoking;
      case 'social_media_detox':
        return loc.goalSocialDetox;
      case 'read_book':
        return loc.goalReadBook;
      case 'drink_water':
        return loc.goalDrinkWater;
      case 'meditation':
        return loc.goalMeditation;
      case 'early_rise':
        return loc.goalEarlyRise;
      case 'no_sugar':
        return loc.goalNoSugar;
      case 'journaling':
        return loc.goalJournaling;
      case '10k_steps':
        return loc.goalSteps;

      // --- HEALTH ---
      case 'sport':
        return loc.healthSport;
      case 'healthy_food':
        return loc.healthHealthyFood;
      case 'fast_food':
        return loc.healthFastFood;
      case 'water':
        return loc.healthWater;
      case 'walking':
        return loc.healthWalking;
      case 'vitamins':
        return loc.healthVitamins;
      case 'sleep_health':
        return loc.healthSleep;
      case 'doctor':
        return loc.healthDoctor;

      // --- SOCIAL ---
      case 'friends':
        return loc.socialFriends;
      case 'family':
        return loc.socialFamily;
      case 'party':
        return loc.socialParty;
      case 'partner':
        return loc.socialPartner;
      case 'guests':
        return loc.socialGuests;
      case 'colleagues':
        return loc.socialColleagues;
      case 'travel':
        return loc.socialTravel;
      case 'volunteer':
        return loc.socialVolunteer;

      // --- HOBBIES ---
      case 'gaming':
        return loc.hobbyGaming;
      case 'reading':
        return loc.hobbyReading;
      case 'movie':
        return loc.hobbyMovie;
      case 'art':
        return loc.hobbyArt;
      case 'music':
        return loc.hobbyMusic;
      case 'coding':
        return loc.hobbyCoding;
      case 'photography':
        return loc.hobbyPhotography;
      case 'crafts':
        return loc.hobbyCrafts;

      // --- CHORES ---
      case 'cleaning':
        return loc.choreCleaning;
      case 'shopping':
        return loc.choreShopping;
      case 'laundry':
        return loc.choreLaundry;
      case 'cooking':
        return loc.choreCooking;
      case 'ironing':
        return loc.choreIroning;
      case 'dishes':
        return loc.choreDishes;
      case 'repair':
        return loc.choreRepair;
      case 'plants':
        return loc.chorePlants;

      // --- SELF CARE ---
      case 'manicure':
        return loc.careManicure;
      case 'skincare':
        return loc.careSkincare;
      case 'hair':
        return loc.careHair;
      case 'massage':
        return loc.careMassage;
      case 'facemask':
        return loc.careFaceMask;
      case 'bath':
        return loc.careBath;
      case 'digital_detox':
        return loc.careDetox;

      default:
        return "";
    }
  }

  // Story generation methods removed - moved to StoryGenerator with JSON service

  static String getMoodName(BuildContext context, String moodCode) {
    final loc = AppLocalizations.of(context)!;
    switch (moodCode) {
      case 'happy':
        return loc.moodHappy;
      case 'sad':
        return loc.moodSad;
      case 'romantic':
        return loc.moodRomantic;
      case 'angry':
        return loc.moodAngry;
      case 'tired':
        return loc.moodTired;
      case 'hopeful':
        return loc.moodHopeful;
      case 'peaceful':
        return loc.moodPeaceful;
      case 'nostalgic':
        return loc.moodNostalgic;
      case 'mystic':
        return loc.moodMystic;
      default:
        return loc.moodUnknown;
    }
  }

  static String getMoodDescription(BuildContext context, String moodCode) {
    final loc = AppLocalizations.of(context)!;
    switch (moodCode) {
      case 'happy':
        return loc.descHappy;
      case 'sad':
        return loc.descSad;
      case 'romantic':
        return loc.descRomantic;
      case 'angry':
        return loc.descAngry;
      case 'tired':
        return loc.descTired;
      case 'hopeful':
        return loc.descHopeful;
      case 'peaceful':
        return loc.descPeaceful;
      case 'nostalgic':
        return loc.descNostalgic;
      case 'mystic':
        return loc
            .descAll; // Use generic or add specific if needed, defaulting to generic-ish
      default:
        return loc.descAll;
    }
  }
}
