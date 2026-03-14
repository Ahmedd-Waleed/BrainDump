import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  Color get _color {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.neutralGray;
    }
  }

  String get _dot {
    switch (priority.toLowerCase()) {
      case 'high':
        return '●';
      case 'medium':
        return '●';
      case 'low':
        return '●';
      default:
        return '●';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_dot, style: TextStyle(fontSize: 8, color: _color)),
          const SizedBox(width: 4),
          Text(
            priority,
            style: AppTextStyles.label.copyWith(color: _color),
          ),
        ],
      ),
    );
  }
}