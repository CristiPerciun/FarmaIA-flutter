import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/baganza_effects.dart';

/// A fade + slight-slide page transition (§7.2.5). Used for the product detail
/// route so the shared [Hero] image animates while the rest of the page fades
/// and slides in. Honors `prefers-reduced-motion` (instant transition).
CustomTransitionPage<T> fadeSlidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.of(context).disableAnimations) return child;
      final effects = BaganzaEffects.of(context);
      final curved = CurvedAnimation(
        parent: animation,
        curve: effects.curveEmphasized,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
