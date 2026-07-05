import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/checkout_address.dart';
import '../domain/payment_method.dart';

/// Carries the address entered on the checkout screen to the payment screen.
final checkoutDraftProvider =
    NotifierProvider<CheckoutDraftNotifier, CheckoutAddress?>(
      CheckoutDraftNotifier.new,
    );

class CheckoutDraftNotifier extends Notifier<CheckoutAddress?> {
  @override
  CheckoutAddress? build() => null;
  void set(CheckoutAddress address) => state = address;
  void clear() => state = null;
}

/// Outcome of placing an order.
class PlacedOrder {
  const PlacedOrder({required this.orderId, required this.orderNumber});
  final String orderId;
  final String orderNumber;
}

final checkoutServiceProvider = Provider<CheckoutService>(
  (ref) => CheckoutService(ref),
);

/// Orchestrates order placement (§3.4). Creation and payment confirmation are
/// Cloud Functions (clients cannot write `orders` directly, §5.5). Guests are
/// signed in anonymously first (§3.2). The MVP uses a sandbox payment
/// confirmation that stands in for the gateway webhook — see ADR 0003.
class CheckoutService {
  CheckoutService(this._ref);

  final Ref _ref;

  Future<PlacedOrder> placeOrder({
    required CheckoutAddress address,
    required PaymentMethod method,
  }) async {
    // Guest checkout → anonymous auth so the order has an owner (§3.2).
    await _ref.read(authRepositoryProvider).ensureSignedIn();

    final functions = _ref.read(firebaseFunctionsProvider);

    final createResult = await functions.httpsCallable('createOrder').call({
      'shippingAddress': address.toJson(),
      'paymentMethod': method.storageName,
    });
    final data = Map<String, dynamic>.from(createResult.data as Map);
    final orderId = data['orderId'] as String;
    final orderNumber = data['orderNumber'] as String;

    // Sandbox payment confirmation (stands in for the gateway webhook, ADR 0003).
    await functions.httpsCallable('confirmMockPayment').call({
      'orderId': orderId,
      'paymentMethod': method.storageName,
    });

    return PlacedOrder(orderId: orderId, orderNumber: orderNumber);
  }
}
