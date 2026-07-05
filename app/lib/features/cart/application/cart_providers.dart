import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/providers/config_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/product.dart';
import '../../checkout/domain/order_pricing.dart';
import '../data/cart_repository.dart';
import '../domain/cart.dart';

/// A cart line joined with its current product (null if it's no longer
/// published), for display and checkout pricing.
class CartLine {
  const CartLine({required this.item, this.product});

  final CartItem item;
  final Product? product;

  int get lineTotal => item.lineTotal;
}

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepository(ref.watch(firestoreProvider)),
);

/// In-memory cart for guests (not signed in). Persisted to Firestore only once
/// the user authenticates (see [CartController]).
class GuestCartNotifier extends Notifier<Cart> {
  @override
  Cart build() => const Cart(userRef: 'guest');

  void set(Cart cart) => state = cart;
  void reset() => state = const Cart(userRef: 'guest');
}

final guestCartProvider = NotifierProvider<GuestCartNotifier, Cart>(
  GuestCartNotifier.new,
);

/// The active cart: the Firestore cart for a signed-in user, or the in-memory
/// guest cart otherwise. Recomputes on sign-in/out.
final cartProvider = StreamProvider<Cart>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(ref.watch(guestCartProvider));
  }
  return ref.watch(cartRepositoryProvider).watch(user.uid);
});

/// Total item count, for the nav badge.
final cartItemCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).valueOrNull?.itemCount ?? 0,
);

/// Cart lines joined with their current published product, for the cart and
/// checkout screens. Preserves cart order.
final cartLinesProvider = Provider<List<CartLine>>((ref) {
  final cart = ref.watch(cartProvider).valueOrNull;
  if (cart == null || cart.isEmpty) return const [];
  final products = ref.watch(publishedProductsProvider).valueOrNull ?? const [];
  final byId = {for (final p in products) p.id: p};
  return [
    for (final item in cart.items)
      CartLine(item: item, product: byId[item.productRef]),
  ];
});

/// Priced cart (subtotal, shipping, VAT breakdown, total). Uses the snapshotted
/// unit price and the product's VAT rate (falling back to the config default).
final cartPricingProvider = Provider<OrderPricing>((ref) {
  final lines = ref.watch(cartLinesProvider);
  final config = ref.watch(appConfigValueProvider);
  return OrderPricing.compute([
    for (final line in lines)
      PricingLine(
        qty: line.item.qty,
        unitPrice: line.item.priceSnapshot,
        vatRate: line.product?.vatRate ?? config.defaultVatRate,
      ),
  ], config);
});

final cartControllerProvider = Provider<CartController>(
  (ref) => CartController(ref),
);

/// Mutates the active cart, persisting to Firestore for signed-in users and to
/// the in-memory guest cart otherwise. Price is snapshotted at add time (§5.1).
class CartController {
  CartController(this._ref);

  final Ref _ref;

  /// The freshest known cart. For guests this is the synchronous in-memory
  /// source of truth (avoids a lost update when the [cartProvider] stream lags
  /// behind rapid edits); for signed-in users it's the Firestore-backed cart.
  Cart get _current {
    if (_ref.read(currentUserProvider) == null) {
      return _ref.read(guestCartProvider);
    }
    return _ref.read(cartProvider).valueOrNull ?? const Cart(userRef: 'guest');
  }

  Future<void> _persist(List<CartItem> items) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      _ref
          .read(guestCartProvider.notifier)
          .set(Cart(userRef: 'guest', items: items));
      return;
    }
    await _ref
        .read(cartRepositoryProvider)
        .save(user.uid, Cart(userRef: user.uid, items: items));
  }

  /// Adds [qty] of [product] (increments if already present), snapshotting the
  /// current effective price.
  Future<void> add(Product product, {int qty = 1}) async {
    final items = [..._current.items];
    final index = items.indexWhere((i) => i.productRef == product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(qty: items[index].qty + qty);
    } else {
      items.add(
        CartItem(
          productRef: product.id,
          qty: qty,
          priceSnapshot: product.effectivePrice,
        ),
      );
    }
    await _persist(items);
  }

  Future<void> setQty(String productRef, int qty) async {
    final items = [..._current.items];
    final index = items.indexWhere((i) => i.productRef == productRef);
    if (index < 0) return;
    if (qty <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(qty: qty);
    }
    await _persist(items);
  }

  Future<void> remove(String productRef) async {
    final items = _current.items
        .where((i) => i.productRef != productRef)
        .toList();
    await _persist(items);
  }

  Future<void> clear() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      _ref.read(guestCartProvider.notifier).reset();
      return;
    }
    await _ref.read(cartRepositoryProvider).clear(user.uid);
  }
}
