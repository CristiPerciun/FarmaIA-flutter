import 'package:flutter/material.dart';

import '../theme/baganza_effects.dart';

/// A product-card surface with measured 3D depth (§7.2.4).
///
/// - **Desktop (hover):** perspective tilt that follows the pointer, capped at
///   [maxTiltDegrees] (6°), plus a soft radial sheen tracking the cursor.
/// - **Touch:** no tilt — a press scales to 0.97 with a spring settle.
/// - **`prefers-reduced-motion`:** tilt and sheen are disabled; press is a
///   plain (near-instant) scale so the affordance survives without motion.
///
/// The tilt is purely perceptual: hit-area and semantics are unchanged.
class TiltCard extends StatefulWidget {
  const TiltCard({
    super.key,
    required this.child,
    this.onTap,
    this.maxTiltDegrees = 6,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double maxTiltDegrees;
  final String? semanticLabel;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  Offset? _hoverFraction; // -0.5..0.5 on each axis, null when not hovering.
  bool _pressed = false;

  void _onHover(PointerEvent e, Size size) {
    if (size.isEmpty) return;
    setState(() {
      _hoverFraction = Offset(
        (e.localPosition.dx / size.width) - 0.5,
        (e.localPosition.dy / size.height) - 0.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final effects = BaganzaEffects.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final tiltActive = !reduceMotion && _hoverFraction != null;
    final frac = _hoverFraction ?? Offset.zero;

    final radians = widget.maxTiltDegrees * 3.1415926535 / 180;
    final matrix = Matrix4.identity()..setEntry(3, 2, 0.0015);
    if (tiltActive) {
      // Rotate opposite to the pointer offset for a natural "look-at" tilt.
      matrix.rotateX(-frac.dy * radians);
      matrix.rotateY(frac.dx * radians);
    }

    final scale = _pressed ? 0.97 : 1.0;

    Widget card = AnimatedScale(
      scale: scale,
      duration: reduceMotion ? Duration.zero : effects.durationFast,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : effects.durationFast,
        curve: Curves.easeOut,
        transform: matrix,
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(effects.cardRadius),
          boxShadow: effects.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            widget.child,
            // Cursor-following sheen (desktop only).
            if (tiltActive)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(frac.dx * 2, frac.dy * 2),
                        radius: 0.9,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    card = MouseRegion(
      onHover: (e) => _onHover(e, context.size ?? Size.zero),
      onExit: (_) => setState(() => _hoverFraction = null),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: card,
      ),
    );

    if (widget.semanticLabel != null) {
      card = Semantics(
        label: widget.semanticLabel,
        button: widget.onTap != null,
        child: card,
      );
    }
    return card;
  }
}
