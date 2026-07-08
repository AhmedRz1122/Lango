import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/translation_mode.dart';
import '../../viewmodels/app_view_model.dart';
import '../../viewmodels/translate_view_model.dart';
import '../widgets/language_selector.dart';
import '../widgets/voice_floating_mic.dart';

class TranslateScreen extends StatefulWidget {
  final bool startVoice;
  final bool forceOffline;
  final bool forceOnline;

  const TranslateScreen({
    super.key,
    this.startVoice = false,
    this.forceOffline = false,
    this.forceOnline = false,
  });

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  late final TextEditingController _textController;
  late TranslateViewModel _vm;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _vm = context.read<TranslateViewModel>();

    if (widget.startVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _vm.showVoiceInputBar();
      });
    }

    if (widget.forceOffline || widget.forceOnline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mode = widget.forceOnline
            ? TranslationMode.online
            : TranslationMode.offline;
        _vm.setMode(mode);
        context.read<AppViewModel>().setTranslationMode(mode);
      });
    }
  }

  @override
  void dispose() {
    _vm.hideVoiceInputBar();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TranslateViewModel>();

    if (_textController.text != vm.sourceText) {
      _textController.value = TextEditingValue(
        text: vm.sourceText,
        selection: TextSelection.collapsed(offset: vm.sourceText.length),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) vm.hideVoiceInputBar();
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(vm.mode == TranslationMode.online
              ? 'Online Translate'
              : 'Offline Translate'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () {},
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      vm.showVoiceInput ? 120 : 20,
                    ),
                    child: Column(
                      children: [
                        LanguageSelector(
                          languages: vm.availableLanguages,
                          sourceLang: vm.sourceLang,
                          targetLang: vm.targetLang,
                          onSourceChanged: vm.setSourceLang,
                          onTargetChanged: vm.setTargetLang,
                          onSwap: vm.swapLanguages,
                        ),
                        const SizedBox(height: 20),
                        _TranslationCard(
                          label: vm.sourceLang.name,
                          controller: _textController,
                          hint: 'Enter text to translate...',
                          color: AppColors.lavenderLight,
                          accentColor: AppColors.lavenderDeep,
                          isSource: true,
                          charCount: vm.sourceText.length,
                          onChanged: vm.setSourceText,
                          onMic: vm.isVoiceInputSupported
                              ? () => vm.toggleVoiceInputBar()
                              : null,
                          onSpeak: () =>
                              vm.speak(vm.sourceText, vm.sourceLang.code),
                          isListening: vm.isListening,
                          isVoiceActive: vm.showVoiceInput,
                        ),
                        const SizedBox(height: 16),
                        if (vm.state == TranslateState.translating)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: AppColors.lavenderDeep,
                            ),
                          )
                        else
                          _TranslationCard(
                            label: vm.targetLang.name,
                            text: vm.translatedText,
                            hint: 'Translation will appear here',
                            color: AppColors.mintLight,
                            accentColor: AppColors.mintDeep,
                            isSource: false,
                            onSpeak: () =>
                                vm.speak(vm.translatedText, vm.targetLang.code),
                            onCopy: () {
                              Clipboard.setData(
                                ClipboardData(text: vm.translatedText),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                ),
                              );
                            },
                          ),
                        if (vm.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            vm.errorMessage!,
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _QuickPhrases(
                          onSelected: (phrase) {
                            vm.setSourceText(phrase);
                            vm.translate();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (vm.showVoiceInput && vm.isVoiceInputSupported)
              Positioned(
                left: 16,
                bottom: 60,
                child: VoiceFloatingMic(
                  isListening: vm.isListening,
                  isLoading: vm.isSpeechLoading,
                  sourceLang: vm.sourceLang,
                  languages: vm.availableLanguages,
                  onToggleListening: vm.toggleListening,
                  onLanguageSelected: vm.setSourceLang,
                ),
              ),
          ],
        ),
        floatingActionButton: vm.sourceText.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: vm.translate,
                backgroundColor: AppColors.lavenderDeep,
                icon: const Icon(Icons.translate_rounded, color: Colors.white),
                label: Text(
                  'Translate',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class _TranslationCard extends StatelessWidget {
  final String label;
  final String? text;
  final TextEditingController? controller;
  final String hint;
  final Color color;
  final Color accentColor;
  final bool isSource;
  final int? charCount;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onMic;
  final VoidCallback? onSpeak;
  final VoidCallback? onCopy;
  final bool isListening;
  final bool isVoiceActive;

  const _TranslationCard({
    required this.label,
    this.text,
    this.controller,
    required this.hint,
    required this.color,
    required this.accentColor,
    required this.isSource,
    this.charCount,
    this.onChanged,
    this.onMic,
    this.onSpeak,
    this.onCopy,
    this.isListening = false,
    this.isVoiceActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          if (isSource && controller != null && onChanged != null)
            TextField(
              controller: controller,
              onChanged: onChanged,
              maxLines: 5,
              minLines: 3,
              maxLength: AppConstants.maxTextLength,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                counterText: '',
                filled: false,
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
            )
          else
            Text(
              (text ?? '').isEmpty ? hint : text!,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: (text ?? '').isEmpty
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : AppColors.textPrimary,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (onMic != null)
                _ActionIcon(
                  icon: isListening
                      ? Icons.stop_rounded
                      : Icons.mic_rounded,
                  onTap: onMic!,
                  color: isListening
                      ? Colors.red
                      : isVoiceActive
                          ? AppColors.lavenderDeep
                          : accentColor,
                  isHighlighted: isVoiceActive,
                ),
              if (onSpeak != null) ...[
                const SizedBox(width: 8),
                _ActionIcon(
                  icon: Icons.volume_up_rounded,
                  onTap: onSpeak!,
                  color: accentColor,
                ),
              ],
              if (onCopy != null) ...[
                const SizedBox(width: 8),
                _ActionIcon(
                  icon: Icons.copy_rounded,
                  onTap: onCopy!,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                _ActionIcon(
                  icon: Icons.share_rounded,
                  onTap: () {},
                  color: accentColor,
                ),
              ],
              const Spacer(),
              if (charCount != null)
                Text(
                  '$charCount/${AppConstants.maxTextLength}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool isHighlighted;

  const _ActionIcon({
    required this.icon,
    required this.onTap,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHighlighted
              ? color.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: isHighlighted
              ? Border.all(color: color.withValues(alpha: 0.5))
              : null,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _QuickPhrases extends StatelessWidget {
  final ValueChanged<String> onSelected;
  const _QuickPhrases({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Phrases',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.quickPhrases.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final phrase = AppConstants.quickPhrases[i];
              return GestureDetector(
                onTap: () => onSelected(phrase),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.lavender.withValues(alpha: 0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    phrase,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
