import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/cookie_consent_provider.dart';

/// A non-invasive cookie consent banner (§1.4) shown at the bottom until the
/// user decides. Mounted app-wide via the MaterialApp builder so it overlays
/// every route. Collapses to nothing once a choice is stored.
class CookieBanner extends ConsumerWidget {
  const CookieBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decision = ref.watch(cookieConsentProvider);
    if (decision != null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(cookieConsentProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cookieBannerTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.cookieBannerBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: notifier.rejectNonEssential,
                      child: Text(l10n.cookieReject),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      label: l10n.cookieAccept,
                      onPressed: notifier.acceptAll,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
