import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../components/category_chip.dart';
import '../components/priority_badge.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All', 'Task', 'Idea', 'Reminder', 'Note', 'Errand',
  ];

  final List<Map<String, dynamic>> _captures = [
    {
      'content': 'Finish the project report by Friday',
      'category': 'Task',
      'priority': 'High',
      'tags': ['#work', '#report'],
      'deadline': 'Friday',
      'time': 'Today, 2:30 PM',
    },
    {
      'content': 'Try new state management library for Flutter',
      'category': 'Idea',
      'priority': 'Medium',
      'tags': ['#flutter', '#learning'],
      'deadline': null,
      'time': 'Today, 1:15 PM',
    },
    {
      'content': 'Buy milk, eggs, and bread',
      'category': 'Errand',
      'priority': 'Low',
      'tags': ['#groceries'],
      'deadline': 'Today',
      'time': 'Today, 11:00 AM',
    },
    {
      'content': 'Call dentist to reschedule appointment',
      'category': 'Reminder',
      'priority': 'Medium',
      'tags': ['#health'],
      'deadline': null,
      'time': 'Yesterday, 4:20 PM',
    },
    {
      'content': 'What if we used microservices architecture?',
      'category': 'Idea',
      'priority': 'Medium',
      'tags': ['#architecture', '#work'],
      'deadline': null,
      'time': 'Yesterday, 9:30 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('📥 ', style: TextStyle(fontSize: 24)),
                          Text('Inbox', style: AppTextStyles.title),
                        ],
                      ),
                      Text(
                        '${_captures.length} thoughts captured',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutralGray,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search_rounded),
                    color: AppColors.neutralDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutralWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.neutralBorder,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: AppTextStyles.label.copyWith(
                          color: isSelected
                              ? AppColors.neutralWhite
                              : AppColors.neutralDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Captures List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _captures.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final capture = _captures[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neutralWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.neutralBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          capture['content'] as String,
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CategoryChip(
                              category: capture['category'] as String,
                            ),
                            const SizedBox(width: 8),
                            PriorityBadge(
                              priority: capture['priority'] as String,
                            ),
                            if (capture['deadline'] != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.infoBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 12, color: AppColors.info),
                                    const SizedBox(width: 4),
                                    Text(
                                      capture['deadline'] as String,
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...(capture['tags'] as List<String>).map(
                              (tag) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  tag,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              capture['time'] as String,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}