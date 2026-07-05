import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';

/// Shown after a successful order (§3.4). The order itself is created and paid
/// server-side; this just confirms and routes to the orders area.
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: AmbientBackground(
        hero: true,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 88,
                    color: AppColors.brandGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.orderPlacedTitle,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.orderPlacedBody(orderNumber),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      minimumSize: const Size(220, 52),
                    ),
                    onPressed: () => context.go('/orders'),
                    child: Text(l10n.ordersTitle),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: Text(l10n.navToHome),
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
