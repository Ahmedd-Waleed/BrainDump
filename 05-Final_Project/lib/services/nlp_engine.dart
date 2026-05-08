/// NLP Engine
///
/// PRIMARY: Calls Gemini API via AIService for accurate analysis.
/// FALLBACK: On-device keyword + regex engine when API fails or
/// the device is offline. This ensures the app always works.
///
/// The public API is `analyze(text)` — returns AIAnalysisResult.
/// Note: this is now async (because Gemini is a network call).

import '../models/capture_model.dart';
import 'ai_service.dart';

// Re-export so existing imports of `AIAnalysisResult` from this file
// keep working without changing every file.
export 'ai_service.dart' show AIAnalysisResult;

class NLPEngine {
  NLPEngine._();

  /// Analyzes [text]. Tries Gemini first, falls back to on-device logic.
  static Future<AIAnalysisResult> analyze(String text) async {
    // Try the Gemini API
    final apiResult = await AIService.analyze(text);
    if (apiResult != null) return apiResult;

    // Fall back to on-device engine
    return _localAnalyze(text);
  }

  // ═══════════════════════════════════════════════════════════════
  //  LOCAL FALLBACK (the original on-device engine)
  // ═══════════════════════════════════════════════════════════════

  static AIAnalysisResult _localAnalyze(String text) {
    final lower = text.toLowerCase();
    return AIAnalysisResult(
      category: _detectCategory(lower),
      priority: _detectPriority(lower),
      deadline: _extractDeadline(lower),
      tags: _generateTags(lower),
      summary: _generateSummary(text),
    );
  }

  // ── Category keywords ─────────────────
  static const Map<CaptureCategory, List<String>> _categoryKeywords = {
    CaptureCategory.task: [
      'finish', 'complete', 'submit', 'send', 'write',
      'prepare', 'review', 'fix', 'do', 'must', 'need to',
      'have to', 'should', 'deadline', 'due', 'work on',
      'build', 'create', 'develop', 'deliver',
    ],
    CaptureCategory.idea: [
      'idea', 'maybe', 'what if', 'could', 'might',
      'try', 'experiment', 'consider', 'think about',
      'concept', 'invent', 'design', 'imagine',
      'brainstorm', 'innovation',
    ],
    CaptureCategory.reminder: [
      'remember', 'remind', 'don\'t forget', 'note to self',
      'recall', 'memo', 'mark', 'meeting', 'appointment',
    ],
    CaptureCategory.errand: [
      'buy', 'get', 'pick up', 'shop', 'purchase',
      'groceries', 'milk', 'bread', 'eggs', 'store',
      'pharmacy', 'gas', 'order',
    ],
    CaptureCategory.question: [
      'why', 'how', 'what', 'when', 'where', 'who',
      'which', 'is it', 'are they', '?', 'wonder',
      'curious', 'figure out',
    ],
  };

  static const List<String> _highPriorityWords = [
    'urgent', 'asap', 'immediately', 'critical', 'important',
    'priority', 'now', 'today', 'tomorrow', 'deadline',
    'must', 'emergency', 'rush', 'quickly',
  ];

  static const List<String> _lowPriorityWords = [
    'maybe', 'eventually', 'someday', 'later',
    'when i have time', 'optional', 'nice to have',
    'whenever', 'no rush',
  ];

  static final Map<String, int> _weekdays = {
    'monday': 1, 'mon': 1,
    'tuesday': 2, 'tue': 2, 'tues': 2,
    'wednesday': 3, 'wed': 3,
    'thursday': 4, 'thu': 4, 'thurs': 4,
    'friday': 5, 'fri': 5,
    'saturday': 6, 'sat': 6,
    'sunday': 7, 'sun': 7,
  };

