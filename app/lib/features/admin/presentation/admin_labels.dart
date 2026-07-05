import '../../../l10n/app_localizations.dart';
import '../../catalog/domain/product.dart';

/// Localized labels for the admin product enums (§10).
extension ProductTypeL10n on ProductType {
  String label(AppLocalizations l10n) => switch (this) {
    ProductType.sop => l10n.productTypeSop,
    ProductType.otc => l10n.productTypeOtc,
    ProductType.parafarmaco => l10n.productTypeParafarmaco,
    ProductType.integratore => l10n.productTypeIntegratore,
    ProductType.cosmetico => l10n.productTypeCosmetico,
    ProductType.dispositivoMedico => l10n.productTypeDispositivoMedico,
  };
}

extension ProductStatusL10n on ProductStatus {
  String label(AppLocalizations l10n) => switch (this) {
    ProductStatus.draft => l10n.statusDraft,
    ProductStatus.pendingReview => l10n.statusPendingReview,
    ProductStatus.published => l10n.statusPublished,
    ProductStatus.archived => l10n.statusArchived,
  };
}
