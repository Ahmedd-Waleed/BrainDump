/// Capture Detail Screen
///
/// Shows full details of a single capture including AI analysis.
/// Allows user to convert to task, archive, or delete.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/category_chip.dart';
import '../components/outline_button.dart';
import '../components/primary_button.dart';
import '../components/priority_badge.dart';
import '../components/secondary_button.dart';
import '../models/capture_model.dart';
import '../repositories/capture_repository.dart';
import '../repositories/task_repository.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CaptureDetailScreen extends StatelessWidget {
  final Capture capture;

  const CaptureDetailScreen({super.key, required this.capture});

  Future<void> _convertToTask(BuildContext context) async {
    try {
      await TaskRepository().createFromCapture(capture);
      await CaptureRepository().markConvertedToTask(capture.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Converted to task!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _archive(BuildContext context) async {
    try {
      await CaptureRepository().archive(capture.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      // ignore
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete capture?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await CaptureRepository().deleteCapture(capture.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, y · h:mm a');

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.neutralBg,
      appBar: AppBar(
        title: Text(
          'Capture Detail',
          style: AppTextStyles.headerSmall.copyWith(
            color: isDark
                ? AppColors.darkText
                : AppColors.neutralBlack,
          ),
        ),
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.neutralWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Content card ──
            _Card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Content', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Text(
                    capture.content,
                    style: AppTextStyles.header.copyWith(
                      color: isDark
                          ? AppColors.darkText
                          : AppColors.neutralBlack,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Details ──
            _Card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details', style: AppTextStyles.caption),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Category: ',
                        style: AppTextStyles.bold.copyWith(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.neutralBlack,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CategoryChip(category: capture.category.label),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Priority: ',
                        style: AppTextStyles.bold.copyWith(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.neutralBlack,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PriorityBadge(priority: capture.priority.label),
                    ],
                  ),
                  if (capture.deadline != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Deadline: ',
                          style: AppTextStyles.bold.copyWith(
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.neutralBlack,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, y').format(capture.deadline!),
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Captured: ',
                        style: AppTextStyles.bold.copyWith(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.neutralBlack,
                        ),
                      ),
                      Text(
                        dateFormat.format(capture.capturedAt),
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                  if (capture.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: capture.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primaryBgDark
                                    : AppColors.primaryBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── AI Analysis card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.micGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.neutralWhite,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Analysis',
                        style: AppTextStyles.headerSmall.copyWith(
                          color: AppColors.neutralWhite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This thought was automatically classified as a '
                    '${capture.category.label} with ${capture.priority.label} '
                    'priority${capture.deadline != null ? ' and a detected deadline' : ''}. '
                    'BrainDump\'s on-device NLP engine analyzed your '
                    'wording and context to organize it instantly.',
                    style: AppTextStyles.body.copyWith(
                      color:
                          AppColors.neutralWhite.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Actions ──
            if (capture.status == CaptureStatus.active) ...[
              PrimaryButton(
                text: 'Convert to Task',
                icon: Icons.check_circle_outline,
                onPressed: () => _convertToTask(context),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Archive',
                icon: Icons.archive_outlined,
                onPressed: () => _archive(context),
              ),
            ] else if (capture.status == CaptureStatus.convertedToTask)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    SizedBox(width: 8),
                    Text(
                      'Already converted to task',
                      style: TextStyle(color: AppColors.success),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            AppOutlineButton(
              text: 'Delete',
              icon: Icons.delete_outline,
              borderColor: AppColors.error,
              textColor: AppColors.error,
              onPressed: () => _delete(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(16),
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
