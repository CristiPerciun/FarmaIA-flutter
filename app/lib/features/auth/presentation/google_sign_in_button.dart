import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../../core/utils/platform_support.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_providers.dart';

const _log = AppLogger('auth.google');

/// "Continue with Google" button (§1.5). Shared by the login and register
/// screens: first Google sign-in creates the `users/{uid}` profile, later ones
/// reuse it (see [AuthRepository.signInWithGoogle]).
///
/// Hidden where Firebase's federated flow isn't available (desktop/Windows),
/// which keep email/password as the declared fallback (§4.4). On success it
/// honors [from] like the email flow.
class GoogleSignInButton extends HookConsumerWidget {
  const GoogleSignInButton({super.key, this.from, this.onError});

  final String? from;

  /// Reports a localized error to the parent (or `null` to clear it) so the
  /// message shows in the screen's existing error area.
  final ValueChanged<String?>? onError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!PlatformSupport.federatedSignIn) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final isLoading = useState(false);
    final locale = Localizations.localeOf(context).languageCode;

    Future<void> run() async {
      isLoading.value = true;
      onError?.call(null);
      try {
        _log.info('button tapped', {'from': from});
        await ref.read(authRepositoryProvider).signInWithGoogle(locale: locale);
        _log.info('sign-in complete -> ${from ?? '/profile'}');
        if (context.mounted) context.go(from ?? '/profile');
      } on FirebaseAuthException catch (e) {
        if (_isCancellation(e.code)) {
          _log.info('cancelled by user', {'code': e.code});
          return; // user dismissed the popup — silent
        }
        onError?.call(_messageFor(e.code, l10n));
      } catch (e) {
        _log.error('unexpected error', error: e);
        onError?.call(l10n.authErrorGeneric);
      } finally {
        if (context.mounted) isLoading.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l10n.orSeparator,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),
        AppButton(
          label: l10n.continueWithGoogle,
          variant: AppButtonVariant.outlined,
          icon: Icons.g_mobiledata,
          isLoading: isLoading.value,
          onPressed: run,
        ),
      ],
    );
  }
}

/// User-initiated cancellations (closed the popup) — not worth an error message.
bool _isCancellation(String code) =>
    code == 'popup-closed-by-user' ||
    code == 'cancelled-popup-request' ||
    code == 'web-context-canceled' ||
    code == 'user-canceled' ||
    code == 'user-cancelled';

String _messageFor(String code, AppLocalizations l10n) {
  switch (code) {
    case 'account-exists-with-different-credential':
      return l10n.authErrorAccountExists;
    case 'too-many-requests':
      return l10n.authErrorTooManyRequests;
    default:
      return l10n.authErrorGeneric;
  }
}
