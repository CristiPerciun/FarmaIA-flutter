import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/core/models/localized_text.dart';
import 'package:baganza_app/features/catalog/domain/product.dart';
import 'package:baganza_app/features/compliance/domain/medicine_separation.dart';

Product _product(ProductType type) => Product(
  id: type.name,
  sku: '',
  barcode: '',
  categoryRef: '',
  type: type,
  name: const LocalizedText.empty(),
  shortDescription: const LocalizedText.empty(),
  description: const LocalizedText.empty(),
  activeIngredient: const LocalizedText.empty(),
  posology: const LocalizedText.empty(),
  contraindications: const LocalizedText.empty(),
  warnings: const LocalizedText.empty(),
  ceMarking: false,
  priceList: 0,
  priceSale: 0,
  currency: 'EUR',
  vatRate: 0,
  stockQty: 0,
  available: true,
  images: const [],
  seo: ProductSeo.fromJson(const {}),
  status: ProductStatus.published,
  aiGenerated: false,
  assistantEligible: true,
);

void main() {
  group('MedicineSeparation (§9.2)', () {
    test('a mix of medicine and non-medicine is flagged', () {
      final list = [_product(ProductType.sop), _product(ProductType.cosmetico)];
      expect(MedicineSeparation.isMixed(list), isTrue);
      expect(MedicineSeparation.isHomogeneous(list), isFalse);
    });

    test('only-medicines is homogeneous', () {
      final list = [_product(ProductType.sop), _product(ProductType.otc)];
      expect(MedicineSeparation.isMixed(list), isFalse);
      expect(MedicineSeparation.isHomogeneous(list), isTrue);
    });

    test('only-non-medicines is homogeneous', () {
      final list = [
        _product(ProductType.cosmetico),
        _product(ProductType.integratore),
      ];
      expect(MedicineSeparation.isHomogeneous(list), isTrue);
    });

    test('empty list is homogeneous and does not throw the assert', () {
      expect(MedicineSeparation.isHomogeneous(const []), isTrue);
      MedicineSeparation.assertHomogeneous(const []);
    });
  });
}
