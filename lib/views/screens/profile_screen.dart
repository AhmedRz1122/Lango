import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/translation_mode.dart';
import '../../viewmodels/app_view_model.dart';
import '../../viewmodels/translate_view_model.dart';
import '../widgets/app_logo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appVm = context.watch<AppViewModel>();
    final translateVm = context.watch<TranslateViewModel>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const AppLogo(size: 120),
            const SizedBox(height: 16),
            Text(
              appVm.userName,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              appVm.userEmail,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _SettingsSection(
              title: 'Translation Mode',
              children: [
                _ModeTile(
                  mode: TranslationMode.auto,
                  current: appVm.translationMode,
                  icon: Icons.sync_rounded,
                  onTap: () {
                    appVm.setTranslationMode(TranslationMode.auto);
                    translateVm.setMode(TranslationMode.auto);
                  },
                ),
                _ModeTile(
                  mode: TranslationMode.online,
                  current: appVm.translationMode,
                  icon: Icons.cloud_rounded,
                  onTap: () {
                    appVm.setTranslationMode(TranslationMode.online);
                    translateVm.setMode(TranslationMode.online);
                  },
                ),
                _ModeTile(
                  mode: TranslationMode.offline,
                  current: appVm.translationMode,
                  icon: Icons.cloud_off_rounded,
                  onTap: () {
                    appVm.setTranslationMode(TranslationMode.offline);
                    translateVm.setMode(TranslationMode.offline);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'Status',
              children: [
                _StatusTile(
                  label: 'Network',
                  value: appVm.isOnline ? 'Connected' : 'Disconnected',
                  isGood: appVm.isOnline,
                ),
                _StatusTile(
                  label: 'Offline Engine',
                  value: appVm.offlineAvailable ? 'Ready' : 'Not available',
                  isGood: appVm.offlineAvailable,
                ),
                _StatusTile(
                  label: 'Speech Recognition',
                  value: translateVm.speechService.isInitialized
                      ? 'Ready'
                      : 'Not initialized',
                  isGood: translateVm.speechService.isInitialized,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'About',
              children: const [
                _AboutContent(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.appName,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version ${AppConstants.appVersion}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${AppConstants.appName} is a multilingual translation companion built for '
            'travel, study, and everyday conversation. Translate text and speech '
            'between languages with a focus on clarity, speed, and ease of use.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _AboutBullet(
            icon: Icons.translate_rounded,
            title: 'Text translation',
            body:
                'Type or paste content and receive accurate translations in offline '
                'or online mode, depending on your connection and preference.',
          ),
          const SizedBox(height: 12),
          _AboutBullet(
            icon: Icons.mic_rounded,
            title: 'Voice input',
            body:
                'Speak naturally and have your words transcribed for translation, '
                'ideal when typing is inconvenient.',
          ),
          const SizedBox(height: 12),
          _AboutBullet(
            icon: Icons.cloud_off_rounded,
            title: 'Offline support',
            body:
                'Core languages work on your device without an internet connection '
                'once language packs are set up.',
          ),
          const SizedBox(height: 12),
          _AboutBullet(
            icon: Icons.language_rounded,
            title: 'Extended online coverage',
            body:
                'When connected, access a broader set of languages through secure '
                'cloud translation.',
          ),
          const SizedBox(height: 12),
          _AboutBullet(
            icon: Icons.history_rounded,
            title: 'History & favorites',
            body:
                'Review past translations and mark useful phrases for quick access later.',
          ),
          const SizedBox(height: 16),
          Text(
            'Privacy note: Offline translations are processed on your device. '
            'Online translations are sent only when you choose cloud mode and '
            'have an active connection.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.45,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _AboutBullet({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.lavenderDeep),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  final TranslationMode mode;
  final TranslationMode current;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeTile({
    required this.mode,
    required this.current,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == current;
    return ListTile(
      leading: Icon(icon, color: AppColors.lavenderDeep),
      title: Text(
        mode.label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        mode.description,
        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.mintDeep)
          : null,
      onTap: onTap,
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isGood;

  const _StatusTile({
    required this.label,
    required this.value,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isGood ? AppColors.mint : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
