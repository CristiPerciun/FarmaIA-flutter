import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/assistant_consent.dart';

/// First-run onboarding (§12.6, step 4B.6): what the assistant does / does
/// not do, plus the explicit art. 9 consent (§12.5) before the first message.
///
/// Accept: signed-in users get the durable `consents.aiAssistant` on their
/// profile ("il consenso non viene richiesto di nuovo"); guests get a
/// session-only consent, sent with each request. Decline: the page stays
/// usable in "results-only" mode — search is never hostage to consent.
class AssistantOnboarding extends ConsumerStatefulWidget {
  const AssistantOnboarding({super.key});

  @override
  ConsumerState<AssistantOnboarding> createState() =>
      _AssistantOnboardingState();
}

class _AssistantOnboardingState extends ConsumerState<AssistantOnboarding> {
  bool _saving = false;

  Future<void> _accept() async {
    setState(() => _saving = true);
    // Immediate effect for this session (also covers guests).
    ref.read(sessionAiConsentProvider.notifier).grant();
    final user = ref.read(appUserProvider).valueOrNull;
    if (user != null) {
      try {
        await ref
            .read(authRepositoryProvider)
            .updateConsents(
              marketing: user.consents.marketing,
              medicineDataProcessing: user.consents.medicineDataProcessing,
              aiAssistant: true,
            );
      } catch (_) {
        // Session consent already granted; the profile write can retry from
        // the consents screen. Never block the chat on this.
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  void _decline() => ref.read(sessionAiConsentProvider.notifier).decline();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.ambientAzureHero,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: AppColors.brandGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  l10n.assistantOnboardingTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.brandGreenDark,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              _Point(icon: Icons.check_circle, text: l10n.assistantDoes1),
              _Point(icon: Icons.check_circle, text: l10n.assistantDoes2),
              _Point(icon: Icons.check_circle, text: l10n.assistantDoes3),
              const SizedBox(height: 8),
              _Point(
                icon: Icons.cancel,
                color: AppColors.brandCrimson,
                text: l10n.assistantDoesnt1,
              ),
              _Point(
                icon: Icons.cancel,
                color: AppColors.brandCrimson,
                text: l10n.assistantDoesnt2,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.assistantConsentTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.assistantConsentBody, style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _accept,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.assistantConsentAccept),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _saving ? null : _decline,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.assistantConsentDecline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({
    required this.icon,
    required this.text,
    this.color = AppColors.brandGreen,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
