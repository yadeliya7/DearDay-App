import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:line_icons/line_icons.dart';

import 'home_tab.dart';
import 'mood_calendar_screen.dart';
import 'journal_screen.dart';

import 'analysis_screen.dart';

import 'profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0; // Default to Home

  final List<Widget> _widgetOptions = <Widget>[
    const HomeTab(), // Index 0: Akış (Home)
    const JournalScreen(), // Index 1: Günlük (Journal)
    const MoodCalendarScreen(), // Index 2: Takvim
    const AnalysisScreen(), // Index 3: Analiz
    const ProfileScreen(), // Index 4: Profil
  ];

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Existing colors for Dark Mode
    const darkSelected = Color.fromARGB(
      255,
      162,
      178,
      253,
    ); // Vibrant coral/periwinkle
    const darkUnselected = Color.fromARGB(
      255,
      202,
      201,
      201,
    ); // Medium brown/grey

    // New colors for Light Mode (Darker for visibility)
    // Using a dark warm grey/brown for broader appeal in a journal app
    const lightSelected = Color(0xFF2D2D2D); // Very Dark Grey (almost black)
    const lightUnselected = Color(0xFF8D8D8D); // Darker Grey

    // Determine effective colors
    final Color effectiveSelected = isDark ? darkSelected : lightSelected;
    final Color effectiveUnselected = isDark ? darkUnselected : lightUnselected;

    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? effectiveSelected : effectiveUnselected,
        size: 28,
      ),
      onPressed: () => onItemTapped(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // For transparent nav bar effect if needed
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.5 // Dark mode: 75% opacity
                      : 0.1, // Light mode: 55% opacity (more transparent)
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.3)
                        : const Color(0xFFD4A574).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home_filled, 0),
                  _buildNavItem(LineIcons.book, 1),
                  _buildNavItem(Icons.calendar_month, 2),
                  _buildNavItem(LineIcons.pieChart, 3),
                  _buildNavItem(LineIcons.user, 4),
                ],
              ),
            ),
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () { ... },
      //   ...
      // ),
      // Removed global FAB as per request

      // Depending on layout, we might want centerDocked, but simpler is safer first.
      // If we used a notched shape, we'd need BottomAppBar.
      // Standard FAB is fine.
    );
  }
}

// Reusing the Clipper (copied from HomeScreen or moved to utils)
// I'll duplicate it here to be safe and avoid tight coupling unless I move it to utils.
// Moving to utils is better but for speed I'll include it here or verify if it's public in HomeScreen.
// It was at the bottom of HomeScreen. ideally I should move it to a shared file.
// I will move it to lib/utils/ui_utils.dart in a future step or just duplicate for now.
// I'll duplicate for now to minimize file touches, will comment to refactor.
