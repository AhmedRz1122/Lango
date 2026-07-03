import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/app_view_model.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decorative elements
              Positioned(
                top: 60,
                left: -30,
                child: _FaintBubble(
                  color: AppColors.lavender.withValues(alpha: 0.15),
                  size: 120,
                  child: Text(
                    'A',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: AppColors.lavender.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                right: 20,
                child: Icon(
                  Icons.location_on_outlined,
                  size: 28,
                  color: AppColors.lavender.withValues(alpha: 0.25),
                ),
              ),
              Positioned(
                bottom: 280,
                left: 30,
                child: _PaperPlane(controller: _controller),
              ),
              Positioned(
                bottom: 200,
                right: -20,
                child: _FaintBubble(
                  color: AppColors.mint.withValues(alpha: 0.12),
                  size: 100,
                  child: Text(
                    '文',
                    style: GoogleFonts.notoSans(
                      fontSize: 40,
                      color: AppColors.mint.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  const Spacer(flex: 2),
                  _AnimatedLogo(controller: _controller),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: AppConstants.taglinePart1),
                          TextSpan(
                            text: AppConstants.taglineHighlight1,
                            style: const TextStyle(
                              color: AppColors.lavenderDeep,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: AppConstants.taglinePart2),
                          TextSpan(
                            text: AppConstants.taglineHighlight2,
                            style: const TextStyle(
                              color: AppColors.mintDeep,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  _PageIndicator(currentPage: _currentPage),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _GetStartedButton(
                      onPressed: () {
                        context.read<AppViewModel>().completeOnboarding();
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedLogo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final float = math.sin(controller.value * 2 * math.pi) * 6;
        return Transform.translate(
          offset: Offset(0, float),
          child: child,
        );
      },
      child: const AppLogo(size: 220),
    );
  }
}

class _FaintBubble extends StatelessWidget {
  final Color color;
  final double size;
  final Widget child;

  const _FaintBubble({
    required this.color,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}

class _PaperPlane extends StatelessWidget {
  final AnimationController controller;
  const _PaperPlane({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final offset = controller.value * 20;
        return Transform.translate(
          offset: Offset(offset, -offset * 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPaint(
                size: const Size(60, 30),
                painter: _DottedTrailPainter(
                  progress: controller.value,
                ),
              ),
              Transform.rotate(
                angle: -0.3,
                child: Icon(
                  Icons.send_rounded,
                  color: AppColors.lavenderDeep.withValues(alpha: 0.6),
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DottedTrailPainter extends CustomPainter {
  final double progress;
  _DottedTrailPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lavenderDeep.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      0,
    );

    for (var i = 0; i < 8; i++) {
      final t = (i / 8.0 + progress) % 1.0;
      final metric = path.computeMetrics().first;
      final pos = metric.getTangentForOffset(metric.length * t);
      if (pos != null) {
        canvas.drawCircle(pos.position, 2, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedTrailPainter old) =>
      old.progress != progress;
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  const _PageIndicator({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.lavenderDeep
                : AppColors.lavender.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GetStartedButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 4,
          shadowColor: AppColors.navy.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Started',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
