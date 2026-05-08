/// Main Navigation
///
/// The shell that contains the 5 main tabs:
/// Capture / Inbox / Tasks / Insights / Settings.

import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'capture_screen.dart';
import 'inbox_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';
import 'tasks_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    CaptureScreen(),
    InboxScreen(),
    TasksScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkSurface : AppColors.neutralWhite,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.neutralBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.neutralGray,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.mic_rounded),
                label: 'Capture',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inbox_outlined),
                activeIcon: Icon(Icons.inbox),
                label: 'Inbox',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline),
                activeIcon: Icon(Icons.check_circle),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights_outlined),
                activeIcon: Icon(Icons.insights),
                label: 'Insights',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
