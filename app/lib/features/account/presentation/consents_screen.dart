import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_providers.dart';

/// GDPR consent management (§1.4, §12.5). Each consent is opt-in and revocable;
/// the AI-assistant consent is the explicit Art. 9 consent for health data
/// typed into the chat. Saving writes only the `consents` map (role untouched,
/// §5.5).
class ConsentsScreen extends HookConsumerWidget {
  const ConsentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appUser = ref.watch(appUserProvider).valueOrNull;
    final consents = appUser?.consents;

    final marketing = useState(consents?.marketing ?? false);
    final medicineData = useState(consents?.medicineDataProcessing ?? false);
    final aiAssistant = useState(consents?.aiAssistant ?? false);
    final isSaving = useState(false);

    // Sync local toggles once the profile document loads.
    useEffect(() {
      if (consents != null) {
        marketing.value = consents.marketing;
        medicineData.value = consents.medicineDataProcessing;
        aiAssistant.value = consents.aiAssistant;
      }
      return null;
    }, [consents]);

    Future<void> save() async {
      isSaving.value = true;
      try {
        await ref
            .read(authRepositoryProvider)
            .updateConsents(
              marketing: marketing.value,
              medicineDataProcessing: medicineData.value,
              aiAssistant: aiAssistant.value,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.consentsSaved)));
        }
      } finally {
        if (context.mounted) isSaving.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.consentsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.consentsIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: marketing.value,
            onChanged: (v) => marketing.value = v,
            title: Text(l10n.consentMarketingTitle),
            subtitle: Text(l10n.consentMarketingBody),
          ),
          SwitchListTile(
            value: medicineData.value,
            onChanged: (v) => medicineData.value = v,
            title: Text(l10n.consentMedicineDataTitle),
            subtitle: Text(l10n.consentMedicineDataBody),
          ),
          SwitchListTile(
            value: aiAssistant.value,
            onChanged: (v) => aiAssistant.value = v,
            title: Text(l10n.consentAiAssistantTitle),
            subtitle: Text(l10n.consentAiAssistantBody),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: l10n.saveConsents,
            isLoading: isSaving.value,
            onPressed: save,
          ),
        ],
      ),
    );
  }
}
