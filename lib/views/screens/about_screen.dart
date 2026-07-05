import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/platform_info.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const AppLogo(size: 100),
                  const SizedBox(height: 16),
                  Text(
                    'Lango',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Translate offline and online, with voice input support.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _FeatureSection(
              icon: Icons.mic_rounded,
              color: AppColors.mint,
              title: 'Speech to Text',
              subtitle:
                  '${PlatformInfo.speechToTextLanguages.length} language supported',
              languages: PlatformInfo.speechToTextLanguages,
            ),
            const SizedBox(height: 16),
            _FeatureSection(
              icon: Icons.language_rounded,
              color: AppColors.lavender,
              title: 'Online Translation',
              subtitle:
                  '${PlatformInfo.googleTranslateLanguageCount} languages via Google Translate',
              languages: const [
                'All languages available on Google Translate',
              ],
              showFullList: false,
            ),
            const SizedBox(height: 16),
            _FeatureSection(
              icon: Icons.cloud_off_rounded,
              color: AppColors.softOrange,
              title: 'Offline Translation',
              subtitle:
                  '${PlatformInfo.onDeviceLanguageCount} on-device · '
                  '${PlatformInfo.offlineLanguageCount} via HY-MT (dev)',
              languages: PlatformInfo.offlineTranslationLanguages,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureSection extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final List<String> languages;
  final bool showFullList;

  const _FeatureSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.languages,
    this.showFullList = true,
  });

  @override
  State<_FeatureSection> createState() => _FeatureSectionState();
}

class _FeatureSectionState extends State<_FeatureSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.lavender.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: AppColors.textPrimary, size: 22),
            ),
            title: Text(
              widget.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              widget.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: widget.showFullList
                ? IconButton(
                    icon: Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                    onPressed: () => setState(() => _expanded = !_expanded),
                  )
                : null,
          ),
          if (!widget.showFullList)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                widget.languages.first,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          if (widget.showFullList && _expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.languages
                    .map(
                      (lang) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          lang,
                          style: GoogleFonts.poppins(fontSize: 11),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (widget.showFullList && !_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Tap to view all ${widget.languages.length} languages',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.lavenderDeep,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
