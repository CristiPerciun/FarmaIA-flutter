import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baganza_app/core/widgets/splash_reveal.dart';

void main() {
  setUp(SplashReveal.resetForTesting);

  Widget host({VoidCallback? onReady}) => MaterialApp(
        home: const Scaffold(body: Text('home')),
        builder: (context, child) => Stack(
          children: [
            child ?? const SizedBox.shrink(),
            SplashReveal(onReady: onReady),
          ],
        ),
      );

  testWidgets('plays once, calls onReady, and hands off within 1.8s',
      (tester) async {
    var readyCalls = 0;
    await tester.pumpWidget(host(onReady: () => readyCalls++));
    await tester.pump(); // post-frame callback -> onReady + start

    expect(readyCalls, 1, reason: 'native splash removed at first frame');
    // Overlay is covering the app while the choreography runs.
    expect(find.byType(CustomPaint), findsWidgets);

    // Non-loop: after the total duration the overlay is gone for good.
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();
    expect(find.image(const AssetImage('assets/images/emblem_raster.png')),
        findsNothing);
    expect(readyCalls, 1);
  });

  testWidgets('respects disableAnimations: skips the choreography quickly',
      (tester) async {
    // Reduced motion at the platform level (what MediaQuery derives from).
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
        tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(host());
    await tester.pump(); // post-frame -> reduced-motion path

    // Well under the animated total: gone after the short static hold.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.image(const AssetImage('assets/images/emblem_raster.png')),
        findsNothing);
  });

  testWidgets('does not replay on rebuild within the same launch',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();

    // Rebuild (e.g. locale change recreates the overlay widget).
    await tester.pumpWidget(host());
    await tester.pump();
    expect(find.image(const AssetImage('assets/images/emblem_raster.png')),
        findsNothing);
  });
}
