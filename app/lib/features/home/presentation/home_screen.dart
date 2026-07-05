import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    return AdaptiveScaffold(
      currentTab: AppTab.home,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      body: AmbientBackground(
        hero: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LogoPlaceholder(label: l10n.logoPlaceholder),
                    const SizedBox(height: 24),
                    Text(
                      l10n.welcomeMessage,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.welcomeSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
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
            ),
          ),
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
