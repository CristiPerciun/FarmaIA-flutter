import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';

/// Right-of-withdrawal button (art. 54-bis, §1.4/§16.8). Shows a confirmation
/// dialog, then invokes [onConfirmed] so the caller records a **tracked**
/// request (e.g. sets `orders.recessoRequested = true` with a timestamp in
/// Fase 3). Reusable now so the compliance flow exists ahead of orders.
class WithdrawalButton extends StatelessWidget {
  const WithdrawalButton({
    super.key,
    required this.onConfirmed,
    this.alreadyRequested = false,
  });

  final Future<void> Function() onConfirmed;
  final bool alreadyRequested;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (alreadyRequested) {
      return Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.withdrawalRequested)),
        ],
      );
    }

    return AppButton(
      label: l10n.withdrawalButton,
      variant: AppButtonVariant.outlined,
      icon: Icons.assignment_return_outlined,
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.withdrawalButton),
            content: Text(l10n.withdrawalConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.withdrawalConfirm),
              ),
            ],
          ),
        );
        if (confirmed ?? false) await onConfirmed();
      },
    );
  }
}
