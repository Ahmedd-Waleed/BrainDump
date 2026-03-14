import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../components/mic_button.dart';
import '../components/category_chip.dart';
import '../components/priority_badge.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  bool _isRecording = false;
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, String>> _recentCaptures = [
    {
      'content': 'Finish the project report by Friday',
      'category': 'Task',
      'priority': 'High',
      'time': '2 min ago',
    },
    {
      'content': 'Try that new state management library',
      'category': 'Idea',
      'priority': 'Medium',
      'time': '15 min ago',
    },
    {
      'content': 'Buy groceries on the way home',
      'category': 'Errand',
      'priority': 'Low',
      'time': '1 hour ago',
    },
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BrainDump', style: AppTextStyles.title),
                      Text(
                        'Capture your thoughts instantly',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutralGray,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryBg,
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Mic Button
              Center(
                child: Column(
                  children: [
                    MicButton(
                      isRecording: _isRecording,
                      onTap: () {
                        setState(() => _isRecording = !_isRecording);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isRecording ? 'Listening...' : 'Tap to speak',
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

              // Text Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutralBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: AppTextStyles.body,
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
                        onPressed: () {},
                        icon: const Icon(Icons.send_rounded),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Recent Captures Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Captures', style: AppTextStyles.headerSmall),
                  Text(
                    'See all',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Recent Captures List
              Expanded(
                child: ListView.separated(
                  itemCount: _recentCaptures.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final capture = _recentCaptures[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.neutralWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.neutralBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(capture['content']!, style: AppTextStyles.body),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              CategoryChip(category: capture['category']!),
                              const SizedBox(width: 8),
                              PriorityBadge(priority: capture['priority']!),
                              const Spacer(),
                              Text(capture['time']!,
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ),
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
}