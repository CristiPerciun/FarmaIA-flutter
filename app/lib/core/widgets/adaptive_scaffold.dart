import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assistant/application/assistant_panel.dart';
import '../../features/assistant/presentation/widgets/assistant_pill.dart';
import '../../features/assistant/presentation/widgets/assistant_side_panel.dart';
import '../../features/cart/application/cart_providers.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/baganza_effects.dart';
import '../theme/breakpoints.dart';
import 'glass_surface.dart';

/// Wraps a destination icon with the live cart badge on the cart tab.
Widget _tabIcon(AppTab tab, IconData icon, int cartCount, {Color? color}) {
  final iconWidget = Icon(icon, color: color);
  if (tab != AppTab.cart || cartCount <= 0) return iconWidget;
  return Badge(
    label: Text('$cartCount'),
    backgroundColor: AppColors.brandCrimson,
    child: iconWidget,
  );
}

/// The five primary destinations (§7.3). "Servizi" is a Home hero card, not a
/// nav item, to keep the bar at five (§16.7). Chat AI (Fase 4B) and Carrello
/// (Fase 3) route to placeholders until their features land.
enum AppTab {
  home('/'),
  shop('/catalog'),
  chatAi('/assistant'),
  cart('/cart'),
  profile('/profile');

  const AppTab(this.route);
  final String route;

  String label(AppLocalizations l10n) => switch (this) {
    AppTab.home => l10n.navHome,
    AppTab.shop => l10n.navShop,
    AppTab.chatAi => l10n.navChatAi,
    AppTab.cart => l10n.navCart,
    AppTab.profile => l10n.navProfile,
  };

  IconData get icon => switch (this) {
    AppTab.home => Icons.home_outlined,
    AppTab.shop => Icons.storefront_outlined,
    AppTab.chatAi => Icons.chat_bubble_outline,
    AppTab.cart => Icons.shopping_cart_outlined,
    AppTab.profile => Icons.person_outline,
  };

  IconData get selectedIcon => switch (this) {
    AppTab.home => Icons.home,
    AppTab.shop => Icons.storefront,
    AppTab.chatAi => Icons.chat_bubble,
    AppTab.cart => Icons.shopping_cart,
    AppTab.profile => Icons.person,
  };
}

/// One code base, four surfaces (§4.4): a single wrapper that renders a glass
/// bottom bar on `compact` and a glass `NavigationRail` on `expanded`, over the
/// same `go_router` routes. Screens pass their [body]; the shell owns the nav.
///
/// On `expanded` the shell also hosts the assistant 70/30 panel (§12.6, step
/// 4B.5): when open, the content keeps ~70% of the width (min-360 px panel on
/// the right) with a 250–300 ms emphasized animation — instant under
/// `prefers-reduced-motion`. Screens that opt in via [showAssistantPill]
/// (Home, Catalogo) get the floating bottom-center pill.
class AdaptiveScaffold extends ConsumerWidget {
  const AdaptiveScaffold({
    super.key,
    required this.currentTab,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = true,
    this.showAssistantPill = false,
  });

  final AppTab currentTab;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;

  /// Renders the assistant pill bottom-center on `expanded` (§12.6 — only
  /// Home and Catalogo; never on mobile, where the chat is the central tab).
  final bool showAssistantPill;

  void _onSelect(BuildContext context, AppTab tab) {
    if (tab == currentTab) return;
    context.go(tab.route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = Breakpoints.of(context);

    if (size.usesRail) {
      final panelOpen = ref.watch(
        assistantPanelProvider.select((s) => s.isOpen),
      );
      final effects = BaganzaEffects.of(context);
      final reduceMotion = MediaQuery.of(context).disableAnimations;

      return Scaffold(
        appBar: appBar,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            _GlassRail(currentTab: currentTab, onSelect: _onSelect),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 30% of the content area, never below 360 px (§12.6).
                  final panelWidth = math.max(
                    360.0,
                    constraints.maxWidth * 0.30,
                  );
                  return Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(child: body),
                            if (showAssistantPill && !panelOpen)
                              const Positioned(
                                left: 0,
                                right: 0,
                                bottom: 24,
                                child: Center(child: AssistantPill()),
                              ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: reduceMotion
                            ? Duration.zero
                            : effects.durationStandard,
                        curve: effects.curveEmphasized,
                        width: panelOpen ? panelWidth : 0,
                        child: panelOpen
                            ? ClipRect(
                                child: OverflowBox(
                                  alignment: Alignment.topLeft,
                                  minWidth: panelWidth,
                                  maxWidth: panelWidth,
                                  child: const AssistantSidePanel(),
                                ),
                              )
                            : null,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: true,
      floatingActionButton: floatingActionButton,
      body: body,
      bottomNavigationBar: _GlassBottomBar(
        currentTab: currentTab,
        onSelect: _onSelect,
      ),
    );
  }
}

class _GlassBottomBar extends ConsumerWidget {
  const _GlassBottomBar({required this.currentTab, required this.onSelect});

  final AppTab currentTab;
  final void Function(BuildContext, AppTab) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cartCount = ref.watch(cartItemCountProvider);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: GlassSurface(
          radius: 28,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.brandGreen.withValues(alpha: 0.14),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              height: 64,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: currentTab.index,
              onDestinationSelected: (i) => onSelect(context, AppTab.values[i]),
              destinations: [
                for (final tab in AppTab.values)
                  NavigationDestination(
                    icon: _tabIcon(tab, tab.icon, cartCount),
                    selectedIcon: _tabIcon(
                      tab,
                      tab.selectedIcon,
                      cartCount,
                      color: AppColors.brandGreen,
                    ),
                    label: tab.label(l10n),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassRail extends ConsumerWidget {
  const _GlassRail({required this.currentTab, required this.onSelect});

  final AppTab currentTab;
  final void Function(BuildContext, AppTab) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cartCount = ref.watch(cartItemCountProvider);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GlassSurface(
        radius: 24,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - 24,
            ),
            child: IntrinsicHeight(
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                indicatorColor: AppColors.brandGreen.withValues(alpha: 0.14),
                selectedIndex: currentTab.index,
                groupAlignment: -0.85,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: (i) =>
                    onSelect(context, AppTab.values[i]),
                selectedIconTheme: const IconThemeData(
                  color: AppColors.brandGreen,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: AppColors.brandGreenDark,
                  fontWeight: FontWeight.w600,
                ),
                destinations: [
                  for (final tab in AppTab.values)
                    NavigationRailDestination(
                      icon: _tabIcon(tab, tab.icon, cartCount),
                      selectedIcon: _tabIcon(tab, tab.selectedIcon, cartCount),
                      label: Text(tab.label(l10n)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
