import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/baganza_effects.dart';

/// A glassmorphism surface for navigation chrome and overlays (§7.2.3):
/// app/bottom bars, `NavigationRail`, the filter bottom-sheet, dialogs.
///
/// NEVER place posology, contraindications, prices, checkout totals or the
/// ministerial logo behind glass — those go on solid surfaces (§7.2.3).
///
/// When [solidFallback] is true (low-end devices, or reduced-effects contexts)
/// the blur is skipped and the surface renders near-opaque white — the layout
/// is identical, only the effect degrades.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.solidFallback = false,
    this.padding,
    this.radius,
  });

  final Widget child;
  final bool solidFallback;
  final EdgeInsetsGeometry? padding;

  /// Overrides the spec's corner radius when set.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final glass = BaganzaEffects.of(context).glass;
    final r = radius ?? glass.radius;
    final borderRadius = BorderRadius.circular(r);

    final content = Padding(padding: padding ?? EdgeInsets.zero, child: child);

    final border = Border.all(
      color: Colors.white.withValues(alpha: glass.borderOpacity),
      width: 1,
    );

    if (solidFallback) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: glass.solidFallbackOpacity),
          borderRadius: borderRadius,
          border: border,
        ),
        child: content,
      );
    }

    // RepaintBoundary keeps the blur from repainting with the content behind it.
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: glass.blurSigma,
            sigmaY: glass.blurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: glass.fillOpacity),
              borderRadius: borderRadius,
              border: border,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
