import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../components/priority_badge.dart';
import '../components/primary_button.dart';
import '../components/outline_button.dart';

class TaskDetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBg,
      appBar: AppBar(
        title: Text('Task Detail', style: AppTextStyles.headerSmall),
        backgroundColor: AppColors.neutralWhite,
        foregroundColor: AppColors.neutralBlack,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutralBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.neutralBorder, width: 2),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          task['title'] as String,
                          style: AppTextStyles.header,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutralBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details', style: AppTextStyles.caption),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined,
                          size: 18, color: AppColors.neutralGray),
                      const SizedBox(width: 10),
                      Text('Priority: ', style: AppTextStyles.body),
                      PriorityBadge(priority: task['priority'] as String),
                    ],
                  ),
                  if (task['deadline'] != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: AppColors.neutralGray),
                        const SizedBox(width: 10),
                        Text('Deadline: ', style: AppTextStyles.body),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.infoBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task['deadline'] as String,
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.info),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.label_outline,
                          size: 18, color: AppColors.neutralGray),
                      const SizedBox(width: 10),
                      Text('Tags: ', style: AppTextStyles.body),
                      ...(task['tags'] as List<String>).map(
                        (tag) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Subtasks Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutralBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtasks', style: AppTextStyles.headerSmall),
                      Icon(Icons.add_circle_outline,
                          color: AppColors.primary, size: 22),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSubtask('Break down requirements', true),
                  const SizedBox(height: 8),
                  _buildSubtask('Write first draft', false),
                  const SizedBox(height: 8),
                  _buildSubtask('Review and polish', false),
                ],
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Mark as Done',
              icon: Icons.check_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            AppOutlineButton(
              text: 'Delete Task',
              icon: Icons.delete_outline,
              borderColor: AppColors.error,
              textColor: AppColors.error,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtask(String title, bool isDone) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone ? AppColors.success : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? AppColors.success : AppColors.neutralBorder,
              width: 2,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 14, color: AppColors.neutralWhite)
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? AppColors.neutralGray : AppColors.neutralDark,
          ),
        ),
      ],
    );
  }
}
