import 'package:flutter/widgets.dart';

/// Adaptive breakpoints — one code base, four surfaces (§4.4).
///
/// Aligned to Material 3 window size classes. Features must read these tokens
/// instead of hardcoding pixel widths, so the shell (bottom bar ↔ rail) and the
/// grids stay consistent across mobile PWA, desktop portal and Windows.
enum WindowSize { compact, medium, expanded }

abstract final class Breakpoints {
  /// `compact` < 600 · `medium` 600–1024 · `expanded` ≥ 1024 (§4.4).
  static const double medium = 600;
  static const double expanded = 1024;

  static WindowSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  static WindowSize fromWidth(double width) {
    if (width >= expanded) return WindowSize.expanded;
    if (width >= medium) return WindowSize.medium;
    return WindowSize.compact;
  }
}

extension WindowSizeX on WindowSize {
  bool get isCompact => this == WindowSize.compact;
  bool get isExpanded => this == WindowSize.expanded;

  /// Desktop-class layout (rail/menu, side filter panel, hover affordances).
  bool get usesRail => this == WindowSize.expanded;
}
