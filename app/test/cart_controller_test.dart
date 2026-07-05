import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/features/auth/application/auth_providers.dart';
import 'package:baganza_app/features/cart/application/cart_providers.dart';
import 'package:baganza_app/features/catalog/domain/product.dart';

Product _product(String id, {int priceList = 1000, int priceSale = 0}) =>
    Product.fromJson({
      'sku': id,
      'name': {'it': id, 'en': id},
      'priceList': priceList,
      'priceSale': priceSale,
      'status': 'published',
      'available': true,
    }, id);

void main() {
  // Guest path: currentUser is null → the controller mutates the in-memory
  // guest cart, which is the synchronous source of truth.
  ProviderContainer guestContainer() {
    final c = ProviderContainer(
      overrides: [currentUserProvider.overrideWithValue(null)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('add inserts a line with the effective price snapshot', () async {
    final c = guestContainer();
    await c.read(cartControllerProvider).add(_product('oki', priceList: 800));

    final cart = c.read(guestCartProvider);
    expect(cart.items.length, 1);
    expect(cart.items.first.productRef, 'oki');
    expect(cart.items.first.priceSnapshot, 800);
    expect(cart.itemCount, 1);
  });

  test(
    'adding the same product twice increments quantity (no lost update)',
    () async {
      final c = guestContainer();
      final controller = c.read(cartControllerProvider);
      await controller.add(_product('oki'));
      await controller.add(_product('oki'));

      final cart = c.read(guestCartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.qty, 2);
    },
  );

  test('two different products create two lines', () async {
    final c = guestContainer();
    final controller = c.read(cartControllerProvider);
    await controller.add(_product('oki'));
    await controller.add(_product('tachi'));

    expect(c.read(guestCartProvider).items.length, 2);
  });

  test('setQty to 0 removes the line; subtotal reflects snapshots', () async {
    final c = guestContainer();
    final controller = c.read(cartControllerProvider);
    await controller.add(_product('oki', priceList: 500));
    await controller.add(_product('tachi', priceList: 300));

    await controller.setQty('oki', 3);
    expect(c.read(guestCartProvider).subtotal, 500 * 3 + 300);

    await controller.setQty('oki', 0);
    final cart = c.read(guestCartProvider);
    expect(cart.items.map((i) => i.productRef), ['tachi']);
  });

  test('remove drops the line; clear empties the cart', () async {
    final c = guestContainer();
    final controller = c.read(cartControllerProvider);
    await controller.add(_product('oki'));
    await controller.add(_product('tachi'));

    await controller.remove('oki');
    expect(c.read(guestCartProvider).items.length, 1);

    await controller.clear();
    expect(c.read(guestCartProvider).isEmpty, isTrue);
  });
}
