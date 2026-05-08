/// Settings Screen
///
/// Wires up all the app preferences to ThemeProvider, SettingsProvider,
/// and AuthService.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You\'ll need to sign in again next time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await context.read<AuthService>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.neutralBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  const Text('⚙️ ', style: TextStyle(fontSize: 24)),
                  Text(
                    'Settings',
                    style: AppTextStyles.title.copyWith(
                      color: isDark
                          ? AppColors.darkText
                          : AppColors.neutralBlack,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Profile Card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.authGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          AppColors.neutralWhite.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.neutralWhite,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'User',
                            style: AppTextStyles.headerSmall.copyWith(
                              color: AppColors.neutralWhite,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.neutralWhite
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Appearance Section ──
              _SectionTitle(title: 'Appearance', isDark: isDark),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                child: Consumer<ThemeProvider>(
                  builder: (context, theme, _) {
                    return Column(
                      children: [
                        _ThemeOption(
                          label: 'Light',
                          icon: Icons.light_mode,
                          selected: theme.label == 'Light',
                          onTap: () => theme.setFromLabel('Light'),
                          isDark: isDark,
                        ),
                        _Divider(isDark: isDark),
                        _ThemeOption(
                          label: 'Dark',
                          icon: Icons.dark_mode,
                          selected: theme.label == 'Dark',
                          onTap: () => theme.setFromLabel('Dark'),
                          isDark: isDark,
                        ),
                        _Divider(isDark: isDark),
                        _ThemeOption(
                          label: 'System',
                          icon: Icons.smartphone,
                          selected: theme.label == 'System',
                          onTap: () => theme.setFromLabel('System'),
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── AI Section ──
              _SectionTitle(title: 'AI Preferences', isDark: isDark),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                child: Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    return Column(
                      children: [
                        _ToggleTile(
                          icon: Icons.auto_awesome,
                          title: 'Auto-categorize',
                          subtitle: 'Let AI categorize captures',
                          value: settings.autoCategorize,
                          onChanged: settings.setAutoCategorize,
                          isDark: isDark,
                        ),
                        _Divider(isDark: isDark),
                        _ToggleTile(
                          icon: Icons.flag_outlined,
                          title: 'Auto-priority',
                          subtitle: 'Detect priority from text',
                          value: settings.autoPriority,
                          onChanged: settings.setAutoPriority,
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Notifications Section ──
              _SectionTitle(title: 'Notifications', isDark: isDark),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                child: Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    return Column(
                      children: [
                        _ToggleTile(
                          icon: Icons.notifications_active_outlined,
                          title: 'Daily review',
                          subtitle: 'Review your captures at 8 PM',
                          value: settings.dailyReview,
                          onChanged: settings.setDailyReview,
                          isDark: isDark,
                        ),
                        _Divider(isDark: isDark),
                        _ToggleTile(
                          icon: Icons.calendar_today_outlined,
                          title: 'Deadline alerts',
                          subtitle: 'Notify before deadlines',
                          value: settings.deadlineAlerts,
                          onChanged: settings.setDeadlineAlerts,
                          isDark: isDark,
                        ),
                        _Divider(isDark: isDark),
                        _ToggleTile(
                          icon: Icons.insights_outlined,
                          title: 'Weekly insights',
                          subtitle: 'Receive a Sunday summary',
                          value: settings.weeklyInsights,
                          onChanged: settings.setWeeklyInsights,
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Account Section ──
              _SectionTitle(title: 'Account', isDark: isDark),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _signOut(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.errorBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: AppColors.error,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Sign Out',
                                style: AppTextStyles.bold.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.neutralGray,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: Text(
                  'BrainDump AI v1.0.0',
                  style: AppTextStyles.caption,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.bold.copyWith(
          color: isDark
              ? AppColors.darkText
              : AppColors.neutralBlack,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _SettingsCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.darkSurface : AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.neutralBorder,
        ),
      ),
      child: child,
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark
          ? AppColors.darkBorder
          : AppColors.neutralBorder,
      indent: 56,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bold.copyWith(
                  color: isDark
                      ? AppColors.darkText
                      : AppColors.neutralBlack,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: AppColors.neutralBorder,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bold.copyWith(
                    color: isDark
                        ? AppColors.darkText
                        : AppColors.neutralBlack,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
