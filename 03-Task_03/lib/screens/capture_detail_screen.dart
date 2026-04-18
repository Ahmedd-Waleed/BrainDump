import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../components/category_chip.dart';
import '../components/priority_badge.dart';
import '../components/primary_button.dart';
import '../components/secondary_button.dart';

class CaptureDetailScreen extends StatelessWidget {
  final Map<String, String> capture;

  const CaptureDetailScreen({super.key, required this.capture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBg,
      appBar: AppBar(
        title: Text('Capture Detail', style: AppTextStyles.headerSmall),
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
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content Card
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
                  Text('Content', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Text(
                    capture['content'] ?? '',
                    style: AppTextStyles.header,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Meta Info
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
                      Text('Category: ', style: AppTextStyles.bold),
                      const SizedBox(width: 8),
                      CategoryChip(category: capture['category'] ?? 'Note'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Priority: ', style: AppTextStyles.bold),
                      const SizedBox(width: 8),
                      PriorityBadge(priority: capture['priority'] ?? 'Low'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Captured: ', style: AppTextStyles.bold),
                      const SizedBox(width: 8),
                      Text(
                        capture['time'] ?? 'Unknown',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // AI Analysis Card
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
                      const Icon(Icons.auto_awesome,
                          color: AppColors.neutralWhite, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI Analysis',
                        style: AppTextStyles.headerSmall
                            .copyWith(color: AppColors.neutralWhite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This thought was automatically categorized as a '
                    '${capture['category']} with ${capture['priority']} priority. '
                    'Consider breaking it into smaller actionable steps.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.neutralWhite.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            PrimaryButton(
              text: 'Convert to Task',
              icon: Icons.check_circle_outline,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              text: 'Archive',
              icon: Icons.archive_outlined,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
