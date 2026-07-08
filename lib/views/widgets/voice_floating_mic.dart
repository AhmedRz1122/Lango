import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/language.dart';

/// Bottom-left floating mic control.
/// Tap = start/stop listening.
/// Long-press = expand language + mic options in a circle around the fab.
class VoiceFloatingMic extends StatefulWidget {
  final bool isListening;
  final bool isLoading;
  final Language sourceLang;
  final List<Language> languages;
  final VoidCallback onToggleListening;
  final ValueChanged<Language> onLanguageSelected;

  const VoiceFloatingMic({
    super.key,
    required this.isListening,
    this.isLoading = false,
    required this.sourceLang,
    required this.languages,
    required this.onToggleListening,
    required this.onLanguageSelected,
  });

  @override
  State<VoiceFloatingMic> createState() => _VoiceFloatingMicState();
}

class _VoiceFloatingMicState extends State<VoiceFloatingMic>
    with SingleTickerProviderStateMixin {
  bool _menuOpen = false;
  late final AnimationController _pulse;

  static const _micSize = 64.0;
  static const _orbitRadius = 78.0;
  static const _orbitButtonSize = 48.0;
  static const _canvasWidth = 170.0;
  static const _canvasHeight = 190.0;

  Offset get _micCenter => Offset(
        _micSize / 2,
        _canvasHeight - _micSize / 2,
      );

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(VoiceFloatingMic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _menuOpen = !_menuOpen);
  }

  Future<void> _pickLanguage() async {
    setState(() => _menuOpen = false);
    final selected = await showModalBottomSheet<Language>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _LanguageSheet(
        languages: widget.languages,
        current: widget.sourceLang,
      ),
    );
    if (selected != null) {
      widget.onLanguageSelected(selected);
    }
  }

  Offset _orbitOffset(double angleRadians) {
    const columnHeight = _orbitButtonSize + 20;
    return Offset(
      _micCenter.dx +
          _orbitRadius * math.cos(angleRadians) -
          _orbitButtonSize / 2,
      _micCenter.dy +
          _orbitRadius * math.sin(angleRadians) -
          columnHeight / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    const speakAngle = -math.pi / 2; // top
    const langAngle = -math.pi / 6; // upper-right (~30°)

    final speakPos = _orbitOffset(speakAngle);
    final langPos = _orbitOffset(langAngle);

    return SizedBox(
      width: _canvasWidth,
      height: _canvasHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: speakPos.dx,
            top: speakPos.dy,
            child: _OrbitButton(
              visible: _menuOpen,
              label: widget.isListening ? 'Stop' : 'Speak',
              icon: widget.isListening
                  ? Icons.stop_rounded
                  : Icons.mic_rounded,
              color: widget.isListening ? Colors.red : AppColors.lavenderDeep,
              onTap: () {
                setState(() => _menuOpen = false);
                if (!widget.isLoading) widget.onToggleListening();
              },
            ),
          ),
          Positioned(
            left: langPos.dx,
            top: langPos.dy,
            child: _OrbitButton(
              visible: _menuOpen,
              label: 'Lang',
              icon: Icons.translate_rounded,
              color: AppColors.mintDeep,
              onTap: _pickLanguage,
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isListening || widget.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      widget.isLoading ? 'Loading…' : 'Listening…',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lavenderDeep,
                      ),
                    ),
                  ),
                ScaleTransition(
                  scale: widget.isListening
                      ? Tween(begin: 1.0, end: 1.08).animate(
                          CurvedAnimation(
                            parent: _pulse,
                            curve: Curves.easeInOut,
                          ),
                        )
                      : const AlwaysStoppedAnimation(1.0),
                  child: GestureDetector(
                    onTap: widget.isLoading
                        ? null
                        : () {
                            if (_menuOpen) {
                              setState(() => _menuOpen = false);
                            } else {
                              widget.onToggleListening();
                            }
                          },
                    onLongPress: widget.isLoading ? null : _toggleMenu,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _micSize,
                      height: _micSize,
                      decoration: BoxDecoration(
                        color: widget.isLoading
                            ? Colors.white
                            : widget.isListening
                                ? Colors.red.shade400
                                : AppColors.lavenderDeep,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isListening
                                    ? Colors.red
                                    : AppColors.lavenderDeep)
                                .withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: _menuOpen
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                      child: widget.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.lavenderDeep,
                              ),
                            )
                          : Icon(
                              widget.isListening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitButton extends StatelessWidget {
  final bool visible;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OrbitButton({
    required this.visible,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSheet extends StatefulWidget {
  final List<Language> languages;
  final Language current;

  const _LanguageSheet({
    required this.languages,
    required this.current,
  });

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.languages.where((lang) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return lang.name.toLowerCase().contains(q) ||
          lang.code.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Column(
          children: [
            Text(
              'Voice language',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search language...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final lang = filtered[i];
                  final selected = lang.code == widget.current.code;
                  return ListTile(
                    leading:
                        Text(lang.flag, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      lang.name,
                      style: GoogleFonts.poppins(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check_circle,
                            color: AppColors.mintDeep)
                        : null,
                    onTap: () => Navigator.pop(context, lang),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
