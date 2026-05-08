/// Capture Repository
///
/// All Firestore operations for captures.
/// Path: users/{uid}/captures/{captureId}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/capture_model.dart';
import '../services/nlp_engine.dart';

class CaptureRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _capturesRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('captures');
  }

  // ═══════════════════════════════════════
  //  CREATE
  // ═══════════════════════════════════════

  /// Save a captured thought. Runs Gemini-powered NLP analysis.
  /// (Now async — was sync before because old engine was on-device.)
  Future<String> saveCapture({
    required String content,
    required String source,
  }) async {
    final ref = _capturesRef;
    if (ref == null) throw Exception('User not signed in');
    if (content.trim().isEmpty) throw Exception('Content is empty');

    // Run NLP analysis (Gemini → fallback)
    final analysis = await NLPEngine.analyze(content);

    final docRef = await ref.add({
      'content': content.trim(),
      'source': source,
      'capturedAt': Timestamp.now(),
      'category': analysis.category.name,
      'priority': analysis.priority.name,
      'tags': analysis.tags,
      'deadline': analysis.deadline != null
          ? Timestamp.fromDate(analysis.deadline!)
          : null,
      'summary': analysis.summary,
      'status': 'active',
    });

    return docRef.id;
  }

  // ═══════════════════════════════════════
  //  READ
  // ═══════════════════════════════════════

  /// Stream all active captures, newest first.
  Stream<List<Capture>> watchAll() {
    final ref = _capturesRef;
    if (ref == null) return Stream.value([]);

    return ref
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => Capture.fromFirestore(d)).toList();
          list.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
          return list;
        });
  }

  /// Stream captures filtered by category.
  Stream<List<Capture>> watchByCategory(CaptureCategory? category) {
    final ref = _capturesRef;
    if (ref == null) return Stream.value([]);

    Query<Map<String, dynamic>> query =
        ref.where('status', isEqualTo: 'active');

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query.snapshots().map((snap) {
      final list = snap.docs.map((d) => Capture.fromFirestore(d)).toList();
      list.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      return list;
    });
  }

  /// NEW: Stream archived captures (for unarchive feature).
  Stream<List<Capture>> watchArchived() {
    final ref = _capturesRef;
    if (ref == null) return Stream.value([]);

    return ref
        .where('status', isEqualTo: 'archived')
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => Capture.fromFirestore(d)).toList();
          list.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
          return list;
        });
  }

  /// Get the most recent N captures (one-shot, not stream).
  Future<List<Capture>> getRecent(int n) async {
    final ref = _capturesRef;
    if (ref == null) return [];

    final snap = await ref.where('status', isEqualTo: 'active').get();
    final list = snap.docs.map((d) => Capture.fromFirestore(d)).toList();
    list.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return list.take(n).toList();
  }

  // ═══════════════════════════════════════
  //  UPDATE
  // ═══════════════════════════════════════

  Future<void> updateCapture(String id, Map<String, dynamic> data) async {
    final ref = _capturesRef;
    if (ref == null) return;
    await ref.doc(id).update(data);
  }

  Future<void> archive(String id) async {
    await updateCapture(id, {'status': 'archived'});
  }

  /// NEW: Restore an archived capture back to active.
  Future<void> unarchive(String id) async {
    await updateCapture(id, {'status': 'active'});
  }

  Future<void> markConvertedToTask(String id) async {
    await updateCapture(id, {'status': 'convertedToTask'});
  }

  // ═══════════════════════════════════════
  //  DELETE
  // ═══════════════════════════════════════

  Future<void> deleteCapture(String id) async {
    final ref = _capturesRef;
    if (ref == null) return;
    await ref.doc(id).delete();
  }
}