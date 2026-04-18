import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'screens/capture_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';

class BrainDumpPreview extends StatelessWidget {
  const BrainDumpPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainDump AI - Preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.neutralBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CaptureScreen(),
    InboxScreen(),
    TasksScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralBlack.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppColors.neutralWhite,
          indicatorColor: AppColors.primaryBg,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.mic_none_rounded),
              selectedIcon:
                  Icon(Icons.mic_rounded, color: AppColors.primary),
              label: 'Capture',
            ),
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined),
              selectedIcon:
                  Icon(Icons.inbox_rounded, color: AppColors.primary),
              label: 'Inbox',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(Icons.check_circle_rounded,
                  color: AppColors.primary),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded,
                  color: AppColors.primary),
              label: 'Insights',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded,
                  color: AppColors.primary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}