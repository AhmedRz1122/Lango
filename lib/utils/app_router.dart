import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/translation_mode.dart';
import '../viewmodels/app_view_model.dart';
import '../viewmodels/translate_view_model.dart';
import '../views/screens/main_shell.dart';
import '../views/widgets/translate_screen.dart';
import 'app_routes.dart';

/// Central navigation helpers for the Lango app.
class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.main: (_) => const MainShell(),
        AppRoutes.translate: (_) => const TranslateScreen(),
        AppRoutes.translateOnline: (_) =>
            const TranslateScreen(forceOnline: true),
        AppRoutes.translateOffline: (_) =>
            const TranslateScreen(forceOffline: true),
      };

  /// Switches to the Translation hub tab (mode picker — not a specific mode).
  static void goToTranslationTab(BuildContext context) {
    context.read<AppViewModel>().setNavIndex(1);
  }

  /// Opens the translate screen with optional voice and mode overrides.
  static Future<void> openTranslate(
    BuildContext context, {
    bool startVoice = false,
    bool forceOnline = false,
    bool forceOffline = false,
  }) {
    if (forceOnline || forceOffline) {
      final appVm = context.read<AppViewModel>();
      final translateVm = context.read<TranslateViewModel>();
      final mode =
          forceOnline ? TranslationMode.online : TranslationMode.offline;
      appVm.setTranslationMode(mode);
      translateVm.setMode(mode);
    }

    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TranslateScreen(
          startVoice: startVoice,
          forceOnline: forceOnline,
          forceOffline: forceOffline,
        ),
      ),
    );
  }

  /// Opens online translation directly.
  static Future<void> openOnlineTranslation(BuildContext context) {
    return openTranslate(context, forceOnline: true);
  }

  /// Opens offline translation directly.
  static Future<void> openOfflineTranslation(BuildContext context) {
    return openTranslate(context, forceOffline: true);
  }
}
