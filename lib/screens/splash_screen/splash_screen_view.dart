import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/screens/splash_screen/splash_controller.dart';
import 'package:untitled/utilities/const.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _taglineCtrl;
  late AnimationController _particleCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowRadius;
  late Animation<double> _taglineOpacity;
  late Animation<double> _taglineSlide;

  @override
  void initState() {
    super.initState();
    Get.put(SplashController());

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _taglineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );
    _glowRadius = Tween<double>(begin: 20, end: 55).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn),
    );
    _taglineSlide = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut),
    );

    _logoCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () => _taglineCtrl.forward());
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _glowCtrl.dispose();
    _taglineCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fBG,
      body: Stack(
        children: [
          // Subtle radial background glow
          Center(
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) => Container(
                width: Get.width * 0.85,
                height: Get.width * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      fGradEnd.withValues(alpha: 0.07 + 0.04 * _glowCtrl.value),
                      fGradStart.withValues(alpha: 0.04 + 0.02 * _glowCtrl.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating particles
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              size: Size(Get.width, Get.height),
              painter: _ParticlePainter(_particleCtrl.value),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with glow
                AnimatedBuilder(
                  animation: Listenable.merge([_logoCtrl, _glowCtrl]),
                  builder: (_, __) => Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: fGradEnd.withValues(alpha: 0.35 + 0.15 * _glowCtrl.value),
                              blurRadius: _glowRadius.value,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: fGradStart.withValues(alpha: 0.2 + 0.1 * _glowCtrl.value),
                              blurRadius: _glowRadius.value * 2,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => flayrGradient.createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: const Text(
                            'FLAYR',
                            style: TextStyle(
                              fontFamily: 'gilroy_extrabold',
                              fontSize: 68,
                              letterSpacing: 6,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tagline
                AnimatedBuilder(
                  animation: _taglineCtrl,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _taglineSlide.value),
                    child: Opacity(
                      opacity: _taglineOpacity.value.clamp(0.0, 1.0),
                      child: const Text(
                        'Show your flayr',
                        style: TextStyle(
                          fontFamily: 'gilroy_light',
                          fontSize: 15,
                          color: fTextSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  static final _rng = Random(42);
  static final List<_Particle> _particles = List.generate(
    18,
    (i) => _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: 1.5 + _rng.nextDouble() * 2.5,
      speed: 0.15 + _rng.nextDouble() * 0.35,
      phase: _rng.nextDouble(),
      color: i % 3 == 0 ? fGradStart : i % 3 == 1 ? fGradMid : fGradEnd,
    ),
  );

  const _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final dy = (p.y - t * 0.6) % 1.0;
      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - t) * 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        Offset(p.x * size.width, dy * size.height),
        p.size * (1 - t * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, y, size, speed, phase;
  final Color color;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });
}
