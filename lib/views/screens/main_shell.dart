import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/app_view_model.dart';
import '../widgets/glass_nav_bar.dart';
import 'about_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'translation_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _screens = [
    HomeScreen(),
    TranslationScreen(),
    HistoryScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navIndex = context.watch<AppViewModel>().currentNavIndex;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: IndexedStack(
        index: navIndex,
        children: _screens,
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: navIndex,
        onTap: (i) => context.read<AppViewModel>().setNavIndex(i),
      ),
    );
  }
}
