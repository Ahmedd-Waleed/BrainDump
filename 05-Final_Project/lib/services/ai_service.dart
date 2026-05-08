/// AI Service — Gemini API
///
/// Sends captured thought text to Google Gemini and returns
/// a structured analysis (category, priority, deadline, tags).
///
/// If the API call fails (no internet, key invalid, timeout, etc.)
/// the NLPEngine will fall back to its on-device keyword logic.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/capture_model.dart';

/// Result returned from Gemini analysis (or fallback).
class AIAnalysisResult {
  final CaptureCategory category;
  final Priority priority;
  final DateTime? deadline;
  final List<String> tags;
  final String summary;

  const AIAnalysisResult({
    required this.category,
    required this.priority,
    this.deadline,
    required this.tags,
    required this.summary,
  });
}

class AIService {
  AIService._();

  // ═══════════════════════════════════════════════════════════════
  //  ⚠️ PASTE YOUR GEMINI API KEY HERE ⚠️
  //  Get one (free) at: https://aistudio.google.com/apikey
  // ═══════════════════════════════════════════════════════════════
  static const String _apiKey = 'PASTE_YOUR_GEMINI_API_KEY_HERE';

  // Using gemini-1.5-flash — fast, free tier, great for short text.
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Returns true if the API key has been set.
  static bool get isConfigured =>
      _apiKey.isNotEmpty && _apiKey != 'AIzaSyBCeTmCQnr6jZkO_kMQHJ9ws7xww5MG9HM';

  /// Calls Gemini API to analyze [text].
  /// Returns null if API call fails (caller should use fallback).
  static Future<AIAnalysisResult?> analyze(String text) async {
    if (!isConfigured) {
      debugPrint('[AIService] No API key configured — using fallback.');
      return null;
    }

    try {
      final prompt = _buildPrompt(text);

      final response = await http
          .post(
            Uri.parse('$_endpoint?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.2,
                'response_mime_type': 'application/json',
              }
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint(
            '[AIService] Gemini returned ${response.statusCode}: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = body['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return null;

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) return null;

      final rawText = parts[0]['text'] as String? ?? '';
      return _parseResponse(rawText, text);
    } catch (e) {
      debugPrint('[AIService] Failed: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════
  //  PROMPT
  // ═══════════════════════════════════════

  static String _buildPrompt(String text) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return '''
You are an assistant that analyzes a single captured thought and returns structured JSON.

Today's date: $today

Analyze this thought:
"""
$text
"""

Return ONLY valid JSON (no markdown, no extra text) with these exact fields:
{
  "category": one of ["task", "idea", "reminder", "note", "errand", "question"],
  "priority": one of ["high", "medium", "low"],
  "deadline": ISO 8601 date string (YYYY-MM-DD) if a deadline is mentioned, else null,
  "tags": array of 1-3 short lowercase tags WITHOUT the # symbol (e.g. ["work", "urgent"]),
  "summary": a short 1-line summary (max 60 characters)
}

Guidelines:
- "task" = something the user must do (work, action items)
- "idea" = a thought, concept, or possibility
- "reminder" = something to remember (meeting, appointment)
- "errand" = shopping, picking up, buying
- "question" = something the user is asking or wondering
- "note" = general observation, anything that doesn't fit above
- High priority = urgent, deadline today/soon, contains "asap", "urgent", "!"
- Low priority = "someday", "maybe", "eventually"
- Medium priority = everything else
''';
  }

  // ═══════════════════════════════════════
  //  PARSE
  // ═══════════════════════════════════════

  static AIAnalysisResult? _parseResponse(String raw, String original) {
    try {
      // Strip markdown code fences if Gemini wraps them
      var cleaned = raw.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceAll(RegExp(r'```(?:json)?'), '').trim();
      }

      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      // Category
      final categoryStr = (json['category'] as String? ?? 'note').toLowerCase();
      final category = CaptureCategory.fromString(categoryStr);

      // Priority
      final priorityStr =
          (json['priority'] as String? ?? 'medium').toLowerCase();
      final priority = Priority.fromString(priorityStr);

      // Deadline
      DateTime? deadline;
      final deadlineRaw = json['deadline'];
      if (deadlineRaw is String && deadlineRaw.isNotEmpty) {
        deadline = DateTime.tryParse(deadlineRaw);
      }

      // Tags — ensure they have # prefix and are lowercase
      final tagsRaw = json['tags'] as List? ?? [];
      final tags = tagsRaw
          .map((t) => t.toString().toLowerCase().trim())
          .where((t) => t.isNotEmpty)
          .map((t) => t.startsWith('#') ? t : '#$t')
          .take(3)
          .toList();

      // Summary
      var summary = (json['summary'] as String? ?? '').trim();
      if (summary.isEmpty) {
        summary = original.length <= 60
            ? original
            : '${original.substring(0, 57)}...';
      }

      return AIAnalysisResult(
        category: category,
        priority: priority,
        deadline: deadline,
        tags: tags,
        summary: summary,
      );
    } catch (e) {
      debugPrint('[AIService] Failed to parse Gemini response: $e\nRaw: $raw');
      return null;
    }
  }
}