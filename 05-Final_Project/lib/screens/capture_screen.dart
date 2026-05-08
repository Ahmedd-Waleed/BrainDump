/// Capture Screen
///
/// Home screen for capturing thoughts. Real voice + text input,
/// real-time list of recent captures from Firestore.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../components/category_chip.dart';
import '../components/mic_button.dart';
import '../components/priority_badge.dart';
import '../models/capture_model.dart';
import '../repositories/capture_repository.dart';
import '../services/notification_service.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import 'capture_detail_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final TextEditingController _textController = TextEditingController();
  final CaptureRepository _repo = CaptureRepository();

  // Voice
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isRecording = false;

  bool _isSaving = false;

  // Cached stream — see comment in original file.
  late final Stream<List<Capture>> _capturesStream;

  @override
  void initState() {
    super.initState();
    _capturesStream = _repo.watchAll();
    _initSpeech();
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════
  //  VOICE
  // ═══════════════════════════════════════

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (e) => debugPrint('[Speech] error: $e'),
        onStatus: (status) => debugPrint('[Speech] status: $status'),
      );
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('[Speech] init failed: $e');
      _speechAvailable = false;
    }
  }

  Future<bool> _ensureMicPermission() async {
    // permission_handler doesn't work on web — skip there
    if (kIsWeb) return true;

    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _speech.stop();
      if (mounted) setState(() => _isRecording = false);
      return;
    }

    // Check permission
    final hasPermission = await _ensureMicPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission denied'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Re-init if not available (sometimes needed after permission grant)
    if (!_speechAvailable) {
      await _initSpeech();
    }

    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition unavailable on this device'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isRecording = true);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );

    // When listen() returns and we are no longer listening, flip back
    if (mounted && !_speech.isListening) {
      setState(() => _isRecording = false);
    }
  }

  // ═══════════════════════════════════════
  //  SAVE
  // ═══════════════════════════════════════

  Future<void> _saveText({String source = 'text'}) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Stop recording if active
    if (_isRecording) {
      await _speech.stop();
      setState(() => _isRecording = false);
    }

    setState(() => _isSaving = true);
    try {
      await _repo.saveCapture(content: text, source: source);
      _textController.clear();
      await NotificationService.instance.showCaptureSavedNotification(text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Thought captured!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ═══════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBg : AppColors.neutralBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Header ────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $firstName 👋',
                          style: AppTextStyles.title.copyWith(
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.neutralBlack,
                          ),
                        ),
                        Text(
                          'Capture your thoughts instantly',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutralGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: isDark
                        ? AppColors.primaryBgDark
                        : AppColors.primaryBg,
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Mic Button ────────────────
              Center(
                child: Column(
                  children: [
                    MicButton(
                      isRecording: _isRecording,
                      onTap: _toggleRecording,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isRecording
                          ? 'Listening... tap to stop'
                          : 'Tap to speak',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _isRecording
                            ? AppColors.error
                            : AppColors.neutralGray,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Text Input ────────────────
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.neutralBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: AppTextStyles.body.copyWith(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.neutralBlack,
                        ),
                        onSubmitted: (_) => _saveText(
                          source: _isRecording ? 'voice' : 'text',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Or type your thought here...',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.neutralGray,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: _isSaving
                            ? null
                            : () => _saveText(
                                  source: _isRecording ? 'voice' : 'text',
                                ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Recent Captures Header ────
              Text(
                'Recent Captures',
                style: AppTextStyles.headerSmall.copyWith(
                  color: isDark
                      ? AppColors.darkText
                      : AppColors.neutralBlack,
                ),
              ),
              const SizedBox(height: 12),

              // ── Recent Captures List ──────
              Expanded(
                child: StreamBuilder<List<Capture>>(
                  stream: _capturesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final captures = snapshot.data ?? [];
                    if (captures.isEmpty) {
                      return _buildEmptyState(isDark);
                    }

                    return ListView.separated(
                      itemCount: captures.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildCaptureCard(captures[index], isDark);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: AppColors.neutralBorder,
          ),
          const SizedBox(height: 12),
          Text(
            'No thoughts captured yet',
            style: AppTextStyles.body.copyWith(
              color: AppColors.neutralGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the mic or type your first thought',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureCard(Capture capture, bool isDark) {
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CategoryChip(category: capture.category.label),
                const SizedBox(width: 8),
                PriorityBadge(priority: capture.priority.label),
                const Spacer(),
                Text(
                  capture.timeAgo,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}