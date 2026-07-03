import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/language.dart';

class LanguageSelector extends StatelessWidget {
  final Language sourceLang;
  final Language targetLang;
  final ValueChanged<Language> onSourceChanged;
  final ValueChanged<Language> onTargetChanged;
  final VoidCallback onSwap;

  const LanguageSelector({
    super.key,
    required this.sourceLang,
    required this.targetLang,
    required this.onSourceChanged,
    required this.onTargetChanged,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LangChip(
            language: sourceLang,
            onTap: () => _showPicker(context, onSourceChanged, sourceLang),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSwap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.lavender.withValues(alpha: 0.15),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.lavenderDeep,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _LangChip(
            language: targetLang,
            onTap: () => _showPicker(context, onTargetChanged, targetLang),
          ),
        ),
      ],
    );
  }

  void _showPicker(
    BuildContext context,
    ValueChanged<Language> onChanged,
    Language current,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _LanguagePicker(
        current: current,
        onSelected: (lang) {
          onChanged(lang);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final Language language;
  final VoidCallback onTap;

  const _LangChip({required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(language.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                language.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  final Language current;
  final ValueChanged<Language> onSelected;

  const _LanguagePicker({
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Language',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Language.supported.length,
              itemBuilder: (context, i) {
                final lang = Language.supported[i];
                final isSelected = lang.code == current.code;
                return ListTile(
                  leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    lang.name,
                    style: GoogleFonts.poppins(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.mintDeep)
                      : null,
                  onTap: () => onSelected(lang),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
