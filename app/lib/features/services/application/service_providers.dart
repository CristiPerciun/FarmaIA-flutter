import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/service_repository.dart';
import '../domain/service.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepository(ref.watch(firestoreProvider)),
);

/// The active services (§16.4). Auto-disposed.
final servicesProvider = StreamProvider.autoDispose<List<Service>>(
  (ref) => ref.watch(serviceRepositoryProvider).watchActiveServices(),
);

/// A single service by id.
final serviceProvider = StreamProvider.autoDispose.family<Service?, String>(
  (ref, id) => ref.watch(serviceRepositoryProvider).watchService(id),
);

/// The category selected in the Servizi screen (null = all).
final serviceCategoryFilterProvider =
    NotifierProvider<ServiceCategoryFilter, ServiceCategory?>(
      ServiceCategoryFilter.new,
    );

class ServiceCategoryFilter extends Notifier<ServiceCategory?> {
  @override
  ServiceCategory? build() => null;

  void set(ServiceCategory? category) => state = category;
}

/// Active services after applying the category filter, grouped for display by
/// their category order. Client-side over the streamed list (§2.4).
final filteredServicesProvider =
    Provider.autoDispose<AsyncValue<List<Service>>>((ref) {
      final async = ref.watch(servicesProvider);
      final category = ref.watch(serviceCategoryFilterProvider);
      return async.whenData((services) {
        final list = category == null
            ? [...services]
            : services.where((s) => s.category == category).toList();
        // Stable order: by category enum index, then by name.
        list.sort((a, b) {
          final byCat = a.category.index.compareTo(b.category.index);
          return byCat != 0 ? byCat : a.name.it.compareTo(b.name.it);
        });
        return list;
      });
    });

/// The distinct categories present in the active service set, in enum order —
/// powers the filter chips (only shows categories that actually have services).
final availableServiceCategoriesProvider =
    Provider.autoDispose<List<ServiceCategory>>((ref) {
      final services = ref.watch(servicesProvider).valueOrNull ?? const [];
      final present = services.map((s) => s.category).toSet();
      return ServiceCategory.values.where(present.contains).toList();
    });