  static CaptureCategory _detectCategory(String text) {
    final scores = <CaptureCategory, int>{};
    for (final entry in _categoryKeywords.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          score += keyword.split(' ').length * 2;
        }
      }
      scores[entry.key] = score;
    }
    if (text.contains('?')) {
      scores[CaptureCategory.question] =
          (scores[CaptureCategory.question] ?? 0) + 5;
    }
    final maxEntry =
        scores.entries.reduce((a, b) => a.value >= b.value ? a : b);
    if (maxEntry.value == 0) return CaptureCategory.note;
    return maxEntry.key;
  }

  static Priority _detectPriority(String text) {
    int highScore = 0;
    int lowScore = 0;
    for (final word in _highPriorityWords) {
      if (text.contains(word)) highScore++;
    }
    for (final word in _lowPriorityWords) {
      if (text.contains(word)) lowScore++;
    }
    final exclamations = '!'.allMatches(text).length;
    highScore += exclamations;
    if (highScore > lowScore && highScore > 0) return Priority.high;
    if (lowScore > 0) return Priority.low;
    return Priority.medium;
  }

  static DateTime? _extractDeadline(String text) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (text.contains('today')) return today;
    if (text.contains('tonight')) {
      return today.add(const Duration(hours: 20));
    }
    if (text.contains('tomorrow')) {
      return today.add(const Duration(days: 1));
    }
    if (text.contains('next week')) {
      return today.add(const Duration(days: 7));
    }
    if (text.contains('next month')) {
      return DateTime(now.year, now.month + 1, now.day);
    }
    if (text.contains('this weekend')) {
      final daysUntilSat = (6 - now.weekday) % 7;
      return today.add(Duration(days: daysUntilSat == 0 ? 7 : daysUntilSat));
    }

    for (final entry in _weekdays.entries) {
      final pattern = RegExp(r'\b' + entry.key + r'\b');
      if (pattern.hasMatch(text)) {
        final targetWeekday = entry.value;
        int daysUntil = (targetWeekday - now.weekday) % 7;
        if (daysUntil == 0) daysUntil = 7;
        return today.add(Duration(days: daysUntil));
      }
    }

    final inDaysMatch = RegExp(r'in (\d+) days?').firstMatch(text);
    if (inDaysMatch != null) {
      return today.add(Duration(days: int.parse(inDaysMatch.group(1)!)));
    }

    final inWeeksMatch = RegExp(r'in (\d+) weeks?').firstMatch(text);
    if (inWeeksMatch != null) {
      return today.add(Duration(days: int.parse(inWeeksMatch.group(1)!) * 7));
    }
    return null;
  }

  static const Map<String, List<String>> _tagDictionary = {
    'work': ['work', 'office', 'meeting', 'project', 'report',
      'presentation', 'client', 'boss', 'team', 'deadline'],
    'personal': ['home', 'family', 'friend', 'self', 'personal'],
    'health': ['doctor', 'dentist', 'gym', 'exercise', 'medicine',
      'appointment', 'health', 'workout'],
    'learning': ['learn', 'study', 'read', 'book', 'course',
      'tutorial', 'practice', 'research'],
    'finance': ['money', 'bill', 'pay', 'budget', 'expense',
      'invoice', 'tax', 'bank'],
    'shopping': ['buy', 'shop', 'purchase', 'order', 'amazon',
      'groceries', 'store'],
    'tech': ['code', 'programming', 'flutter', 'python',
      'javascript', 'app', 'software', 'bug', 'debug'],
    'travel': ['trip', 'flight', 'hotel', 'travel', 'vacation',
      'book', 'reservation'],
  };

  static List<String> _generateTags(String text) {
    final tags = <String>[];
    for (final entry in _tagDictionary.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          tags.add('#${entry.key}');
          break;
        }
      }
    }
    return tags.take(3).toList();
  }

  static String _generateSummary(String text) {
    final trimmed = text.trim();
    if (trimmed.length <= 60) return trimmed;
    return '${trimmed.substring(0, 57)}...';
  }
}