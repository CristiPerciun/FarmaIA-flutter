import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_providers.dart';

/// Account registration (§1.3). Creates the Firebase user and the
/// `users/{uid}` profile with `role: customer` (§5.5).
class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final name = useTextEditingController();
    final email = useTextEditingController();
    final password = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isLoading = useState(false);
    final error = useState<String?>(null);

    final locale = Localizations.localeOf(context).languageCode;

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      isLoading.value = true;
      error.value = null;
      try {
        await ref
            .read(authRepositoryProvider)
            .register(
              email: email.text,
              password: password.text,
              displayName: name.text,
              locale: locale,
            );
        if (context.mounted) context.go('/profile');
      } on FirebaseAuthException catch (e) {
        error.value = _messageFor(e.code, l10n);
      } catch (_) {
        error.value = l10n.authErrorGeneric;
      } finally {
        if (context.mounted) isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
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
                  AppTextField(label: l10n.displayNameLabel, controller: name),
                  const SizedBox(height: 16),
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
                    validator: (v) => (v == null || v.length < 6)
                        ? l10n.passwordTooShort
                        : null,
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
                    label: l10n.createAccount,
                    isLoading: isLoading.value,
                    onPressed: submit,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: l10n.alreadyHaveAccount,
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.go('/login'),
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
    case 'email-already-in-use':
      return l10n.authErrorEmailInUse;
    case 'weak-password':
      return l10n.passwordTooShort;
    case 'invalid-email':
      return l10n.invalidEmail;
    default:
      return l10n.authErrorGeneric;
  }
}
