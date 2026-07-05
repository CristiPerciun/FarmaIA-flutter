import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/baganza_effects.dart';

/// Ghost product card with a diagonal shimmer, shown while the grid loads
/// (§7.2.5) — never a full-page spinner. With reduced motion the shimmer is
/// replaced by a static placeholder.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final effects = BaganzaEffects.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    const base = Color(0xFFEFF3F0);

    Widget block(double height, {double? width, double radius = 8}) =>
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(effects.cardRadius),
        boxShadow: effects.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: block(0, radius: 0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                block(12, width: double.infinity),
                const SizedBox(height: 8),
                block(12, width: 90),
                const SizedBox(height: 14),
                block(18, width: 70),
              ],
            ),
          ),
        ],
      ),
    );

    if (reduceMotion) return card;
    return card
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.55),
          angle: 0.5,
        );
  }
}

/// Convenience: a wash color for skeleton blocks, exported for reuse.
const skeletonBase = AppColors.surface;
