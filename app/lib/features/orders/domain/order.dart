import '../../../core/firebase/firestore_converters.dart';

/// Payment lifecycle (§5.1). Stock is scaled only once payment is confirmed
/// (§9.2); a failed payment leaves stock untouched.
enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded;

  static PaymentStatus fromStorage(Object? value) =>
      enumFromName(value, PaymentStatus.values, PaymentStatus.pending);
}

enum ShippingStatus {
  processing,
  shipped,
  delivered,
  returned;

  static ShippingStatus fromStorage(Object? value) =>
      enumFromName(value, ShippingStatus.values, ShippingStatus.processing);
}

enum OrderStatus {
  created,
  confirmed,
  preparing,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromStorage(Object? value) =>
      enumFromName(value, OrderStatus.values, OrderStatus.created);
}

/// An order line item, with a name snapshot and the VAT rate applied (§5.3).
class OrderItem {
  const OrderItem({
    required this.productRef,
    required this.nameSnapshot,
    required this.qty,
    required this.unitPrice,
    required this.vatRate,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productRef: (json['productRef'] as String?) ?? '',
    nameSnapshot: (json['nameSnapshot'] as String?) ?? '',
    qty: centsFromJson(json['qty']),
    unitPrice: centsFromJson(json['unitPrice']),
    vatRate: centsFromJson(json['vatRate']),
  );

  final String productRef;
  final String nameSnapshot;
  final int qty;
  final int unitPrice;
  final int vatRate;

  int get lineTotal => qty * unitPrice;

  Map<String, dynamic> toJson() => {
    'productRef': productRef,
    'nameSnapshot': nameSnapshot,
    'qty': qty,
    'unitPrice': unitPrice,
    'vatRate': vatRate,
  };
}

/// Order money breakdown, all in cents (§5.3).
class OrderTotals {
  const OrderTotals({
    required this.subtotal,
    required this.shipping,
    required this.vat,
    required this.total,
  });

  factory OrderTotals.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    return OrderTotals(
      subtotal: centsFromJson(map['subtotal']),
      shipping: centsFromJson(map['shipping']),
      vat: centsFromJson(map['vat']),
      total: centsFromJson(map['total']),
    );
  }

  final int subtotal;
  final int shipping;
  final int vat;
  final int total;

  Map<String, dynamic> toJson() => {
    'subtotal': subtotal,
    'shipping': shipping,
    'vat': vat,
    'total': total,
  };
}

/// An order (collection `orders`, §5.1/§5.3). Creation and sensitive status
/// changes happen through Cloud Functions (§5.5).
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.userRef,
    required this.items,
    required this.totals,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.shippingStatus,
    required this.status,
    this.billingAddress,
    this.paymentRef,
    this.carrier,
    this.trackingNumber,
    this.recessoRequested = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json, String id) => Order(
    id: id,
    orderNumber: (json['orderNumber'] as String?) ?? '',
    userRef: (json['userRef'] as String?) ?? '',
    items: (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromJson)
        .toList(),
    totals: OrderTotals.fromJson(json['totals']),
    shippingAddress: (json['shippingAddress'] as Map<String, dynamic>?) ?? {},
    billingAddress: json['billingAddress'] as Map<String, dynamic>?,
    paymentMethod: (json['paymentMethod'] as String?) ?? '',
    paymentStatus: PaymentStatus.fromStorage(json['paymentStatus']),
    paymentRef: json['paymentRef'] as String?,
    shippingStatus: ShippingStatus.fromStorage(json['shippingStatus']),
    carrier: json['carrier'] as String?,
    trackingNumber: json['trackingNumber'] as String?,
    status: OrderStatus.fromStorage(json['status']),
    recessoRequested: (json['recessoRequested'] as bool?) ?? false,
    createdAt: dateFromJson(json['createdAt']),
    updatedAt: dateFromJson(json['updatedAt']),
  );

  final String id;
  final String orderNumber;
  final String userRef;
  final List<OrderItem> items;
  final OrderTotals totals;
  final Map<String, dynamic> shippingAddress;
  final Map<String, dynamic>? billingAddress;
  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final String? paymentRef;
  final ShippingStatus shippingStatus;
  final String? carrier;
  final String? trackingNumber;
  final OrderStatus status;

  /// Withdrawal requested under art. 54-bis (§1.4, §16.8).
  final bool recessoRequested;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  Map<String, dynamic> toJson() => {
    'orderNumber': orderNumber,
    'userRef': userRef,
    'items': items.map((i) => i.toJson()).toList(),
    'totals': totals.toJson(),
    'shippingAddress': shippingAddress,
    'billingAddress': billingAddress,
    'paymentMethod': paymentMethod,
    'paymentStatus': paymentStatus.name,
    'paymentRef': paymentRef,
    'shippingStatus': shippingStatus.name,
    'carrier': carrier,
    'trackingNumber': trackingNumber,
    'status': status.name,
    'recessoRequested': recessoRequested,
    'createdAt': dateToJson(createdAt),
    'updatedAt': dateToJson(updatedAt),
  };
}
