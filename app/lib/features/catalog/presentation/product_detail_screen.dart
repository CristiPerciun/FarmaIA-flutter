import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/localized_text.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/breakpoints.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/application/cart_providers.dart';
import '../../compliance/presentation/ministerial_logo.dart';
import '../application/catalog_providers.dart';
import '../domain/product.dart';
import 'widgets/product_card.dart';

/// Step 2.3 — bilingual product detail. The photo sits on the ambient wash;
/// everything critical (price, posology, contraindications) is on a solid
/// surface (§7.2.3). The image is a shared [Hero] with the catalog card.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(productProvider(productId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/catalog'),
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
            child: Text(
              ref.watch(localeProvider).languageCode == 'it' ? 'IT' : 'EN',
            ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _NotFound(message: l10n.catalogLoadError),
        data: (product) => product == null
            ? _NotFound(message: l10n.productNotFound)
            : _ProductBody(product: product),
      ),
    );
  }
}

class _ProductBody extends ConsumerWidget {
  const _ProductBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isDesktop = Breakpoints.of(context).usesRail;
    final imageUrl = product.images.isNotEmpty ? product.images.first.url : '';

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Photo on the ambient wash (§7.2.3).
        AmbientBackground(
          hero: true,
          child: SizedBox(
            height: 320,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + kToolbarHeight,
                left: 24,
                right: 24,
                bottom: 16,
              ),
              child: Hero(
                tag: productHeroTag(product.id),
                child: imageUrl.isEmpty
                    ? const Icon(
                        Icons.medication_outlined,
                        size: 96,
                        color: AppColors.border,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) => const Icon(
                          Icons.broken_image_outlined,
                          size: 64,
                          color: AppColors.border,
                        ),
                      ),
              ),
            ),
          ),
        ),
        // Everything below is on a solid white surface.
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name.resolve(locale),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (product.shortDescription.resolve(locale).isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  product.shortDescription.resolve(locale),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 16),
              _PriceRow(product: product, locale: locale),
              const SizedBox(height: 16),
              if (product.type == ProductType.dispositivoMedico &&
                  product.ceMarking)
                _CeBadge(label: l10n.productCeMarkingPresent),
              MinisterialLogo(isMedicine: product.isMedicine),
              const SizedBox(height: 8),
              _Section(
                title: l10n.productDescription,
                value: product.description,
                locale: locale,
              ),
              _Section(
                title: l10n.productActiveIngredient,
                value: product.activeIngredient,
                locale: locale,
              ),
              _Section(
                title: l10n.productPosology,
                value: product.posology,
                locale: locale,
              ),
              _Section(
                title: l10n.productContraindications,
                value: product.contraindications,
                locale: locale,
              ),
              _Section(
                title: l10n.productWarnings,
                value: product.warnings,
                locale: locale,
              ),
              const SizedBox(height: 16),
              _TrustReturns(
                title: l10n.trustReturnsTitle,
                body: l10n.trustReturnsBody,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(l10n.productAddToCart),
                  onPressed: () {
                    ref.read(cartControllerProvider).add(product);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(l10n.addedToCart)));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final scroll = SingleChildScrollView(
      child: isDesktop
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: content,
              ),
            )
          : content,
    );
    return scroll;
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product, required this.locale});

  final Product product;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final code = locale.languageCode;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          product.effectivePrice.formatMoney(
            localeCode: code,
            currency: product.currency,
          ),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: product.isOnSale
                ? AppColors.brandCrimson
                : AppColors.brandGreenDark,
          ),
        ),
        if (product.isOnSale) ...[
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              product.priceList.formatMoney(
                localeCode: code,
                currency: product.currency,
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CeBadge extends StatelessWidget {
  const _CeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_outlined, color: AppColors.brandGreen),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.value,
    required this.locale,
  });

  final String title;
  final LocalizedText value;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final text = value.resolve(locale);
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.brandGreenDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _TrustReturns extends StatelessWidget {
  const _TrustReturns({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.assignment_return_outlined,
            color: AppColors.brandGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 56,
                color: AppColors.brandGreen,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
