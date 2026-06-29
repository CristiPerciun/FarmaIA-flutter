import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:baganza_app/core/config/app_env.dart';
import 'package:baganza_app/core/providers/demo_counter_provider.dart';

void main() {
  test('AppEnv defaults to dev', () {
    expect(AppEnv.fromDartDefine(), AppEnv.dev);
  });

  test('Demo counter increments', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(demoCounterProvider), 0);
    container.read(demoCounterProvider.notifier).increment();
    expect(container.read(demoCounterProvider), 1);
  });
}
