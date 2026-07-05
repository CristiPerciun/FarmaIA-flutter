import 'package:flutter/material.dart';

import '../theme/baganza_effects.dart';

/// Paints the ambient ice-blue → white wash behind [child] (§7.2.2).
///
/// The gradient sits *behind* content by construction: long text should always
/// rest on the white zone or a solid surface. Not invasive, not interactive.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child, this.hero = false});

  final Widget child;

  /// Use the slightly more saturated Home-hero variant.
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final effects = BaganzaEffects.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: hero ? effects.heroGradient : effects.ambientGradient,
      ),
      child: child,
    );
  }
}
