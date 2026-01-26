import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  String _selectedThemeKey = 'peach';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    loadInitialization();
  }

  String get selectedThemeKey => _selectedThemeKey;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Define 5 custom FlexSchemeData themes
  static final Map<String, FlexSchemeData> _themes = {
    'peach': FlexSchemeData(
      name: 'Peach',
      description: 'Warm and welcoming peach theme',
      light: FlexSchemeColor(
        primary: const Color(0xFFFF7043), // Deep Orange
        primaryContainer: const Color(0xFFFFCCBC),
        secondary: const Color(0xFFFFAB91),
        secondaryContainer: const Color(0xFFFFE0B2),
        tertiary: const Color(0xFFFF8A65),
        tertiaryContainer: const Color(0xFFFFD4C4),
        appBarColor: const Color(0xFFFFE0B2),
        error: const Color(0xFFD32F2F),
      ),
      dark: FlexSchemeColor(
        primary: const Color(0xFFFF8A65),
        primaryContainer: const Color(0xFFBF360C),
        secondary: const Color(0xFFFFAB91),
        secondaryContainer: const Color(0xFF5D4037),
        tertiary: const Color(0xFFFFCCBC),
        tertiaryContainer: const Color(0xFF4E342E),
        appBarColor: const Color(0xFF3E2723), // Kept for consistency
        error: const Color(0xFFEF5350),
      ),
    ),
    'coffee': FlexSchemeData(
      name: 'Coffee',
      description: 'Earthy and sophisticated coffee theme',
      light: FlexSchemeColor(
        primary: const Color(0xFF6D4C41), // Brown
        primaryContainer: const Color(0xFFD7CCC8),
        secondary: const Color(0xFFA1887F),
        secondaryContainer: const Color(0xFFEFEBE9),
        tertiary: const Color(0xFF8D6E63),
        tertiaryContainer: const Color(0xFFBCAAA4),
        appBarColor: const Color(0xFFEFEBE9),
        error: const Color(0xFFD32F2F),
      ),
      dark: FlexSchemeColor(
        primary: const Color(0xFFA1887F),
        primaryContainer: const Color(0xFF4E342E),
        secondary: const Color(0xFFBCAAA4),
        secondaryContainer: const Color(0xFF3E2723),
        tertiary: const Color(0xFFD7CCC8),
        tertiaryContainer: const Color(0xFF5D4037),
        appBarColor: const Color(0xFF3E2723),
        error: const Color(0xFFEF5350),
      ),
    ),
    'ocean': FlexSchemeData(
      name: 'Ocean',
      description: 'Cool and calm ocean theme',
      light: FlexSchemeColor(
        primary: const Color(0xff0277BD), // Deep Blue
        primaryContainer: const Color(0xFFB3E5FC),
        secondary: const Color(0xFF81D4FA),
        secondaryContainer: const Color(0xFFE1F5FE),
        tertiary: const Color(0xFF4FC3F7),
        tertiaryContainer: const Color(0xFFB3E5FC),
        appBarColor: const Color(0xFFE1F5FE),
        error: const Color(0xFFD32F2F),
      ),
      dark: FlexSchemeColor(
        primary: const Color(0xFF4FC3F7),
        primaryContainer: const Color(0xFF01579B),
        secondary: const Color(0xFF81D4FA),
        secondaryContainer: const Color(0xFF0277BD),
        tertiary: const Color(0xFFB3E5FC),
        tertiaryContainer: const Color(0xFF0288D1),
        appBarColor: const Color(0xFF01579B),
        error: const Color(0xFFEF5350),
      ),
    ),
    'nature': FlexSchemeData(
      name: 'Nature',
      description: 'Fresh and vibrant nature theme',
      light: FlexSchemeColor(
        primary: const Color(0xFF2E7D32), // Forest Green
        primaryContainer: const Color(0xFFC8E6C9),
        secondary: const Color(0xFFA5D6A7),
        secondaryContainer: const Color(0xFFE8F5E9),
        tertiary: const Color(0xFF66BB6A),
        tertiaryContainer: const Color(0xFFC8E6C9),
        appBarColor: const Color(0xFFE8F5E9),
        error: const Color(0xFFD32F2F),
      ),
      dark: FlexSchemeColor(
        primary: const Color(0xFF66BB6A),
        primaryContainer: const Color(0xFF1B5E20),
        secondary: const Color(0xFFA5D6A7),
        secondaryContainer: const Color(0xFF2E7D32),
        tertiary: const Color(0xFFC8E6C9),
        tertiaryContainer: const Color(0xFF388E3C),
        appBarColor: const Color(0xFF1B5E20),
        error: const Color(0xFFEF5350),
      ),
    ),
    'berry': FlexSchemeData(
      name: 'Berry',
      description: 'Bold and creative berry theme',
      light: FlexSchemeColor(
        primary: const Color(0xFFAD1457), // Deep Pink
        primaryContainer: const Color(0xFFF8BBD0),
        secondary: const Color(0xFFEC407A),
        secondaryContainer: const Color(0xFFFCE4EC),
        tertiary: const Color(0xFFBA68C8),
        tertiaryContainer: const Color(0xFFF3E5F5),
        appBarColor: const Color(0xFFFCE4EC),
        error: const Color(0xFFD32F2F),
      ),
      dark: FlexSchemeColor(
        primary: const Color(0xFFEC407A),
        primaryContainer: const Color(0xFF880E4F),
        secondary: const Color(0xFFF48FB1),
        secondaryContainer: const Color(0xFFC2185B),
        tertiary: const Color(0xFFCE93D8),
        tertiaryContainer: const Color(0xFF7B1FA2),
        appBarColor: const Color(0xFF880E4F),
        error: const Color(0xFFEF5350),
      ),
    ),
    'midnight': FlexSchemeData(
      name: 'Midnight',
      description: 'Pure black theme for OLED screens',
      light: FlexSchemeColor(
        primary: const Color(0xFF424242), // Dark Grey
        primaryContainer: const Color(0xFFBDBDBD),
        secondary: const Color(0xFF757575),
        secondaryContainer: const Color(0xFFE0E0E0),
        tertiary: const Color(0xFF616161),
        tertiaryContainer: const Color(0xFFEEEEEE),
        appBarColor: const Color(0xFFF5F5F5),
        error: const Color(0xFFD32F2F),
      ),
      dark: FlexSchemeColor(
        primary: const Color(0xFF9E9E9E), // Light Grey for dark mode
        primaryContainer: const Color(0xFF212121),
        secondary: const Color(0xFFBDBDBD),
        secondaryContainer: const Color(0xFF121212),
        tertiary: const Color(0xFFE0E0E0),
        tertiaryContainer: const Color(0xFF1E1E1E),
        appBarColor: const Color(0xFF000000), // Pure black
        error: const Color(0xFFEF5350),
      ),
    ),
  };

  // Get current theme data
  ThemeData get currentLightTheme {
    final schemeData = _themes[_selectedThemeKey]!;

    // Define specific background colors for each theme
    final scaffoldBackgrounds = {
      'peach': const Color(0xFFFFE0B2), // Warm Peach
      'coffee': const Color(0xFFEFEBE9), // Soft Latte/Grey-Brown
      'ocean': const Color(0xFFE1F5FE), // Ice Blue
      'nature': const Color(0xFFE8F5E9), // Soft Mint
      'berry': const Color(0xFFFCE4EC), // Soft Pink
      'midnight': const Color(0xFFF5F5F5), // Very light grey
    };

    // Define specific CARD colors for each theme (lighter than background)
    final cardColors = {
      'peach': const Color(0xFFFFF3E0), // Lighter peachy cream
      'coffee': const Color(0xFFF5F5F5), // Very light cream
      'ocean': const Color.fromARGB(
        255,
        232,
        244,
        255,
      ), // Very light blue (slight tint, good contrast)
      'nature': const Color(0xFFF1F8E9), // Lighter mint
      'berry': const Color(0xFFF8BBD0), // Lighter rosy pink
      'midnight': const Color(0xFFFFFFFF), // Pure white cards
    };

    return FlexThemeData.light(
      colors: schemeData.light,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel:
          0, // Set to 0 to prevent blending that hides our custom background
      // CRITICAL: Force the scaffold background color
      scaffoldBackground: scaffoldBackgrounds[_selectedThemeKey],
      fontFamily: GoogleFonts.poppins().fontFamily, // Set Global Font
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 0, // Also set to 0 to preserve our custom colors
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        // Ensure transparent Bottom Nav for floating effect
        bottomNavigationBarType: BottomNavigationBarType.fixed,
        bottomNavigationBarElevation: 0,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.transparent,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    ).copyWith(
      // Override card color specifically
      cardColor: cardColors[_selectedThemeKey],
      cardTheme: CardThemeData(
        color: cardColors[_selectedThemeKey],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // CRITICAL: Ensure transparent background for floating nav bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFFF7043), // Peach accent
        unselectedItemColor: Color(0xFF8D6E63), // Brownish
      ),
    );
  }

  ThemeData get currentDarkTheme {
    final schemeData = _themes[_selectedThemeKey]!;

    // Define dark backgrounds for each theme (darker variants)
    final darkScaffoldBackgrounds = {
      'peach': const Color(0xFF4A2C1A), // Dark Peachy-Orange (not brown!)
      'coffee': const Color(0xFF3E2723), // Dark Brown
      'ocean': const Color(0xFF01579B), // Deep Blue
      'nature': const Color(0xFF1B5E20), // Dark Green
      'berry': const Color(0xFF880E4F), // Dark Pink
      'midnight': const Color(0xFF000000), // Pure black (OLED friendly)
    };

    // Define dark CARD colors (lighter than background, but still dark)
    final darkCardColors = {
      'peach': const Color(0xFF5D3A2A), // Slightly lighter dark peachy-brown
      'coffee': const Color(0xFF4E342E), // Slightly lighter brown
      'ocean': const Color(0xFF0277BD), // Lighter blue (distinguishable)
      'nature': const Color(0xFF2E7D32), // Lighter green (distinguishable)
      'berry': const Color(0xFFAD1457), // Lighter pink (distinguishable)
      'midnight': const Color(0xFF1C1C1C), // Very dark grey (visible on black)
    };

    return FlexThemeData.dark(
      colors: schemeData.dark,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 0, // Set to 0 to prevent blending in dark mode too
      // CRITICAL: Force the scaffold background color for dark mode
      scaffoldBackground: darkScaffoldBackgrounds[_selectedThemeKey],
      fontFamily: GoogleFonts.poppins().fontFamily, // Set Global Font
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 0, // Also set to 0
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        // Ensure transparent Bottom Nav for floating effect
        bottomNavigationBarType: BottomNavigationBarType.fixed,
        bottomNavigationBarElevation: 0,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.transparent,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    ).copyWith(
      // Override card color specifically for dark mode
      cardColor: darkCardColors[_selectedThemeKey],
      cardTheme: CardThemeData(
        color: darkCardColors[_selectedThemeKey],
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // CRITICAL: Ensure transparent background for floating nav bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFFF8A65), // Light Peach accent
        unselectedItemColor: Color(0xFFBCAAA4), // Light Brownish
      ),
    );
  }

  // Get theme preview color for UI
  Color getThemePreviewColor(String themeKey) {
    final schemeData = _themes[themeKey];
    return schemeData?.light.primary ?? Colors.grey;
  }

  // Set theme
  Future<void> setTheme(String themeKey) async {
    if (_themes.containsKey(themeKey)) {
      _selectedThemeKey = themeKey;
      notifyListeners();
      await _savePreferences();
    }
  }

  // Set theme mode (Light/Dark/System)
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _savePreferences();
  }

  // Legacy compatibility: Toggle dark mode
  Future<void> setDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _savePreferences();
  }

  void toggleTheme() {
    setDarkMode(!isDarkMode);
  }

  // Load preferences (Public for main initialization)
  Future<void> loadInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedThemeKey = prefs.getString('selected_theme') ?? 'peach';

    // Load theme mode
    final themeModeIndex = prefs.getInt('theme_mode') ?? 1; // Default to light
    _themeMode = ThemeMode.values[themeModeIndex];

    notifyListeners();
  }

  // Save preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', _selectedThemeKey);
    await prefs.setInt('theme_mode', _themeMode.index);
  }

  // Get all available theme keys
  static List<String> get availableThemes => _themes.keys.toList();
}
