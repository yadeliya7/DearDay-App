// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get library => 'My Library';

  @override
  String get settings => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get favorites => 'Favorites';

  @override
  String get myPoems => 'My Poems';

  @override
  String get poemOfDay => 'Poem of the Day';

  @override
  String get moodTitle => 'How do you feel today?';

  @override
  String get save => 'SAVE';

  @override
  String get poetPlaceholder => 'Poet / Pseudonym';

  @override
  String get titlePlaceholder => 'Poem Title...';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get addVideo => 'Add Video';

  @override
  String get futureWarning => 'You haven\'t lived the future yet!';

  @override
  String get writePoem => 'Write Poem';

  @override
  String get search => 'Search';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'English / Turkish';

  @override
  String get home => 'Home';

  @override
  String get discover => 'Discover';

  @override
  String get calendar => 'Calendar';

  @override
  String get checkInPrompt => 'How are you today?';

  @override
  String get greetingMorning => 'Good Morning ☀️';

  @override
  String get greetingDay => 'Good Day 🌤️';

  @override
  String get greetingEvening => 'Good Evening 🌙';

  @override
  String get greetingNight => 'Good Night 🌙';

  @override
  String get dailyQuote => 'May today be poetic.';

  @override
  String get discoverTitle => 'Discover by Mood';

  @override
  String get discoverSubtitle => 'Pick your mood, find your poem...';

  @override
  String get emptyFeed => 'No poems yet...';

  @override
  String get emptyFeedSubtitle => 'Tap (+) above to add your first poem.';

  @override
  String get menu => 'Menu';

  @override
  String get changeTheme => 'Change Theme';

  @override
  String get fontStyle => 'Font Style';

  @override
  String get about => 'About';

  @override
  String get calendarTitle => 'Mood Calendar';

  @override
  String get tabHome => 'Home';

  @override
  String get tabLibrary => 'Journal';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get emptyPoemsTitle => 'You haven\'t written a poem yet';

  @override
  String get emptyPoemsSub => 'Pour your heart out...';

  @override
  String get emptyFavTitle => 'No favorite poems yet';

  @override
  String get emptyFavSub => 'You can add poems you like here';

  @override
  String get dialogDeleteTitle => 'Delete?';

  @override
  String get dialogDeleteMsg => 'Are you sure you want to delete this?';

  @override
  String get btnYes => 'Yes';

  @override
  String get btnNo => 'No';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnDelete => 'Delete';

  @override
  String get msgSaved => 'Saved successfully';

  @override
  String introHighEnergy(String weather) {
    return 'My energy was great today! $weather';
  }

  @override
  String introLowEnergy(String weather) {
    return 'It was a tiring day. $weather';
  }

  @override
  String introNeutral(String weather) {
    return 'I had a calm day. $weather';
  }

  @override
  String healthAction(String activities) {
    return 'I took care of my body: $activities.';
  }

  @override
  String socialAction(String activities) {
    return 'I spent time with loved ones: $activities.';
  }

  @override
  String hobbyAction(String activities) {
    return 'I improved myself and had fun: $activities.';
  }

  @override
  String choreAction(String activities) {
    return 'I handled my responsibilities: $activities.';
  }

  @override
  String selfCareAction(String activities) {
    return 'I pampered myself: $activities.';
  }

  @override
  String get streakBonus => 'I am amazing, I reached my goals! 🚀';

  @override
  String streakSpecific(int count, String activity) {
    return 'Successfully continued my $activity goal for day $count! 🔥';
  }

  @override
  String dayNote(Object note) {
    return 'Note of the day: $note';
  }

  @override
  String get journal_sport =>
      'I energized my body and worked up a sweat with sports today.';

  @override
  String get journal_healthy_food =>
      'I took care of my body and ate healthy food.';

  @override
  String get journal_fast_food =>
      'I treated myself to a fast food cheat meal today.';

  @override
  String get journal_water =>
      'I refreshed my body by drinking plenty of water.';

  @override
  String get journal_walking => 'I cleared my mind with a nice walk.';

  @override
  String get journal_vitamins =>
      'I supported my immunity by taking my vitamins.';

  @override
  String get journal_sleep_health =>
      'I saved energy by getting extra sleep today.';

  @override
  String get journal_doctor =>
      'I didn\'t neglect my health and went for a doctor\'s check-up.';

  @override
  String get journal_friends => 'I met up with friends and had a great time.';

  @override
  String get journal_family =>
      'I enjoyed the peace of spending time with my family.';

  @override
  String get journal_party => 'I joined a party and enjoyed the fun!';

  @override
  String get journal_partner =>
      'I shared romantic and special moments with my partner.';

  @override
  String get journal_guests =>
      'I enjoyed the pleasure of hosting guests in my home.';

  @override
  String get journal_colleagues =>
      'I spent productive time with my colleagues.';

  @override
  String get journal_travel =>
      'I hit the road and felt the freedom of traveling.';

  @override
  String get journal_volunteer =>
      'I nourished my soul by participating in volunteer work.';

  @override
  String get journal_gaming =>
      'I relieved the day\'s stress by diving into the world of games.';

  @override
  String get journal_reading => 'I got lost among the pages of my book.';

  @override
  String get journal_movie => 'I enjoyed watching a nice movie/series.';

  @override
  String get journal_art =>
      'I expressed my inner creativity by engaging in art.';

  @override
  String get journal_music =>
      'I got carried away by the rhythm of music and rested my soul.';

  @override
  String get journal_coding =>
      'I experienced the pleasure of building new things by coding.';

  @override
  String get journal_photography =>
      'I captured life through my lens and took photos.';

  @override
  String get journal_crafts =>
      'I spent a productive day dealing with handicrafts.';

  @override
  String get journal_cleaning =>
      'I cleaned the house and created a spacious living space.';

  @override
  String get journal_shopping =>
      'I went shopping and completed my deficiencies.';

  @override
  String get journal_laundry => 'I washed the laundry and provided order.';

  @override
  String get journal_cooking =>
      'I went into the kitchen and prepared delicious meals.';

  @override
  String get journal_ironing => 'I ironed my clothes and made them look sharp.';

  @override
  String get journal_dishes =>
      'I handled the dishes and left the kitchen spotless.';

  @override
  String get journal_repair => 'I handled small repair jobs at home.';

  @override
  String get journal_plants =>
      'I took care of my plants and gave them life water.';

  @override
  String get journal_manicure =>
      'I applied care to my hands by having a manicure.';

  @override
  String get journal_skincare =>
      'I pampered myself by applying my skincare routine.';

  @override
  String get journal_hair => 'I cared for my hair and felt renewed.';

  @override
  String get journal_massage => 'I relaxed all my muscles with a massage.';

  @override
  String get journal_facemask =>
      'I revitalized my skin by applying a face mask.';

  @override
  String get journal_bath => 'I threw off all my tiredness with a hot bath.';

  @override
  String get journal_digital_detox =>
      'I moved away from technology and stayed alone with myself.';

  @override
  String get journal_no_smoking =>
      'I did a favor to my lungs by not smoking today.';

  @override
  String get journal_social_media_detox =>
      'I enjoyed the moment by staying away from social media.';

  @override
  String get journal_read_book =>
      'I successfully completed my daily book reading goal.';

  @override
  String get journal_drink_water =>
      'I met my water drinking goal, hydration complete!';

  @override
  String get journal_meditation => 'I focused on my inner peace by meditating.';

  @override
  String get journal_early_rise =>
      'I caught the day by waking up before the sun.';

  @override
  String get journal_no_sugar => 'I preserved my will by eating sugar-free.';

  @override
  String get journal_journaling =>
      'I poured my feelings onto paper by writing in my journal.';

  @override
  String get journal_10k_steps =>
      'I passed 10 thousand steps, I reached the goal!';

  @override
  String get mood_sentence_huzun =>
      'I felt a sadness that was hard to describe.';

  @override
  String get mood_sentence_nese => 'I was bubbling with joy and energy!';

  @override
  String get mood_sentence_nostaljik =>
      'Memories came flooding back; I felt nostalgic.';

  @override
  String get mood_sentence_sinirli => 'I was feeling tense and a bit on edge.';

  @override
  String get mood_sentence_umut =>
      'A beautiful hope for the future blossomed within me.';

  @override
  String get mood_sentence_huzur =>
      'I was in a calm, serene, and peaceful state of mind.';

  @override
  String get mood_sentence_romantik =>
      'Romantic winds were blowing in my heart.';

  @override
  String get mood_sentence_yorgun =>
      'I felt a bit tired and worn out throughout the day.';

  @override
  String get sleep_good => 'Also, I had a great sleep.';

  @override
  String get sleep_bad => 'However, I didn\'t sleep very well.';

  @override
  String weather_context(Object weather) {
    return 'The weather was $weather.';
  }

  @override
  String get weather_sentence_sunny =>
      'The warm energy of the sun accompanied my day.';

  @override
  String get weather_sentence_cloudy =>
      'The sky was cloudy; a calm and serene atmosphere prevailed.';

  @override
  String get weather_sentence_rainy =>
      'The sound of rain rested my soul as drops washed the city.';

  @override
  String get weather_sentence_snowy =>
      'Falling snow covered everything like a white fairytale.';

  @override
  String get msgError => 'An error occurred';

  @override
  String get msgFieldRequired => 'Please fill all fields';

  @override
  String get msgFutureDate => 'You haven\'t lived the future yet!';

  @override
  String get moodHappy => 'Joy';

  @override
  String get moodSad => 'Sadness';

  @override
  String get moodRomantic => 'Romantic';

  @override
  String get moodAngry => 'Angry';

  @override
  String get moodTired => 'Tired';

  @override
  String get moodHopeful => 'Hopeful';

  @override
  String get moodPeaceful => 'Peaceful';

  @override
  String get moodNostalgic => 'Nostalgic';

  @override
  String get moodMystic => 'Mystic';

  @override
  String get hintSearch => 'Search poems or poets...';

  @override
  String get hintNote => 'Add a note for today...';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get goodNight => 'Good Night';

  @override
  String get dialogEntryTitle => 'Daily Entry';

  @override
  String get labelMood => 'Mood';

  @override
  String get hintWriteNote => 'Write a note for today...';

  @override
  String get labelAttachedFiles => 'Attached Files';

  @override
  String get btnSave => 'Save';

  @override
  String get msgEntrySaved => 'Diary entry saved';

  @override
  String get shareText => 'Share Text';

  @override
  String get shareImage => 'Share as Image';

  @override
  String get shareImageSubtitle => 'Auto-expanding design for long poems';

  @override
  String get designBgTitle => 'Select Background';

  @override
  String get tabGallery => 'Gallery';

  @override
  String get tabColors => 'Colors';

  @override
  String get settingFontTitle => 'Font Style';

  @override
  String get hintPoemBody => 'Pour your heart out...';

  @override
  String get moodUnknown => 'Unknown';

  @override
  String get noNote => 'No note added for today.';

  @override
  String get titleSelectMood => 'Select Mood';

  @override
  String get btnSeePoems => 'See Poems';

  @override
  String get msgNoMoodPoems => 'No poems for this mood yet.';

  @override
  String get appTitle => 'DearDay';

  @override
  String get msgNoPoemSelected => 'No poem selected yet.';

  @override
  String get createdWith => 'Created with';

  @override
  String get dailyGoals => 'Daily Goals';

  @override
  String get homeTitle => 'DearDay';

  @override
  String get today => 'Today';

  @override
  String get pastRecords => 'Past Records';

  @override
  String streak(int days) {
    return 'Streak: $days days';
  }

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get noActivityDetails => 'No activity details yet';

  @override
  String get tapToAddEntry => 'Tap to add daily summary';

  @override
  String get activityGoodSleep => 'Good Sleep';

  @override
  String get activityMediumSleep => 'Medium Sleep';

  @override
  String get activityBadSleep => 'Bad Sleep';

  @override
  String get activitySunny => 'Sunny';

  @override
  String get activityRainy => 'Rainy';

  @override
  String get activityCloudy => 'Cloudy';

  @override
  String get activitySnowy => 'Snowy';

  @override
  String get activityNoSmoking => 'No Smoking';

  @override
  String get activitySport => 'Sport';

  @override
  String get activityWater => 'Water';

  @override
  String get activityBook => 'Reading';

  @override
  String get activityMeditation => 'Meditation';

  @override
  String get activityDetox => 'Detox';

  @override
  String get shareApp => 'Share with Friends';

  @override
  String get shareMessage =>
      'Hi! I discovered this great app to track my mood and habits. You should try it too! 🚀 DearDay\n\n';

  @override
  String shareError(String error) {
    return 'Error: $error. Please restart the app.';
  }

  @override
  String get goPremium => 'Go Premium';

  @override
  String get premiumDesc => 'Unlimited access and ad-free experience.';

  @override
  String get sectionAppearance => 'APPEARANCE';

  @override
  String get sectionOther => 'OTHER';

  @override
  String get dayDetail => 'Day Detail';

  @override
  String get btnAddPhoto => 'Add Photo';

  @override
  String get goalDuration => 'Goal Duration';

  @override
  String daysSuffix(int days) {
    return '$days Days';
  }

  @override
  String get guestUser => 'Guest User';

  @override
  String get defaultUserTitle => 'Poetry Enthusiast';

  @override
  String get descSad => 'Feels like a rainy day';

  @override
  String get descHappy => 'Like a sunny morning';

  @override
  String get descNostalgic => 'Touch of memories';

  @override
  String get descAngry => 'Angry and tense';

  @override
  String get descHopeful => 'A fresh start';

  @override
  String get descPeaceful => 'Like flowing water';

  @override
  String get descRomantic => 'Purest form of love';

  @override
  String get descTired => 'Need some rest';

  @override
  String get descAll => 'Whole archive';

  @override
  String get moodAll => 'All Poems';

  @override
  String get sectionSleep => 'Sleep';

  @override
  String get sleepGood => 'Good';

  @override
  String get sleepMedium => 'Medium';

  @override
  String get sleepBad => 'Bad';

  @override
  String get sectionHealth => 'Health';

  @override
  String get healthSport => 'Sport';

  @override
  String get healthHealthyFood => 'Healthy Food';

  @override
  String get healthFastFood => 'Fast Food';

  @override
  String get healthWater => 'Water';

  @override
  String get healthWalking => 'Walking';

  @override
  String get healthVitamins => 'Vitamins';

  @override
  String get healthSleep => 'Sleep';

  @override
  String get healthDoctor => 'Doctor';

  @override
  String get libraryTitle => 'Library';

  @override
  String get tabInspiration => 'Inspiration';

  @override
  String get tabNotebook => 'Notebook';

  @override
  String get msgNoPoemYet => 'You haven\'t written a poem yet...';

  @override
  String get msgStartWriting => 'Come on, pick up the pen!';

  @override
  String get btnNewPoem => 'Get New Poem';

  @override
  String get titleDeletePoem => 'Delete Poem';

  @override
  String get msgDeleteConfirmation =>
      'Are you sure you want to delete this poem? This action cannot be undone.';

  @override
  String get analysisTitle => 'Analysis';

  @override
  String get analysisMoodTrend => 'Mood Trend (Last 7 Days)';

  @override
  String get analysisSleepQuality => 'Sleep Quality';

  @override
  String get analysisTopActivities => 'Top Activities';

  @override
  String mostFrequentActivities(int year) {
    return 'Top Activities ($year)';
  }

  @override
  String get analysisAllActivities => 'All Activities';

  @override
  String get analysisNoData => 'Not enough data';

  @override
  String get analysisNoSleepData => 'No sleep data';

  @override
  String get analysisNoActivityData => 'No activity data';

  @override
  String get analysisNoActivities => 'No activities yet';

  @override
  String get btnSeeAll => 'See All';

  @override
  String timesCount(int count) {
    return '$count times';
  }

  @override
  String get legendSleepGood => 'Good';

  @override
  String get legendSleepMedium => 'Medium';

  @override
  String get legendSleepBad => 'Bad';

  @override
  String dailyStreak(int count) {
    return '$count Day Streak';
  }

  @override
  String get startStreak => 'Start Streak';

  @override
  String streakCompleted(int days, String goal) {
    return '\nYou completed $days days streak in $goal!';
  }

  @override
  String streakGoalCompleted(int days) {
    return '\nYou completed $days days streak!';
  }

  @override
  String get sectionSocial => 'Social';

  @override
  String get socialFriends => 'Friends';

  @override
  String get socialFamily => 'Family';

  @override
  String get socialParty => 'Party';

  @override
  String get socialPartner => 'Partner';

  @override
  String get socialGuests => 'Guests';

  @override
  String get socialColleagues => 'Colleagues';

  @override
  String get socialTravel => 'Travel';

  @override
  String get socialVolunteer => 'Volunteer';

  @override
  String get sectionHobbies => 'Hobbies';

  @override
  String get hobbyGaming => 'Gaming';

  @override
  String get hobbyReading => 'Reading';

  @override
  String get hobbyMovie => 'Movie/Series';

  @override
  String get hobbyArt => 'Art';

  @override
  String get hobbyMusic => 'Music';

  @override
  String get hobbyCoding => 'Coding';

  @override
  String get hobbyPhotography => 'Photography';

  @override
  String get hobbyCrafts => 'Handcrafts';

  @override
  String get sectionChores => 'Chores';

  @override
  String get choreCleaning => 'Cleaning';

  @override
  String get choreShopping => 'Shopping';

  @override
  String get choreLaundry => 'Laundry';

  @override
  String get choreCooking => 'Cooking';

  @override
  String get choreIroning => 'Ironing';

  @override
  String get choreDishes => 'Dishes';

  @override
  String get choreRepair => 'Repair';

  @override
  String get chorePlants => 'Plants';

  @override
  String get sectionSelfCare => 'Self Care';

  @override
  String get careManicure => 'Manicure';

  @override
  String get careSkincare => 'Skincare';

  @override
  String get careHair => 'Hair Care';

  @override
  String get careMassage => 'Massage';

  @override
  String get careFaceMask => 'Face Mask';

  @override
  String get careBath => 'Bath';

  @override
  String get careDetox => 'Digital Detox';

  @override
  String get sectionWeather => 'Weather';

  @override
  String get weatherSunny => 'Sunny';

  @override
  String get weatherRainy => 'Rainy';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get weatherSnowy => 'Snowy';

  @override
  String get weatherWindy => 'Windy';

  @override
  String get weatherFoggy => 'Foggy';

  @override
  String get weatherHail => 'Hail';

  @override
  String get weatherSentenceSunny =>
      'The warmth and energy of the sun reflected on my entire day.';

  @override
  String get weatherSentenceRainy =>
      'The sound and peace of the rain accompanied my day.';

  @override
  String get weatherSentenceCloudy =>
      'Beams of light filtering through the clouds added serenity to my day.';

  @override
  String get weatherSentenceSnowy =>
      'The whiteness of the falling snow brought pure peace to my day.';

  @override
  String get weatherSentenceWindy =>
      'The energy and howl of the wind accompanied my day.';

  @override
  String get weatherSentenceFoggy =>
      'The fog descending on the city added a mysterious vibe to my day.';

  @override
  String get weatherSentenceHail =>
      'The sudden hail added excitement and action to my day.';

  @override
  String get sectionNotesMedia => 'Notes & Media';

  @override
  String get notesHint => 'Notes for today...';

  @override
  String get saveSuccess => 'Daily entry saved!';

  @override
  String get selectMoodWarning => 'Please select a mood';

  @override
  String get maxMediaWarning => 'You can add up to 5 photos.';

  @override
  String get goalNoSmoking => 'No Smoking';

  @override
  String get goalSocialDetox => 'Social Media Detox';

  @override
  String get goalReadBook => 'Read Book';

  @override
  String get goalDrinkWater => 'Drink Water';

  @override
  String get goalMeditation => 'Meditation';

  @override
  String get goalEarlyRise => 'Wake up Early';

  @override
  String get goalNoSugar => 'No Sugar';

  @override
  String get goalJournaling => 'Journaling';

  @override
  String get goalSteps => '10k Steps';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutWhatTitle => 'What is it?';

  @override
  String get aboutWhatDesc =>
      'DearDay is a personal development assistant designed to increase your emotional awareness and track your habits.';

  @override
  String get aboutPrivacyTitle => 'Privac';

  @override
  String get aboutPrivacyDesc =>
      'Your data is stored entirely **offline** on your device. It is never sent to any server.';

  @override
  String get aboutContentTitle => 'Content & Poems';

  @override
  String get aboutContentDesc =>
      'Poems and quotes in the app are for motivation and cultural sharing purposes. Content can be edited upon request of rights holders.';

  @override
  String get aboutLegalTitle => 'Legal Warning';

  @override
  String get aboutLegalDesc =>
      'This app is not a medical device. It does not replace professional psychological support.';

  @override
  String get aboutMadeWith => 'Made with ❤️ by Solymos';

  @override
  String get aboutContact => 'Contact';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get welcomeTitle => 'Welcome! 👋';

  @override
  String get welcomeSubtitle => 'Let\'s meet... How should we address you?';

  @override
  String get nameHint => 'Your Name';

  @override
  String get saveBtn => 'Save';

  @override
  String get startBtn => 'Start';

  @override
  String get nameRequiredMsg => 'Please enter your name.';

  @override
  String get profileUpdatedMsg => 'Profile updated!';

  @override
  String get analysisInsightsTitle => 'Smart Insights';

  @override
  String get insightPositiveTitle => 'Super Power';

  @override
  String get insightNegativeTitle => 'Watch Out';

  @override
  String insightImpactMsg(String activity, String percent) {
    return '$activity affects your mood by $percent%';
  }

  @override
  String get insightPremiumTitle => 'Unlock More';

  @override
  String get insightPremiumDesc => 'Become Premium to see all correlations.';

  @override
  String get insightWeekendTitle => 'Weekend Effect';

  @override
  String get insightWeekdayTitle => 'Weekday Effect';

  @override
  String get insightSleepTitle => 'Sleep Factor';

  @override
  String insightWeekendDesc(String percent) {
    return 'Your mood is $percent% higher on weekends.';
  }

  @override
  String get insightWeekdayDesc => 'You have higher energy on weekdays.';

  @override
  String insightSleepDesc(String percent) {
    return 'Good sleep boosts your mood by $percent%.';
  }

  @override
  String get viewMonth => 'Month';

  @override
  String get viewYear => 'Year';

  @override
  String get yearPixelsTitle => 'Year in Pixels';

  @override
  String get unlockYearView => 'Unlock Yearly View';

  @override
  String get exportToPdf => 'Download as PDF';

  @override
  String get exportToPdfDesc => 'Save your journal as a book format';

  @override
  String get premiumFeatureLocked => 'Premium Feature';

  @override
  String get noEntriesForPdf =>
      'No journal entries found. Please add at least one entry to create a PDF.';

  @override
  String get creatingPdf => 'Creating PDF...';

  @override
  String pdfError(String error) {
    return 'Error creating PDF: $error';
  }

  @override
  String get moodOfTheMonth => 'Mood of the Month: ';

  @override
  String get moodOfTheYear => 'Mood of the Year: ';

  @override
  String get insightTeaserSuperPowerTitle => 'Super Power? 🔒';

  @override
  String get insightTeaserSuperPowerDesc =>
      'Discover which activity makes you 40% happier.';

  @override
  String get insightTeaserEnergyDrainersTitle => 'Energy Drainers 🔒';

  @override
  String get insightTeaserEnergyDrainersDesc =>
      'Find hidden reasons draining your mood.';

  @override
  String get insightTeaserSleepAnalysisTitle => 'Sleep Analysis 🔒';

  @override
  String get insightTeaserSleepAnalysisDesc =>
      'How does sleep affect your day?';

  @override
  String get dataCollectionTitle => 'Gathering Data... ⏳';

  @override
  String get dataCollectionDesc =>
      'You need to enter data for at least 3-5 days for analysis. Keep journaling!';
}
