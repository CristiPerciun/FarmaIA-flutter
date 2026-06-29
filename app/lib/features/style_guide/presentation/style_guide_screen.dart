import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';

class StyleGuideScreen extends StatelessWidget {
  const StyleGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.styleGuideTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Palette', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          const _ColorSwatch(
            name: 'brandGreen (CTA)',
            color: AppColors.brandGreen,
            textColor: Colors.white,
          ),
          const _ColorSwatch(
            name: 'brandGreenDark (text)',
            color: AppColors.brandGreenDark,
            textColor: Colors.white,
          ),
          const _ColorSwatch(
            name: 'brandGold (decorative only)',
            color: AppColors.brandGold,
            textColor: AppColors.brandGreenDark,
          ),
          const _ColorSwatch(
            name: 'brandCrimson (accent)',
            color: AppColors.brandCrimson,
            textColor: Colors.white,
          ),
          const _ColorSwatch(
            name: 'alert (errors)',
            color: AppColors.alert,
            textColor: Colors.white,
          ),
          const SizedBox(height: 32),
          Text('Typography', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Headline Large',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
            'Headline Medium',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 32),
          Text('Components', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          AppButton(label: 'Primary', onPressed: () {}),
          const SizedBox(height: 8),
          AppButton(
            label: 'Secondary',
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Outlined',
            variant: AppButtonVariant.outlined,
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          const AppCard(
            title: 'Card title',
            child: Text('Card content with border and surface background.'),
          ),
          const SizedBox(height: 16),
          const AppTextField(label: 'Label', hint: 'Hint text'),
          const SizedBox(height: 32),
          Text(
            'WCAG: green #1E7A3C on white ≈ 4.6:1 (AA). '
            'Green dark #14532D on white ≈ 9.5:1 (AAA). '
            'Gold is never used for readable text.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.name,
    required this.color,
    required this.textColor,
  });

  final String name;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          name,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
