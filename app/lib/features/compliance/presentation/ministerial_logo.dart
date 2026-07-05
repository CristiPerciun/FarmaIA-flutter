import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// The national identifying logo slot required on **medicine** pages for online
/// sale (§16.8). It renders only for medicines; for anything else it collapses
/// to nothing, enforcing that the logo never appears on non-medicine pages.
///
/// The real logo artwork + verification link are enabled once the Ministry of
/// Health authorization is confirmed (§16.8/§16.9). Until then this shows a
/// clearly-labelled placeholder so the *slot* and its rules exist end-to-end
/// without implying an authorization the pharmacy may not yet hold.
class MinisterialLogo extends StatelessWidget {
  const MinisterialLogo({
    super.key,
    required this.isMedicine,
    this.verificationUrl,
    this.authorized = false,
  });

  /// Only medicines (SOP/OTC) carry the logo (§9.2).
  final bool isMedicine;

  /// Ministry verification page for this pharmacy (shown once authorized).
  final String? verificationUrl;

  /// Flips from placeholder to the real authorized badge (§16.8).
  final bool authorized;

  @override
  Widget build(BuildContext context) {
    if (!isMedicine) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.ministerialLogoSemantics,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: authorized ? AppColors.brandGreen : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              authorized ? Icons.verified_user : Icons.pending_outlined,
              color: authorized
                  ? AppColors.brandGreen
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ministerialLogoTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    authorized
                        ? l10n.ministerialLogoAuthorized
                        : l10n.ministerialLogoPending,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
