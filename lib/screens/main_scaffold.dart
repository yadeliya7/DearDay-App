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
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0; // Default to Home

  final List<Widget> _widgetOptions = <Widget>[
    const HomeTab(), // Index 0: Akış (Home)
    const JournalScreen(), // Index 1: Günlük (Journal)
    const MoodCalendarScreen(), // Index 2: Takvim
    const AnalysisScreen(), // Index 3: Analiz
    const ProfileScreen(), // Index 4: Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white54,
        size: 28,
      ),
      onPressed: () => _onItemTapped(index),
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
                color: Theme.of(context).primaryColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
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
