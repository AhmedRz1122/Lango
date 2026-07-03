import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
              'Lango User',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Translation enthusiast',
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
                      ? 'Vosk ready'
                      : 'Not initialized',
                  isGood: translateVm.speechService.isInitialized,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'About',
              children: [
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  label: 'Version',
                  value: '1.0.0',
                ),
                _InfoTile(
                  icon: Icons.translate_rounded,
                  label: 'Offline Model',
                  value: 'Tencent HY-MT1.5',
                ),
                _InfoTile(
                  icon: Icons.mic_rounded,
                  label: 'Speech Engine',
                  value: 'Vosk',
                ),
              ],
            ),
          ],
        ),
      ),
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.lavenderDeep, size: 22),
      title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      trailing: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
