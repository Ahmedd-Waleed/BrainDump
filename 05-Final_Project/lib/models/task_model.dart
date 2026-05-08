/// Task Model
///
/// Represents an actionable task. Tasks can be created manually
/// or converted from captures.
/// Stored in Firestore under: users/{uid}/tasks/{taskId}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'capture_model.dart';

enum TaskStatus {
  todo,
  doing,
  done;

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.doing:
        return 'Doing';
      case TaskStatus.done:
        return 'Done';
    }
  }

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TaskStatus.todo,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final Priority priority;
  final TaskStatus status;
  final DateTime? deadline;
  final List<String> tags;
  final String? sourceCaptureId;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.deadline,
    required this.tags,
    this.sourceCaptureId,
    required this.createdAt,
    this.completedAt,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      priority: Priority.fromString(data['priority'] ?? 'medium'),
      status: TaskStatus.fromString(data['status'] ?? 'todo'),
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      sourceCaptureId: data['sourceCaptureId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'tags': tags,
      'sourceCaptureId': sourceCaptureId,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  Task copyWith({
    String? title,
    String? description,
    Priority? priority,
    TaskStatus? status,
    DateTime? deadline,
    List<String>? tags,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      tags: tags ?? this.tags,
      sourceCaptureId: sourceCaptureId,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get deadlineLabel {
    if (deadline == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dDay = DateTime(deadline!.year, deadline!.month, deadline!.day);

    if (dDay == today) return 'Today';
    if (dDay == tomorrow) return 'Tomorrow';

    final diff = dDay.difference(today).inDays;
    if (diff > 0 && diff < 7) {
      const days = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];
      return days[deadline!.weekday - 1];
    }
    return '${deadline!.day}/${deadline!.month}';
  }
}
