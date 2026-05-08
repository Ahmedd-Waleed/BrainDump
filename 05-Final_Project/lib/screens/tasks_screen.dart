/// Tasks Screen
///
/// Kanban-style task board: To Do / Doing / Done.
/// Real-time data from Firestore.

import 'package:flutter/material.dart';

import '../components/priority_badge.dart';
import '../components/primary_button.dart';
import '../models/capture_model.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaskRepository _repo = TaskRepository();
  late final Stream<List<Task>> _todoStream;
  late final Stream<List<Task>> _doingStream;
  late final Stream<List<Task>> _doneStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _todoStream = _repo.watchByStatus(TaskStatus.todo);
    _doingStream = _repo.watchByStatus(TaskStatus.doing);
    _doneStream = _repo.watchByStatus(TaskStatus.done);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showAddTaskSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddTaskSheet(repo: _repo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.neutralBg,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
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
                  Text(
                    'Tasks',
                    style: AppTextStyles.title.copyWith(
                      color: isDark
                          ? AppColors.darkText
                          : AppColors.neutralBlack,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.neutralLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: AppColors.neutralWhite,
                unselectedLabelColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.neutralDark,
                labelStyle: AppTextStyles.buttonSmall,
                unselectedLabelStyle: AppTextStyles.buttonSmall,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'To Do'),
                  Tab(text: 'Doing'),
                  Tab(text: 'Done'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(_todoStream, isDark),
                  _buildTaskList(_doingStream, isDark),
                  _buildTaskList(_doneStream, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(Stream<List<Task>> stream, bool isDark) {
    return StreamBuilder<List<Task>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
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
            return _buildTaskCard(tasks[index], isDark);
          },
        );
      },
    );
  }

  Widget _buildTaskCard(Task task, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: task),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.neutralBorder,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final next = task.status == TaskStatus.done
                    ? TaskStatus.todo
                    : TaskStatus.done;
                await _repo.moveToStatus(task.id, next);
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: task.status == TaskStatus.done
                      ? AppColors.success
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.status == TaskStatus.done
                        ? AppColors.success
                        : AppColors.neutralBorder,
                    width: 2,
                  ),
                ),
                child: task.status == TaskStatus.done
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.neutralWhite,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTextStyles.bold.copyWith(
                      decoration: task.status == TaskStatus.done
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.status == TaskStatus.done
                          ? AppColors.neutralGray
                          : (isDark
                              ? AppColors.darkText
                              : AppColors.neutralBlack),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      PriorityBadge(priority: task.priority.label),
                      if (task.deadline != null) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: AppColors.neutralGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.deadlineLabel,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<TaskStatus>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.neutralGray,
              ),
              onSelected: (newStatus) {
                _repo.moveToStatus(task.id, newStatus);
              },
              itemBuilder: (ctx) => TaskStatus.values
                  .where((s) => s != task.status)
                  .map(
                    (s) => PopupMenuItem(
                      value: s,
                      child: Text('Move to ${s.label}'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  ADD TASK BOTTOM SHEET
// ═══════════════════════════════════════

class _AddTaskSheet extends StatefulWidget {
  final TaskRepository repo;

  const _AddTaskSheet({required this.repo});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  Priority _priority = Priority.medium;
  DateTime? _deadline;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.repo.createTask(
        title: _titleCtrl.text,
        priority: _priority,
        deadline: _deadline,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : AppColors.neutralWhite,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutralBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'New Task',
              style: AppTextStyles.header.copyWith(
                color: isDark
                    ? AppColors.darkText
                    : AppColors.neutralBlack,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Task title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Priority selector
            Text('Priority', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: Priority.values.map((p) {
                final selected = _priority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkBg
                                : AppColors.neutralLight),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        p.label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.label.copyWith(
                          color: selected
                              ? AppColors.neutralWhite
                              : AppColors.neutralDark,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Deadline picker
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutralBorder),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppColors.neutralGray,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _deadline == null
                          ? 'Add deadline (optional)'
                          : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Create Task',
              isLoading: _saving,
              onPressed: _save,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}