import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo counter to verify Riverpod is active (Step 0.3).
final demoCounterProvider = NotifierProvider<DemoCounter, int>(DemoCounter.new);

class DemoCounter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}
