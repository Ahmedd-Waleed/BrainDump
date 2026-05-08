/// Inbox Screen
///
/// AI-organized list of captured thoughts. Filterable by category.
/// Includes:
///   - Search bar (client-side, case-insensitive)
///   - "Archived" filter to view archived captures with restore button
///   - Real-time updates from Firestore

import 'package:flutter/material.dart';

import '../components/category_chip.dart';
import '../components/priority_badge.dart';
import '../models/capture_model.dart';
import '../repositories/capture_repository.dart';
import '../repositories/task_repository.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import 'capture_detail_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String _selectedFilter = 'All';
  final CaptureRepository _captureRepo = CaptureRepository();
  final TaskRepository _taskRepo = TaskRepository();

  late final Stream<List<Capture>> _allCapturesStream;
  late Stream<List<Capture>> _filteredStream;

  // Search
  bool _searchOpen = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // 'Archived' is a virtual filter — same chip row, special handling
  final List<String> _filters = [
    'All',
    'Task',
    'Idea',
    'Reminder',
    'Note',
    'Errand',
    'Question',
    'Archived',
  ];

  @override
  void initState() {
    super.initState();
    _allCapturesStream = _captureRepo.watchAll();
    _filteredStream = _captureRepo.watchByCategory(null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Archived') {
        _filteredStream = _captureRepo.watchArchived();
      } else if (filter == 'All') {
        _filteredStream = _captureRepo.watchByCategory(null);
      } else {
        _filteredStream =
            _captureRepo.watchByCategory(CaptureCategory.fromString(filter));
      }
    });
  }

  bool get _isViewingArchived => _selectedFilter == 'Archived';

  // ═══════════════════════════════════════
  //  ACTIONS
  // ═══════════════════════════════════════

  Future<void> _convertToTask(Capture capture) async {
    try {
      await _taskRepo.createFromCapture(capture);
      await _captureRepo.markConvertedToTask(capture.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Converted to task!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _archive(Capture capture) async {
    try {
      await _captureRepo.archive(capture.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Archived'),
            backgroundColor: AppColors.neutralDark,
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.neutralWhite,
              onPressed: () => _captureRepo.unarchive(capture.id),
            ),
          ),
        );
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _unarchive(Capture capture) async {
    try {
      await _captureRepo.unarchive(capture.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('♻️ Restored to inbox'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // ignore
    }
  }

  // ═══════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.neutralBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Header / Search bar ───────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _searchOpen
                  ? _buildSearchBar(isDark)
                  : _buildHeader(isDark),
            ),

            const SizedBox(height: 16),

            // ── Filter Chips ──────────────
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
                    onTap: () => _setFilter(filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.neutralWhite),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.neutralBorder),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (filter == 'Archived') ...[
                            Icon(
                              Icons.archive_outlined,
                              size: 14,
                              color: isSelected
                                  ? AppColors.neutralWhite
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.neutralDark),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            filter,
                            style: AppTextStyles.label.copyWith(
                              color: isSelected
                                  ? AppColors.neutralWhite
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.neutralDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Captures List ─────────────
            Expanded(
              child: StreamBuilder<List<Capture>>(
                stream: _filteredStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var captures = snapshot.data ?? [];

                  // Apply client-side search filter
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    captures = captures.where((c) {
                      return c.content.toLowerCase().contains(q) ||
                          c.tags.any((t) => t.toLowerCase().contains(q)) ||
                          c.category.label.toLowerCase().contains(q);
                    }).toList();
                  }

                  if (captures.isEmpty) {
                    return _buildEmpty();
                  }

                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: captures.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildCard(captures[index], isDark);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return StreamBuilder<List<Capture>>(
      stream: _allCapturesStream,
      builder: (context, snap) {
        final count = snap.data?.length ?? 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📥 ', style: TextStyle(fontSize: 24)),
                    Text(
                      'Inbox',
                      style: AppTextStyles.title.copyWith(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.neutralBlack,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$count thoughts captured',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutralGray,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => setState(() => _searchOpen = true),
              icon: const Icon(Icons.search_rounded),
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.neutralDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
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
          const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.neutralGray,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: AppTextStyles.body.copyWith(
                color: isDark
                    ? AppColors.darkText
                    : AppColors.neutralBlack,
              ),
              decoration: InputDecoration(
                hintText: 'Search captures, tags, categories...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.neutralGray,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: AppColors.neutralGray,
            onPressed: () {
              setState(() {
                _searchOpen = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isViewingArchived
                ? Icons.archive_outlined
                : Icons.inbox_outlined,
            size: 64,
            color: AppColors.neutralBorder,
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? 'No matches for "$_searchQuery"'
                : (_isViewingArchived
                    ? 'No archived captures'
                    : 'No captures here'),
            style: AppTextStyles.body.copyWith(
              color: AppColors.neutralGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Capture capture, bool isDark) {
    // Archived view: no swipe, but show restore button.
    if (_isViewingArchived) {
      return _buildArchivedCard(capture, isDark);
    }

    return Dismissible(
      key: Key(capture.id),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.check, color: AppColors.neutralWhite),
            SizedBox(width: 8),
            Text(
              'Convert to task',
              style: TextStyle(color: AppColors.neutralWhite),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.neutralGray,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Archive',
              style: TextStyle(color: AppColors.neutralWhite),
            ),
            SizedBox(width: 8),
            Icon(Icons.archive, color: AppColors.neutralWhite),
          ],
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _convertToTask(capture);
        } else {
          _archive(capture);
        }
      },
      child: _buildCardContent(capture, isDark),
    );
  }

  Widget _buildArchivedCard(Capture capture, bool isDark) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.7,
          child: _buildCardContent(capture, isDark),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _unarchive(capture),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.unarchive_outlined,
                      size: 14,
                      color: AppColors.neutralWhite,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Restore',
                      style: TextStyle(
                        color: AppColors.neutralWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent(Capture capture, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CaptureDetailScreen(capture: capture),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              capture.content,
              style: AppTextStyles.body.copyWith(
                color: isDark
                    ? AppColors.darkText
                    : AppColors.neutralBlack,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CategoryChip(category: capture.category.label),
                PriorityBadge(priority: capture.priority.label),
                if (capture.deadline != null)
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
                        const Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDeadline(capture.deadline!),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (capture.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  ...capture.tags.map(
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
                    capture.timeAgo,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dDay = DateTime(deadline.year, deadline.month, deadline.day);

    if (dDay == today) return 'Today';
    if (dDay == today.add(const Duration(days: 1))) return 'Tomorrow';

    final diff = dDay.difference(today).inDays;
    if (diff > 0 && diff < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[deadline.weekday - 1];
    }
    return '${deadline.day}/${deadline.month}';
  }
}