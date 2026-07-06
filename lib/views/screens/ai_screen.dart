import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/translate_view_model.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TranslateViewModel>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Assistant',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Powered by Genkit for smart translation insights',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.lavenderLight,
                      AppColors.mintLight.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: vm.isAiLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.lavenderDeep,
                        ),
                      )
                    : vm.aiExplanation != null
                        ? SingleChildScrollView(
                            child: Text(
                              vm.aiExplanation!,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                height: 1.6,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 48,
                                color: AppColors.lavenderDeep.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Translate something first, then ask AI to explain nuances, cultural context, or alternative phrasings.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _AiActionButton(
                    icon: Icons.lightbulb_outline_rounded,
                    label: 'Explain Translation',
                    onTap: vm.sourceText.isNotEmpty && vm.translatedText.isNotEmpty
                        ? vm.explainWithAi
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AiActionButton(
                    icon: Icons.tips_and_updates_outlined,
                    label: 'Cultural Tips',
                    color: AppColors.mint,
                    onTap: vm.sourceText.isNotEmpty && vm.translatedText.isNotEmpty
                        ? vm.explainWithAi
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AiActionButton(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Alternatives',
                    color: AppColors.softOrange,
                    onTap: vm.sourceText.isNotEmpty && vm.translatedText.isNotEmpty
                        ? vm.explainWithAi
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AiActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _AiActionButton({
    required this.icon,
    required this.label,
    this.color = AppColors.lavender,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: enabled ? color.withValues(alpha: 0.2) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
