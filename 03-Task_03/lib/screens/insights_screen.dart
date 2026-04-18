import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                children: [
                  const Text('📊 ', style: TextStyle(fontSize: 24)),
                  Text('Insights', style: AppTextStyles.title),
                ],
              ),
              Text(
                'Your weekly thought patterns',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutralGray,
                ),
              ),

              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  _buildStatCard('Captured', '34',
                      Icons.lightbulb_outline, AppColors.secondary),
                  const SizedBox(width: 12),
                  _buildStatCard('Tasks', '12',
                      Icons.check_circle_outline, AppColors.info),
                  const SizedBox(width: 12),
                  _buildStatCard('Done', '8',
                      Icons.celebration_outlined, AppColors.success),
                ],
              ),

              const SizedBox(height: 24),

              // Category Breakdown
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
                    Text('Category Breakdown',
                        style: AppTextStyles.headerSmall),
                    const SizedBox(height: 16),
                    _buildBarRow('Work', 0.45, AppColors.categoryTask),
                    const SizedBox(height: 10),
                    _buildBarRow('Ideas', 0.25, AppColors.categoryIdea),
                    const SizedBox(height: 10),
                    _buildBarRow('Personal', 0.18, AppColors.categoryErrand),
                    const SizedBox(height: 10),
                    _buildBarRow('Learning', 0.12, AppColors.categoryNote),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AI Insight
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
                          'AI Insight',
                          style: AppTextStyles.headerSmall.copyWith(
                            color: AppColors.neutralWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You capture most ideas between 2-4 PM. '
                      'This is your creative peak! Consider '
                      'scheduling brainstorming during this time.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.neutralWhite.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Top Tags
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
                        const Text('🏷️ ', style: TextStyle(fontSize: 16)),
                        Text('Top Tags', style: AppTextStyles.headerSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTagChip('#work', 15),
                        _buildTagChip('#python', 8),
                        _buildTagChip('#ideas', 6),
                        _buildTagChip('#learning', 5),
                        _buildTagChip('#personal', 4),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.title.copyWith(
                color: color,
                fontSize: 24,
              ),
            ),
            Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarRow(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.neutralLight,
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(value * 100).toInt()}%', style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildTagChip(String tag, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$tag ($count)',
        style: AppTextStyles.label.copyWith(color: AppColors.primary),
      ),
    );
  }
}