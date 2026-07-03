import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color cream = Color(0xFFFFF8F0);
  static const Color creamLight = Color(0xFFFFFDF9);
  static const Color lavender = Color(0xFFB8A9E8);
  static const Color lavenderDeep = Color(0xFF9B8AD4);
  static const Color lavenderLight = Color(0xFFE8E0F8);
  static const Color mint = Color(0xFF7ED4B8);
  static const Color mintLight = Color(0xFFD4F5EA);
  static const Color mintDeep = Color(0xFF5BC4A0);
  static const Color softYellow = Color(0xFFFFF3C4);
  static const Color softOrange = Color(0xFFFFE4B5);
  static const Color softPink = Color(0xFFFFD6E0);
  static const Color coral = Color(0xFFFFB4A2);
  static const Color navy = Color(0xFF1A1A2E);
  static const Color navyButton = Color(0xFF2D2D44);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color white = Color(0xFFFFFFFF);
  static const Color glassWhite = Color(0xCCFFFFFF);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [softYellow, cream, lavenderLight],
    stops: [0.0, 0.4, 1.0],
  );

  static const LinearGradient voiceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lavenderDeep, Color(0xFF7B6BB5)],
  );
}
