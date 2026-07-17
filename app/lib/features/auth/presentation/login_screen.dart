import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_providers.dart';
import 'google_sign_in_button.dart';

const _log = AppLogger('auth.login');

/// Email/password sign-in (§1.3). On success it honors the `from` query param
/// so the user returns to the page that triggered the login (session-expiry
/// context preservation, §9.2).
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key, this.from});

  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final email = useTextEditingController();
    final password = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isLoading = useState(false);
    final error = useState<String?>(null);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      isLoading.value = true;
      error.value = null;
      try {
        await ref
            .read(authRepositoryProvider)
            .signIn(email: email.text, password: password.text);
        _log.info('login success -> ${from ?? '/profile'}');
        if (context.mounted) context.go(from ?? '/profile');
      } on FirebaseAuthException catch (e) {
        error.value = _messageFor(e.code, l10n);
      } catch (e) {
        _log.error('login unexpected error', error: e);
        error.value = l10n.authErrorGeneric;
      } finally {
        if (context.mounted) isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signIn)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: l10n.emailLabel,
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => _validateEmail(v, l10n),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: l10n.passwordLabel,
                    controller: password,
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l10n.fieldRequired : null,
                  ),
                  if (error.value != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      error.value!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    label: l10n.signIn,
                    isLoading: isLoading.value,
                    onPressed: submit,
                  ),
                  GoogleSignInButton(
                    from: from,
                    onError: (m) => error.value = m,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: l10n.createAccount,
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.go('/register'),
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

String? _validateEmail(String? value, AppLocalizations l10n) {
  if (value == null || value.trim().isEmpty) return l10n.fieldRequired;
  if (!value.contains('@') || !value.contains('.')) return l10n.invalidEmail;
  return null;
}

String _messageFor(String code, AppLocalizations l10n) {
  switch (code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return l10n.authErrorInvalidCredentials;
    case 'too-many-requests':
      return l10n.authErrorTooManyRequests;
    default:
      return l10n.authErrorGeneric;
  }
}
