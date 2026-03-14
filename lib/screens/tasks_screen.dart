import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../components/priority_badge.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _todoTasks = [
    {
      'title': 'Finish the project report',
      'priority': 'High',
      'deadline': 'Friday',
      'tags': ['#work'],
    },
    {
      'title': 'Check new Python library',
      'priority': 'Medium',
      'deadline': null,
      'tags': ['#python', '#learning'],
    },
  ];

  final List<Map<String, dynamic>> _doingTasks = [
    {
      'title': 'Prepare presentation slides',
      'priority': 'High',
      'deadline': 'Thursday',
      'tags': ['#work'],
    },
  ];

  final List<Map<String, dynamic>> _doneTasks = [
    {
      'title': 'Buy groceries',
      'priority': 'Low',
      'deadline': null,
      'tags': ['#personal'],
    },
    {
      'title': 'Schedule dentist appointment',
      'priority': 'Medium',
      'deadline': null,
      'tags': ['#health'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBg,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.neutralWhite),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('✅ ', style: TextStyle(fontSize: 24)),
                  Text('Tasks', style: AppTextStyles.title),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.neutralLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: AppColors.neutralWhite,
                unselectedLabelColor: AppColors.neutralDark,
                labelStyle: AppTextStyles.buttonSmall,
                unselectedLabelStyle: AppTextStyles.buttonSmall,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'To Do (${_todoTasks.length})'),
                  Tab(text: 'Doing (${_doingTasks.length})'),
                  Tab(text: 'Done (${_doneTasks.length})'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(_todoTasks, 'todo'),
                  _buildTaskList(_doingTasks, 'doing'),
                  _buildTaskList(_doneTasks, 'done'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks, String status) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.neutralBorder,
            ),
            const SizedBox(height: 12),
            Text(
              'No tasks here',
              style: AppTextStyles.body.copyWith(
                color: AppColors.neutralGray,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutralWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.neutralBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: status == 'done'
                      ? AppColors.success
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: status == 'done'
                        ? AppColors.success
                        : AppColors.neutralBorder,
                    width: 2,
                  ),
                ),
                child: status == 'done'
                    ? const Icon(Icons.check, size: 16,
                        color: AppColors.neutralWhite)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'] as String,
                      style: AppTextStyles.bold.copyWith(
                        decoration: status == 'done'
                            ? TextDecoration.lineThrough
                            : null,
                        color: status == 'done'
                            ? AppColors.neutralGray
                            : AppColors.neutralBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PriorityBadge(priority: task['priority'] as String),
                        if (task['deadline'] != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today,
                              size: 12, color: AppColors.neutralGray),
                          const SizedBox(width: 4),
                          Text(
                            task['deadline'] as String,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded),
                color: AppColors.neutralGray,
                iconSize: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}