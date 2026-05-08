/// Insights Screen
///
/// Shows analytics computed from the user's captures and tasks.
/// All stats come from real Firestore data.

import 'package:flutter/material.dart';

import '../models/capture_model.dart';
import '../models/task_model.dart';
import '../repositories/capture_repository.dart';
import '../repositories/task_repository.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.neutralBg,
      body: SafeArea(
        child: StreamBuilder<List<Capture>>(
          stream: CaptureRepository().watchAll(),
          builder: (context, captureSnap) {
            return StreamBuilder<List<Task>>(
              stream: TaskRepository().watchAll(),
              builder: (context, taskSnap) {
                final captures = captureSnap.data ?? [];
                final tasks = taskSnap.data ?? [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──
                      Row(
                        children: [
                          const Text('📊 ',
                              style: TextStyle(fontSize: 24)),
                          Text(
                            'Insights',
                            style: AppTextStyles.title.copyWith(
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.neutralBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Patterns from your thinking',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutralGray,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Summary Stats ──
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.psychology_rounded,
                              label: 'Total Thoughts',
                              value: '${captures.length}',
                              color: AppColors.primary,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.check_circle_rounded,
                              label: 'Tasks Done',
                              value:
                                  '${tasks.where((t) => t.status == TaskStatus.done).length}',
                              color: AppColors.success,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.trending_up_rounded,
                              label: 'This Week',
                              value: '${_thisWeekCount(captures)}',
                              color: AppColors.secondary,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.flag_rounded,
                              label: 'High Priority',
                              value:
                                  '${captures.where((c) => c.priority == Priority.high).length}',
                              color: AppColors.error,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Category Breakdown ──
                      Text(
                        'Category Breakdown',
                        style: AppTextStyles.headerSmall.copyWith(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.neutralBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CategoryBreakdown(
                          captures: captures, isDark: isDark),

                      const SizedBox(height: 24),

                      // ── Top Tags ──
                      Text(
                        'Top Tags',
                        style: AppTextStyles.headerSmall.copyWith(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.neutralBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _TopTags(captures: captures, isDark: isDark),

                      const SizedBox(height: 24),

                      // ── Daily Activity ──
                      Text(
                        'Last 7 Days',
                        style: AppTextStyles.headerSmall.copyWith(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.neutralBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _DailyActivity(
                          captures: captures, isDark: isDark),

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  int _thisWeekCount(List<Capture> captures) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return captures.where((c) => c.capturedAt.isAfter(cutoff)).length;
  }
}

// ═══════════════════════════════════════
//  STAT CARD
// ═══════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              color: isDark
                  ? AppColors.darkText
                  : AppColors.neutralBlack,
              fontSize: 24,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
//  CATEGORY BREAKDOWN
// ═══════════════════════════════════════

class _CategoryBreakdown extends StatelessWidget {
  final List<Capture> captures;
  final bool isDark;

  const _CategoryBreakdown({
    required this.captures,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (captures.isEmpty) {
      return _EmptyMessage(
        message: 'No captures yet. Start capturing thoughts to see patterns.',
        isDark: isDark,
      );
    }

    final counts = <CaptureCategory, int>{};
    for (final cat in CaptureCategory.values) {
      counts[cat] = 0;
    }
    for (final c in captures) {
      counts[c.category] = (counts[c.category] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sorted.first.value;
    final total = captures.length;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: sorted.where((e) => e.value > 0).map((entry) {
          final percent = (entry.value / total * 100).round();
          final progress = maxCount > 0 ? entry.value / maxCount : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.neutralBlack,
                      ),
                    ),
                    Text(
                      '${entry.value} ($percent%)',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark
                        ? AppColors.darkBg
                        : AppColors.neutralLight,
                    valueColor: AlwaysStoppedAnimation(
                      _categoryColor(entry.key),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _categoryColor(CaptureCategory cat) {
    switch (cat) {
      case CaptureCategory.task:
        return AppColors.categoryTask;
      case CaptureCategory.idea:
        return AppColors.categoryIdea;
      case CaptureCategory.reminder:
        return AppColors.categoryReminder;
      case CaptureCategory.note:
        return AppColors.categoryNote;
      case CaptureCategory.errand:
        return AppColors.categoryErrand;
      case CaptureCategory.question:
        return AppColors.categoryQuestion;
    }
  }
}

// ═══════════════════════════════════════
//  TOP TAGS
// ═══════════════════════════════════════

class _TopTags extends StatelessWidget {
  final List<Capture> captures;
  final bool isDark;

  const _TopTags({required this.captures, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final tagCounts = <String, int>{};
    for (final c in captures) {
      for (final tag in c.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    if (tagCounts.isEmpty) {
      return _EmptyMessage(
        message: 'No tags yet.',
        isDark: isDark,
      );
    }

    final sorted = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: top.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryBgDark
                  : AppColors.primaryBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.key,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${entry.value}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  DAILY ACTIVITY
// ═══════════════════════════════════════

class _DailyActivity extends StatelessWidget {
  final List<Capture> captures;
  final bool isDark;

  const _DailyActivity({
    required this.captures,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Build counts for last 7 days
    final counts = List<int>.filled(7, 0);
    for (final c in captures) {
      final dayDiff =
          today.difference(DateTime(c.capturedAt.year,
                  c.capturedAt.month, c.capturedAt.day))
              .inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        counts[6 - dayDiff]++;
      }
    }

    final maxCount = counts.fold<int>(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final count = counts[i];
                final height = maxCount > 0
                    ? (count / maxCount * 100).clamp(4.0, 100.0)
                    : 4.0;
                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (i) {
              final dayIndex =
                  (today.weekday - 1 - (6 - i) + 7) % 7;
              return Expanded(
                child: Text(
                  dayLabels[dayIndex],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
//  EMPTY MESSAGE
// ═══════════════════════════════════════

class _EmptyMessage extends StatelessWidget {
  final String message;
  final bool isDark;

  const _EmptyMessage({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.neutralGray,
        ),
      ),
    );
  }
}
