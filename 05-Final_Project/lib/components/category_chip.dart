import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  Color get _color {
    switch (category.toLowerCase()) {
      case 'task':
        return AppColors.categoryTask;
      case 'idea':
        return AppColors.categoryIdea;
      case 'reminder':
        return AppColors.categoryReminder;
      case 'note':
        return AppColors.categoryNote;
      case 'errand':
        return AppColors.categoryErrand;
      case 'question':
        return AppColors.categoryQuestion;
      default:
        return AppColors.neutralGray;
    }
  }

  IconData get _icon {
    switch (category.toLowerCase()) {
      case 'task':
        return Icons.check_circle_outline;
      case 'idea':
        return Icons.lightbulb_outline;
      case 'reminder':
        return Icons.notifications_none;
      case 'note':
        return Icons.sticky_note_2_outlined;
      case 'errand':
        return Icons.shopping_cart_outlined;
      case 'question':
        return Icons.help_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _color : _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _color.withValues(alpha: isSelected ? 1.0 : 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 16,
              color: isSelected ? AppColors.neutralWhite : _color,
            ),
            const SizedBox(width: 6),
            Text(
              category,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.neutralWhite : _color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
