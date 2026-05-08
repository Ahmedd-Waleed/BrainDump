/// Task Detail Screen

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/outline_button.dart';
import '../components/primary_button.dart';
import '../components/priority_badge.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  Future<void> _markDone(BuildContext context) async {
    try {
      await TaskRepository().moveToStatus(task.id, TaskStatus.done);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      // ignore
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
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
      await TaskRepository().deleteTask(task.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDone = task.status == TaskStatus.done;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.neutralBg,
      appBar: AppBar(
        title: Text(
          'Task Detail',
          style: AppTextStyles.headerSmall.copyWith(
            color: isDark
                ? AppColors.darkText
                : AppColors.neutralBlack,
          ),
        ),
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.neutralWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title card ──
            Container(
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
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.success
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone
                            ? AppColors.success
                            : AppColors.neutralBorder,
                        width: 2,
                      ),
                    ),
                    child: isDone
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.neutralWhite,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      task.title,
                      style: AppTextStyles.header.copyWith(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.neutralBlack,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Details card ──
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details', style: AppTextStyles.caption),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.flag_outlined,
                        size: 18,
                        color: AppColors.neutralGray,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Priority: ',
                        style: AppTextStyles.body.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.neutralDark,
                        ),
                      ),
                      PriorityBadge(priority: task.priority.label),
                    ],
                  ),
                  if (task.deadline != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: AppColors.neutralGray,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Deadline: ',
                          style: AppTextStyles.body.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.neutralDark,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, y')
                              .format(task.deadline!),
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: AppColors.neutralGray,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Status: ',
                        style: AppTextStyles.body.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.neutralDark,
                        ),
                      ),
                      Text(
                        task.status.label,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (task.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.label_outline,
                          size: 18,
                          color: AppColors.neutralGray,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: task.tags
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
                                      borderRadius:
                                          BorderRadius.circular(8),
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
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (!isDone)
              PrimaryButton(
                text: 'Mark as Done',
                icon: Icons.check_rounded,
                onPressed: () => _markDone(context),
              ),

            const SizedBox(height: 12),
            AppOutlineButton(
              text: 'Delete Task',
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
