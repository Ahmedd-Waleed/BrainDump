/// Onboarding Screen
///
/// Shown on first launch. Three pages introducing the app's
/// core features.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/primary_button.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.mic_rounded,
      title: 'Capture Instantly',
      description:
          'Tap once and speak — or type. Capture any thought in '
          'under three seconds, no matter where you are.',
      gradientColors: [AppColors.primary, Color(0xFF8B5CF6)],
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'AI Organizes For You',
      description:
          'Our on-device intelligence categorizes your thoughts, '
          'detects priorities, and extracts deadlines — automatically.',
      gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    ),
    _OnboardingPage(
      icon: Icons.insights_rounded,
      title: 'Discover Patterns',
      description:
          'Weekly insights show you when you think best, what '
          'matters most, and how to clear your mental clutter.',
      gradientColors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.neutralBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? AppColors.primary
                        : AppColors.neutralBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // Action button
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: isLast ? 'Get Started' : 'Next',
                icon: isLast ? null : Icons.arrow_forward_rounded,
                onPressed: () {
                  if (isLast) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: page.gradientColors,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: page.gradientColors.first.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              color: AppColors.neutralWhite,
              size: 72,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}
