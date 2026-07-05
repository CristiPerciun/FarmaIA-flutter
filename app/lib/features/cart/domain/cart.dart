import '../../../core/firebase/firestore_converters.dart';

/// A cart line item. `priceSnapshot` (cents) freezes the price at the time the
/// item was added, so later catalog price changes don't silently alter the
/// cart (§5.1).
class CartItem {
  const CartItem({
    required this.productRef,
    required this.qty,
    required this.priceSnapshot,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productRef: (json['productRef'] as String?) ?? '',
    qty: centsFromJson(json['qty']),
    priceSnapshot: centsFromJson(json['priceSnapshot']),
  );

  final String productRef;
  final int qty;
  final int priceSnapshot;

  int get lineTotal => qty * priceSnapshot;

  CartItem copyWith({int? qty, int? priceSnapshot}) => CartItem(
    productRef: productRef,
    qty: qty ?? this.qty,
    priceSnapshot: priceSnapshot ?? this.priceSnapshot,
  );

  Map<String, dynamic> toJson() => {
    'productRef': productRef,
    'qty': qty,
    'priceSnapshot': priceSnapshot,
  };
}

/// The user's cart (`carts/{uid}`, §5.1). Editing requires connectivity (§9).
class Cart {
  const Cart({required this.userRef, this.items = const [], this.updatedAt});

  factory Cart.fromJson(Map<String, dynamic> json, String id) => Cart(
    userRef: (json['userRef'] as String?) ?? id,
    items: (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CartItem.fromJson)
        .toList(),
    updatedAt: dateFromJson(json['updatedAt']),
  );

  final String userRef;
  final List<CartItem> items;
  final DateTime? updatedAt;

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);

  /// Sum of line totals in cents (before shipping/VAT adjustments).
  int get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  Map<String, dynamic> toJson() => {
    'userRef': userRef,
    'items': items.map((i) => i.toJson()).toList(),
    'updatedAt': dateToJson(updatedAt),
  };
}
