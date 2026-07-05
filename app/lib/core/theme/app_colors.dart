import 'package:flutter/material.dart';

/// Baganza Farmacie brand palette (§16.2).
///
/// Gold is decorative only — never use for readable text or primary actions.
abstract final class AppColors {
  static const Color brandGold = Color(0xFFC9A227);
  static const Color brandGoldLight = Color(0xFFE6C76A);
  static const Color brandGoldDark = Color(0xFF8A6D1B);

  /// Primary action color — good contrast on white (~4.6:1).
  static const Color brandGreen = Color(0xFF1E7A3C);

  /// Text and headings — high contrast on white (~9.5:1).
  static const Color brandGreenDark = Color(0xFF14532D);

  /// Prestige accent — use sparingly; not for errors.
  static const Color brandCrimson = Color(0xFF9E1B32);

  /// Dedicated error/urgency color (distinct from brand crimson).
  static const Color alert = Color(0xFFC62828);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAF8);
  static const Color textPrimary = Color(0xFF14532D);
  static const Color textSecondary = Color(0xFF1F2A24);
  static const Color border = Color(0xFFE0E8E2);

  /// Ambient background wash — cold ice-blue that fades into white (§7.2.2).
  /// NEVER used for text or interactive elements: it is purely atmospheric and
  /// keeps green as the single interactive color.
  static const Color ambientAzure = Color(0xFFEAF4FE);

  /// Slightly more saturated ambient tone, reserved for the Home hero (§7.2.2).
  static const Color ambientAzureHero = Color(0xFFDDEEFC);
}
