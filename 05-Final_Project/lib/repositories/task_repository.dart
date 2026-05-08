/// Task Repository
///
/// All Firestore operations for tasks.
/// Path: users/{uid}/tasks/{taskId}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/capture_model.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _tasksRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  // ═══════════════════════════════════════
  //  CREATE
  // ═══════════════════════════════════════

  Future<String> createTask({
    required String title,
    String? description,
    required Priority priority,
    DateTime? deadline,
    List<String> tags = const [],
    String? sourceCaptureId,
  }) async {
    final ref = _tasksRef;
    if (ref == null) throw Exception('User not signed in');

    final docRef = await ref.add({
      'title': title.trim(),
      'description': description?.trim(),
      'priority': priority.name,
      'status': 'todo',
      'deadline':
          deadline != null ? Timestamp.fromDate(deadline) : null,
      'tags': tags,
      'sourceCaptureId': sourceCaptureId,
      'createdAt': Timestamp.now(),
      'completedAt': null,
    });

    return docRef.id;
  }

  /// Convert a capture into a task.
  Future<String> createFromCapture(Capture capture) async {
    return createTask(
      title: capture.content,
      priority: capture.priority,
      deadline: capture.deadline,
      tags: capture.tags,
      sourceCaptureId: capture.id,
    );
  }

  // ═══════════════════════════════════════
  //  READ
  // ═══════════════════════════════════════

  Stream<List<Task>> watchAll() {
    final ref = _tasksRef;
    if (ref == null) return Stream.value([]);

    return ref.snapshots().map((snap) {
      final list = snap.docs.map((d) => Task.fromFirestore(d)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Stream tasks filtered by status.
  /// Sorting is done client-side to avoid needing a composite Firestore index.
  Stream<List<Task>> watchByStatus(TaskStatus status) {
    final ref = _tasksRef;
    if (ref == null) return Stream.value([]);

    return ref
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => Task.fromFirestore(d)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // ═══════════════════════════════════════
  //  UPDATE
  // ═══════════════════════════════════════

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    final ref = _tasksRef;
    if (ref == null) return;
    await ref.doc(id).update(data);
  }

  Future<void> moveToStatus(String id, TaskStatus status) async {
    final ref = _tasksRef;
    if (ref == null) return;
    await ref.doc(id).update({
      'status': status.name,
      if (status == TaskStatus.done)
        'completedAt': Timestamp.now()
      else
        'completedAt': null,
    });
  }

  // ═══════════════════════════════════════
  //  DELETE
  // ═══════════════════════════════════════

  Future<void> deleteTask(String id) async {
    final ref = _tasksRef;
    if (ref == null) return;
    await ref.doc(id).delete();
  }
}