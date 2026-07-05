import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/demo_counter_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final counter = ref.watch(demoCounterProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: l10n.profileTitle,
            onPressed: () => context.go('/profile'),
          ),
          _LanguageToggle(
            locale: locale,
            onToggle: () => ref.read(localeProvider.notifier).toggleLocale(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LogoPlaceholder(label: l10n.logoPlaceholder),
            const SizedBox(height: 24),
            Text(
              l10n.welcomeMessage,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.welcomeSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      l10n.demoCounterLabel,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$counter',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: l10n.incrementButton,
                      onPressed: () =>
                          ref.read(demoCounterProvider.notifier).increment(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: l10n.navToCatalog,
              icon: Icons.storefront_outlined,
              onPressed: () => context.go('/catalog'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l10n.navToStyleGuide,
              variant: AppButtonVariant.outlined,
              icon: Icons.palette_outlined,
              onPressed: () => context.go('/style-guide'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandGold, width: 2),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Image.asset(
        'assets/images/Baganza_Logo_Ufficiale.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_pharmacy,
                size: 48,
                color: AppColors.brandGold,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.brandGreenDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.locale, required this.onToggle});

  final Locale locale;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isItalian = locale.languageCode == 'it';
    return TextButton.icon(
      onPressed: onToggle,
      icon: const Icon(Icons.language),
      label: Text(isItalian ? 'IT' : 'EN'),
    );
  }
}
