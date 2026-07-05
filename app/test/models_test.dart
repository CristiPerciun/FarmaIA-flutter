import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/core/models/localized_text.dart';
import 'package:baganza_app/core/utils/money.dart';
import 'package:baganza_app/features/auth/domain/app_user.dart';
import 'package:baganza_app/features/cart/domain/cart.dart';
import 'package:baganza_app/features/catalog/domain/product.dart';

void main() {
  group('LocalizedText', () {
    test('resolves EN with IT fallback', () {
      const bilingual = LocalizedText(it: 'Ciao', en: 'Hello');
      expect(bilingual.resolveCode('en'), 'Hello');
      expect(bilingual.resolveCode('it'), 'Ciao');

      const itOnly = LocalizedText(it: 'Solo IT', en: '');
      expect(itOnly.resolveCode('en'), 'Solo IT', reason: 'falls back to IT');
    });

    test('isComplete requires both languages', () {
      expect(const LocalizedText(it: 'a', en: 'b').isComplete, isTrue);
      expect(const LocalizedText(it: 'a', en: '').isComplete, isFalse);
    });

    test('round-trips through JSON', () {
      const value = LocalizedText(it: 'Testo', en: 'Text');
      expect(LocalizedText.fromJson(value.toJson()), value);
    });
  });

  group('CentsFormatting', () {
    test('formats cents as localized currency', () {
      expect(699.formatMoney(localeCode: 'it'), contains('6,99'));
      expect(699.formatMoney(localeCode: 'en'), contains('6.99'));
    });
  });

  group('ProductType', () {
    test('maps two-word type to snake_case storage name', () {
      expect(ProductType.dispositivoMedico.storageName, 'dispositivo_medico');
      expect(
        ProductType.fromStorage('dispositivo_medico'),
        ProductType.dispositivoMedico,
      );
    });

    test('SOP and OTC are medicines', () {
      expect(ProductType.sop.isMedicine, isTrue);
      expect(ProductType.otc.isMedicine, isTrue);
      expect(ProductType.cosmetico.isMedicine, isFalse);
    });
  });

  group('Product', () {
    Product buildMedicine({
      LocalizedText posology = const LocalizedText(it: 'p', en: 'p'),
      LocalizedText contraindications = const LocalizedText(it: 'c', en: 'c'),
    }) {
      return Product(
        id: 'p1',
        sku: 'SKU',
        barcode: '123',
        categoryRef: 'categories/analgesici',
        type: ProductType.sop,
        name: const LocalizedText(it: 'Oki', en: 'Oki'),
        shortDescription: const LocalizedText.empty(),
        description: const LocalizedText.empty(),
        activeIngredient: const LocalizedText.empty(),
        posology: posology,
        contraindications: contraindications,
        warnings: const LocalizedText.empty(),
        ceMarking: false,
        priceList: 999,
        priceSale: 699,
        currency: 'EUR',
        vatRate: 10,
        stockQty: 5,
        available: true,
        images: const [],
        seo: ProductSeo.fromJson(const {}),
        status: ProductStatus.published,
        aiGenerated: true,
        assistantEligible: true,
      );
    }

    test('effectivePrice uses sale price when discounted', () {
      expect(buildMedicine().effectivePrice, 699);
      expect(buildMedicine().isOnSale, isTrue);
    });

    test(
      'medicine needs bilingual posology + contraindications to publish',
      () {
        expect(buildMedicine().meetsMedicinePublishingRule, isTrue);
        final missing = buildMedicine(
          contraindications: const LocalizedText(it: 'solo it', en: ''),
        );
        expect(missing.meetsMedicinePublishingRule, isFalse);
      },
    );

    test('round-trips through JSON preserving type and status', () {
      final product = buildMedicine();
      final restored = Product.fromJson(product.toJson(), product.id);
      expect(restored.type, ProductType.sop);
      expect(restored.status, ProductStatus.published);
      expect(restored.isMedicine, isTrue);
      expect(restored.priceSale, 699);
      expect(restored.assistantEligible, isTrue);
    });

    test('toJson writes derived isMedicine flag', () {
      expect(buildMedicine().toJson()['isMedicine'], isTrue);
    });
  });

  group('AppUser', () {
    test('role defaults to customer and is not in client toJson', () {
      final user = AppUser.fromJson(const {'email': 'a@b.it'}, 'uid1');
      expect(user.role, UserRole.customer);
      expect(
        user.toJson().containsKey('role'),
        isFalse,
        reason: 'role is server-controlled (§5.5)',
      );
    });

    test('staff roles are detected', () {
      expect(UserRole.admin.isStaff, isTrue);
      expect(UserRole.pharmacist.isStaff, isTrue);
      expect(UserRole.customer.isStaff, isFalse);
    });

    test('consents round-trip', () {
      const consents = UserConsents(marketing: true, aiAssistant: true);
      final restored = UserConsents.fromJson(consents.toJson());
      expect(restored.marketing, isTrue);
      expect(restored.aiAssistant, isTrue);
      expect(restored.medicineDataProcessing, isFalse);
    });
  });

  group('Cart', () {
    test('computes item count and subtotal in cents', () {
      const cart = Cart(
        userRef: 'uid1',
        items: [
          CartItem(productRef: 'p1', qty: 2, priceSnapshot: 699),
          CartItem(productRef: 'p2', qty: 1, priceSnapshot: 1590),
        ],
      );
      expect(cart.itemCount, 3);
      expect(cart.subtotal, 2 * 699 + 1590);
    });
  });
}
