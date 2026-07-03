import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../viewmodels/app_view_model.dart';
import '../viewmodels/translate_view_model.dart';
import 'views/screens/main_shell.dart';
import 'views/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LangoApp());
}

class LangoApp extends StatelessWidget {
  const LangoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => TranslateViewModel()..initialize()),
      ],
      child: MaterialApp(
        title: 'Lango',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AppEntry(),
      ),
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    final appVm = context.watch<AppViewModel>();

    if (!appVm.hasSeenOnboarding) {
      return const SplashScreen();
    }
    return const MainShell();
  }
}
