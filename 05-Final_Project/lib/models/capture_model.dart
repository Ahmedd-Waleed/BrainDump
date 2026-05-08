/// Capture Model
///
/// Represents a single thought captured by the user.
/// Stored in Firestore under: users/{uid}/captures/{captureId}

import 'package:cloud_firestore/cloud_firestore.dart';

enum CaptureCategory {
  task,
  idea,
  reminder,
  note,
  errand,
  question;

  String get label {
    switch (this) {
      case CaptureCategory.task:
        return 'Task';
      case CaptureCategory.idea:
        return 'Idea';
      case CaptureCategory.reminder:
        return 'Reminder';
      case CaptureCategory.note:
        return 'Note';
      case CaptureCategory.errand:
        return 'Errand';
      case CaptureCategory.question:
        return 'Question';
    }
  }

  static CaptureCategory fromString(String value) {
    return CaptureCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => CaptureCategory.note,
    );
  }
}

enum Priority {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => Priority.medium,
    );
  }
}

enum CaptureStatus { active, archived, convertedToTask }

class Capture {
  final String id;
  final String content;
  final String source; // "voice" or "text"
  final DateTime capturedAt;
  final CaptureCategory category;
  final Priority priority;
  final List<String> tags;
  final DateTime? deadline;
  final String? summary;
  final CaptureStatus status;

  const Capture({
    required this.id,
    required this.content,
    required this.source,
    required this.capturedAt,
    required this.category,
    required this.priority,
    required this.tags,
    this.deadline,
    this.summary,
    this.status = CaptureStatus.active,
  });

  // ═══════════════════════════════════════
  //  Firestore Serialization
  // ═══════════════════════════════════════

  factory Capture.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Capture(
      id: doc.id,
      content: data['content'] ?? '',
      source: data['source'] ?? 'text',
      capturedAt: (data['capturedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      category: CaptureCategory.fromString(data['category'] ?? 'note'),
      priority: Priority.fromString(data['priority'] ?? 'medium'),
      tags: List<String>.from(data['tags'] ?? []),
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      summary: data['summary'],
      status: _statusFromString(data['status']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'source': source,
      'capturedAt': Timestamp.fromDate(capturedAt),
      'category': category.name,
      'priority': priority.name,
      'tags': tags,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'summary': summary,
      'status': status.name,
    };
  }

  static CaptureStatus _statusFromString(String? value) {
    switch (value) {
      case 'archived':
        return CaptureStatus.archived;
      case 'convertedToTask':
        return CaptureStatus.convertedToTask;
      default:
        return CaptureStatus.active;
    }
  }

  Capture copyWith({
    String? content,
    CaptureCategory? category,
    Priority? priority,
    List<String>? tags,
    DateTime? deadline,
    String? summary,
    CaptureStatus? status,
  }) {
    return Capture(
      id: id,
      content: content ?? this.content,
      source: source,
      capturedAt: capturedAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      deadline: deadline ?? this.deadline,
      summary: summary ?? this.summary,
      status: status ?? this.status,
    );
  }

  /// Returns a human-readable relative time (e.g., "2 min ago").
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(capturedAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} day ago';
    return '${(diff.inDays / 7).floor()} week ago';
  }
}
