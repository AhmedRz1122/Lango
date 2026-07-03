import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 120,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppConstants.appLogo,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.translate_rounded,
        size: size * 0.6,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
