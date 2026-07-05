import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/translation_mode.dart';
import '../../viewmodels/app_view_model.dart';
import '../../viewmodels/translate_view_model.dart';
import '../widgets/app_logo.dart';
import '../widgets/feature_card.dart';
import '../widgets/translate_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final appVm = context.watch<AppViewModel>();
    final translateVm = context.watch<TranslateViewModel>();
    final recent = translateVm.history.take(3).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const AppLogo(size: 48),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Welcome to Lango',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                _ModeBadge(
                  isOnline: appVm.isOnline,
                  mode: appVm.translationMode,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => appVm.refreshConnectivity(),
                  icon: const Icon(Icons.notifications_outlined),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => _openTranslate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lavender.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Type or paste text here..',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openTranslate(context, voice: true),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.lavenderLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: AppColors.lavenderDeep,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Features',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.92,
              children: [
                FeatureCard(
                  title: 'Voice Translator',
                  description: 'Speak and translate instantly',
                  icon: Icons.mic_rounded,
                  color: AppColors.mint,
                  onTap: () => _openTranslate(context, voice: true),
                ),
                FeatureCard(
                  title: 'Text Translator',
                  description: 'Type text in any language',
                  icon: Icons.translate_rounded,
                  color: AppColors.lavender,
                  onTap: () => _openTranslate(context),
                ),
                FeatureCard(
                  title: 'Offline Mode',
                  description: 'Translate without internet',
                  icon: Icons.cloud_off_rounded,
                  color: AppColors.softOrange,
                  onTap: () {
                    appVm.setTranslationMode(
                      appVm.translationMode.index == 1
                          ? TranslationMode.auto
                          : TranslationMode.offline,
                    );
                    _openTranslate(context);
                  },
                ),
                FeatureCard(
                  title: 'Favorites',
                  description: 'Your saved translations',
                  icon: Icons.favorite_rounded,
                  color: AppColors.softPink,
                  onTap: () => appVm.setNavIndex(2),
                ),
              ],
            ),
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Translations',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => appVm.setNavIndex(2),
                    child: Text(
                      'See all',
                      style: GoogleFonts.poppins(
                        color: AppColors.lavenderDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...recent.map((r) => _RecentItem(record: r)),
            ],
          ],
        ),
      ),
    );
  }

  void _openTranslate(BuildContext context, {bool voice = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TranslateScreen(
          startVoice: voice,
          forceOffline: true,
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  final bool isOnline;
  final dynamic mode;

  const _ModeBadge({required this.isOnline, required this.mode});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.mint : AppColors.softOrange;
    final label = isOnline ? 'Online' : 'Offline';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  final dynamic record;
  const _RecentItem({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(record.sourceLang.toUpperCase(), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(record.targetLang.toUpperCase(), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              record.sourceText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
