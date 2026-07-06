import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/language.dart';

class LanguageSelector extends StatelessWidget {
  final List<Language> languages;
  final Language sourceLang;
  final Language targetLang;
  final ValueChanged<Language> onSourceChanged;
  final ValueChanged<Language> onTargetChanged;
  final VoidCallback onSwap;

  const LanguageSelector({
    super.key,
    required this.languages,
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
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _LanguagePicker(
        languages: languages,
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

class _LanguagePicker extends StatefulWidget {
  final List<Language> languages;
  final Language current;
  final ValueChanged<Language> onSelected;

  const _LanguagePicker({
    required this.languages,
    required this.current,
    required this.onSelected,
  });

  @override
  State<_LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<_LanguagePicker> {
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
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            Text(
              'Select Language',
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
                  final isSelected = lang.code == widget.current.code;
                  return ListTile(
                    leading:
                        Text(lang.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      lang.name,
                      style: GoogleFonts.poppins(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      lang.code,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.mintDeep,
                          )
                        : null,
                    onTap: () => widget.onSelected(lang),
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
