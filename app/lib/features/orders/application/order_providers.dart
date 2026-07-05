import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../data/order_repository.dart';
import '../domain/order.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(firestoreProvider)),
);

/// The signed-in user's orders, newest first. Empty when signed out.
final userOrdersProvider = StreamProvider.autoDispose<List<Order>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);
  return ref.watch(orderRepositoryProvider).watchUserOrders(user.uid);
});

/// A single order by id.
final orderProvider = StreamProvider.autoDispose.family<Order?, String>(
  (ref, id) => ref.watch(orderRepositoryProvider).watchOrder(id),
);

/// Requests withdrawal (art. 54-bis) for an order via Cloud Function — clients
/// cannot write `orders` directly (§5.5). Sets `recessoRequested = true`.
final withdrawalServiceProvider = Provider<WithdrawalService>(
  (ref) => WithdrawalService(ref),
);

class WithdrawalService {
  WithdrawalService(this._ref);
  final Ref _ref;

  Future<void> request(String orderId) async {
    await _ref
        .read(firebaseFunctionsProvider)
        .httpsCallable('requestWithdrawal')
        .call({'orderId': orderId});
  }
}
