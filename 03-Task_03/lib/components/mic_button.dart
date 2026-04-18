import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MicButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const MicButton({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: widget.isRecording
                ? AppColors.micRecordingGradient
                : AppColors.micGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (widget.isRecording
                        ? AppColors.error
                        : AppColors.primary)
                    .withValues(alpha: 0.4),
                blurRadius: widget.isRecording ? 24 : 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
            color: AppColors.neutralWhite,
            size: 36,
          ),
        ),
      ),
    );
  }
}