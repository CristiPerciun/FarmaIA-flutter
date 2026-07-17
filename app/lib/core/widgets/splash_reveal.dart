import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Step 6.3 (§16.3) — il reveal animato in-app, "Strada B": raster ufficiale
/// (`emblem_raster.png` + `wordmark_raster.png`) animato con un anello d'oro
/// vettoriale che si disegna come apertura.
///
/// Coreografia (una sola volta per avvio, MAI in loop, totale ~1,75 s ≤ 1,8 s):
///   0–500 ms   l'anello d'oro si disegna (stroke 0→100%)
/// 300–850 ms   l'emblema entra in fade + scale (l'anello dipinto sfuma)
/// 800–1200 ms  il wordmark "BAGANZA / FARMACIE" sale in fade
/// 1150–1550 ms micro-luccichio dorato (shimmer) di chiusura
/// 1550–1750 ms l'overlay sfuma e cede il passo alla Home
///
/// Lo splash NASCONDE il tempo di avvio, non lo allunga: Firebase è già
/// inizializzato prima di `runApp` (main.dart), quindi sotto l'overlay la Home
/// è pronta e l'hand-off avviene a fine coreografia. Con
/// `MediaQuery.disableAnimations` la coreografia è saltata (breve logo statico).
///
/// [onReady] è chiamato al primo frame dell'overlay: main.dart vi aggancia
/// `FlutterNativeSplash.remove` così lo splash nativo (stesso bianco + stesso
/// emblema) cede il passo senza "doppio splash" né flicker.
class SplashReveal extends StatefulWidget {
  const SplashReveal({super.key, this.onReady, this.enabled = true});

  /// Chiamato dopo il primo frame (rimozione dello splash nativo).
  final VoidCallback? onReady;

  /// Consente di spegnere il reveal (es. nei widget test dell'app completa).
  final bool enabled;

  /// Il reveal gira solo al primo avvio del processo: i rebuild successivi
  /// (cambio lingua, hot reload) non lo ripropongono.
  static bool _playedThisLaunch = false;

  @visibleForTesting
  static void resetForTesting() => _playedThisLaunch = false;

  @override
  State<SplashReveal> createState() => _SplashRevealState();
}

class _SplashRevealState extends State<SplashReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _skipped = false;
  bool _done = false;

  static const _total = Duration(milliseconds: 1750);
  static const _reducedHold = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    if (SplashReveal._playedThisLaunch || !widget.enabled) {
      _skipped = true;
      _done = true;
    }
    SplashReveal._playedThisLaunch = true;

    _controller = AnimationController(vsync: this, duration: _total);
    if (!_skipped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onReady?.call();
        final reduceMotion = MediaQuery.of(context).disableAnimations;
        if (reduceMotion) {
          // Niente coreografia: logo statico brevissimo, poi la Home.
          Future<void>.delayed(_reducedHold, _finish);
        } else {
          _controller.forward().whenComplete(_finish);
        }
      });
    }
  }

  void _finish() {
    if (!mounted) return;
    setState(() => _done = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Progress [0..1] nella finestra [begin]–[end] della coreografia.
  double _phase(double t, double begin, double end, [Curve curve = Curves.easeOutCubic]) {
    final raw = ((t - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve.transform(raw);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = reduceMotion ? 1.0 : _controller.value;

        final ringSweep = _phase(t, 0.0, 0.285); // 0–500 ms
        final ringFade = 1.0 - _phase(t, 0.285, 0.515, Curves.easeIn);
        final emblemIn = _phase(t, 0.17, 0.485); // 300–850 ms
        final wordmarkIn = _phase(t, 0.455, 0.685); // 800–1200 ms
        final shimmer = _phase(t, 0.655, 0.885, Curves.easeInOut); // 1150–1550
        final fadeOut = 1.0 - _phase(t, 0.885, 1.0, Curves.easeIn); // 1550–1750

        return Opacity(
          opacity: fadeOut,
          child: Material(
            color: AppColors.background,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final emblemSize = math.min(
                    math.min(constraints.maxWidth * 0.58,
                        constraints.maxHeight * 0.42),
                    340.0,
                  );
                  return _ShimmerSweep(
                    progress: shimmer,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: emblemSize * 1.14,
                          height: emblemSize * 1.14,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // L'anello vettoriale che "si disegna" (§16.3),
                              // leggermente più ampio dell'emblema raster.
                              if (ringFade > 0)
                                Opacity(
                                  opacity: ringFade,
                                  child: CustomPaint(
                                    size: Size.square(emblemSize * 1.14),
                                    painter: _RingPainter(sweep: ringSweep),
                                  ),
                                ),
                              Opacity(
                                opacity: emblemIn,
                                child: Transform.scale(
                                  scale: 0.92 + 0.08 * emblemIn,
                                  child: Image.asset(
                                    'assets/images/emblem_raster.png',
                                    width: emblemSize,
                                    height: emblemSize,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Opacity(
                          opacity: wordmarkIn,
                          child: Transform.translate(
                            offset: Offset(0, 14 * (1 - wordmarkIn)),
                            child: Image.asset(
                              'assets/images/wordmark_raster.png',
                              width: emblemSize * 0.82,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Disegna l'arco dell'anello d'oro da 0 a [sweep]·360°, partendo dall'alto.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.sweep});

  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    if (sweep <= 0) return;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          AppColors.brandGoldLight,
          AppColors.brandGold,
          AppColors.brandGoldDark,
          AppColors.brandGoldLight,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.sweep != sweep;
}

/// Luccichio dorato di chiusura: una banda diagonale chiara che attraversa il
/// logo una sola volta (progress 0→1), poi scompare.
class _ShimmerSweep extends StatelessWidget {
  const _ShimmerSweep({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) return child;
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final dx = bounds.width * (2 * progress - 1) * 1.6;
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.transparent,
            AppColors.brandGoldLight.withValues(alpha: 0.45),
            Colors.transparent,
          ],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlideGradient(dx),
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.dx);

  final double dx;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}
