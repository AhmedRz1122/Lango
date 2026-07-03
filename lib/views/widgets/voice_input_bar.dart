import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class VoiceInputBar extends StatefulWidget {
  final bool isListening;
  final bool isLoading;
  final VoidCallback onTap;

  const VoiceInputBar({
    super.key,
    required this.isListening,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  State<VoiceInputBar> createState() => _VoiceInputBarState();
}

class _VoiceInputBarState extends State<VoiceInputBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(VoiceInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening) {
      _waveController.repeat();
    } else {
      _waveController.stop();
      _waveController.reset();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        gradient: AppColors.voiceGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Waveform(controller: _waveController, isActive: widget.isListening),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: widget.isLoading ? null : widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: widget.isLoading
                        ? Colors.white.withValues(alpha: 0.7)
                        : widget.isListening
                            ? Colors.red.shade400
                            : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: widget.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.lavenderDeep,
                          ),
                        )
                      : Icon(
                          widget.isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          color: widget.isListening
                              ? Colors.white
                              : AppColors.lavenderDeep,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 20),
              _Waveform(
                controller: _waveController,
                isActive: widget.isListening,
                mirror: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.isLoading
                ? 'Loading speech model...'
                : widget.isListening
                    ? 'Listening...'
                    : 'Tap to speak',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  final AnimationController controller;
  final bool isActive;
  final bool mirror;

  const _Waveform({
    required this.controller,
    required this.isActive,
    this.mirror = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 40,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (i) {
              final phase = (controller.value + i * 0.15) % 1.0;
              final height = isActive
                  ? 8.0 + math.sin(phase * 2 * math.pi) * 12
                  : 4.0 + i * 2.0;
              return Container(
                width: 3,
                height: height.abs(),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isActive ? 0.8 : 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
