import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Specification for a glassmorphism surface (§7.2.3).
@immutable
class GlassSpec {
  const GlassSpec({
    required this.blurSigma,
    required this.fillOpacity,
    required this.borderOpacity,
    required this.radius,
    required this.solidFallbackOpacity,
  });

  /// `BackdropFilter` blur σ (20–24, §7.2.3).
  final double blurSigma;

  /// White fill opacity over the blur (0.70–0.75).
  final double fillOpacity;

  /// 1 px white border opacity (~0.45).
  final double borderOpacity;

  /// Corner radius (20–24).
  final double radius;

  /// White fill opacity when blur is skipped (low-end / reduced effects).
  final double solidFallbackOpacity;

  GlassSpec lerpTo(GlassSpec other, double t) => GlassSpec(
    blurSigma: lerpDouble(blurSigma, other.blurSigma, t),
    fillOpacity: lerpDouble(fillOpacity, other.fillOpacity, t),
    borderOpacity: lerpDouble(borderOpacity, other.borderOpacity, t),
    radius: lerpDouble(radius, other.radius, t),
    solidFallbackOpacity: lerpDouble(
      solidFallbackOpacity,
      other.solidFallbackOpacity,
      t,
    ),
  );
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;

/// Design tokens for the §7.2 visual language, exposed as a [ThemeExtension] so
/// features never hardcode gradient stops, blur sigmas, shadow specs or motion
/// timings. The same values are mirrored to CSS custom properties for the SSR
/// storefront (§7.2.6, `core/theme/tokens.json`).
@immutable
class BaganzaEffects extends ThemeExtension<BaganzaEffects> {
  const BaganzaEffects({
    required this.ambientGradient,
    required this.heroGradient,
    required this.glass,
    required this.cardShadow,
    required this.durationFast,
    required this.durationStandard,
    required this.durationPage,
    required this.curveArrive,
    required this.curveEmphasized,
    required this.cardRadius,
  });

  /// Vertical ice-blue → white wash for section headers and empty states.
  final LinearGradient ambientGradient;

  /// Slightly more saturated variant for the Home hero.
  final LinearGradient heroGradient;

  final GlassSpec glass;

  /// Two-layer product-card shadow: soft ambient + directional green-tinted
  /// (§7.2.4). Colored shadows are what make the depth read as "modern".
  final List<BoxShadow> cardShadow;

  /// Micro-interactions 150–200 ms (§7.2.5).
  final Duration durationFast;

  /// Standard transitions 250–300 ms.
  final Duration durationStandard;

  /// Page / layout transitions 400–500 ms.
  final Duration durationPage;

  /// Spring-like "arrive" curve for elements that enter.
  final Curve curveArrive;

  /// Material 3 emphasized curve for layout changes.
  final Curve curveEmphasized;

  final double cardRadius;

  /// The canonical brand instance.
  static const BaganzaEffects standard = BaganzaEffects(
    ambientGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.62],
      colors: [AppColors.ambientAzure, AppColors.background],
    ),
    heroGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.7],
      colors: [AppColors.ambientAzureHero, AppColors.background],
    ),
    glass: GlassSpec(
      blurSigma: 22,
      fillOpacity: 0.72,
      borderOpacity: 0.45,
      radius: 22,
      solidFallbackOpacity: 0.96,
    ),
    cardShadow: [
      // Ambient layer.
      BoxShadow(
        color: Color(0x0D000000), // black 5%
        offset: Offset(0, 2),
        blurRadius: 8,
      ),
      // Directional layer with a green tint (§7.2.4).
      BoxShadow(
        color: Color(0x1A1E7A3C), // brandGreen 10%
        offset: Offset(0, 12),
        blurRadius: 24,
      ),
    ],
    durationFast: Duration(milliseconds: 180),
    durationStandard: Duration(milliseconds: 280),
    durationPage: Duration(milliseconds: 450),
    curveArrive: Curves.easeOutBack,
    curveEmphasized: Curves.easeInOutCubicEmphasized,
    cardRadius: 22,
  );

  @override
  BaganzaEffects copyWith({
    LinearGradient? ambientGradient,
    LinearGradient? heroGradient,
    GlassSpec? glass,
    List<BoxShadow>? cardShadow,
    Duration? durationFast,
    Duration? durationStandard,
    Duration? durationPage,
    Curve? curveArrive,
    Curve? curveEmphasized,
    double? cardRadius,
  }) => BaganzaEffects(
    ambientGradient: ambientGradient ?? this.ambientGradient,
    heroGradient: heroGradient ?? this.heroGradient,
    glass: glass ?? this.glass,
    cardShadow: cardShadow ?? this.cardShadow,
    durationFast: durationFast ?? this.durationFast,
    durationStandard: durationStandard ?? this.durationStandard,
    durationPage: durationPage ?? this.durationPage,
    curveArrive: curveArrive ?? this.curveArrive,
    curveEmphasized: curveEmphasized ?? this.curveEmphasized,
    cardRadius: cardRadius ?? this.cardRadius,
  );

  @override
  BaganzaEffects lerp(covariant BaganzaEffects? other, double t) {
    if (other == null) return this;
    return BaganzaEffects(
      ambientGradient: LinearGradient.lerp(
        ambientGradient,
        other.ambientGradient,
        t,
      )!,
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
      glass: glass.lerpTo(other.glass, t),
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t)!,
      durationFast: t < 0.5 ? durationFast : other.durationFast,
      durationStandard: t < 0.5 ? durationStandard : other.durationStandard,
      durationPage: t < 0.5 ? durationPage : other.durationPage,
      curveArrive: t < 0.5 ? curveArrive : other.curveArrive,
      curveEmphasized: t < 0.5 ? curveEmphasized : other.curveEmphasized,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t),
    );
  }

  /// Convenience accessor: `Theme.of(context).baganzaEffects`.
  static BaganzaEffects of(BuildContext context) =>
      Theme.of(context).extension<BaganzaEffects>() ?? standard;
}

extension BaganzaEffectsThemeX on ThemeData {
  BaganzaEffects get baganzaEffects =>
      extension<BaganzaEffects>() ?? BaganzaEffects.standard;
}
