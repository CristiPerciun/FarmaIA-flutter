import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/tilt_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/product.dart';

/// Hero tag for the shared product image (card → detail, §7.2.5).
String productHeroTag(String productId) => 'product-image-$productId';

/// Product card (§7.2.4): 3D [TiltCard] with a "lifted" cut-out photo, name,
/// strikethrough list price when on sale, and a green "+" CTA. Progressive
/// disclosure — everything else lives on the detail page (§7.2.1).
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final name = product.name.resolve(locale);
    final imageUrl = product.images.isNotEmpty ? product.images.first.url : '';

    return TiltCard(
      onTap: onTap,
      semanticLabel: name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo zone over a faint ambient tint so the cut-out reads as lifted.
          Expanded(
            child: Container(
              color: AppColors.ambientAzure.withValues(alpha: 0.35),
              padding: const EdgeInsets.all(12),
              child: Hero(
                tag: productHeroTag(product.id),
                child: _ProductImage(url: imageUrl),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.brandGreenDark,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _PriceLine(product: product, locale: locale),
                    ),
                    _AddButton(label: l10n.productAddToCart, onAdd: onAdd),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Center(
        child: Icon(
          Icons.medication_outlined,
          size: 48,
          color: AppColors.border,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (context, _) => const ColoredBox(color: Colors.transparent),
      errorWidget: (context, _, _) => const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: AppColors.border,
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.product, required this.locale});

  final Product product;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final code = locale.languageCode;
    final effective = product.effectivePrice.formatMoney(
      localeCode: code,
      currency: product.currency,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.isOnSale)
          Text(
            product.priceList.formatMoney(
              localeCode: code,
              currency: product.currency,
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          effective,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: product.isOnSale
                ? AppColors.brandCrimson
                : AppColors.brandGreenDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onAdd});

  final String label;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    // The single primary action on the card (§7.2.1).
    return Tooltip(
      message: label,
      child: Material(
        color: AppColors.brandGreen,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onAdd,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.add, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
