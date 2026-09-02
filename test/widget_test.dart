import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/core/responsive/feature_page_body.dart';

void main() {
  testWidgets('Material smoke test does not require Firebase', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Tawam'),
        ),
      ),
    );

    expect(find.text('Tawam'), findsOneWidget);
  });

  testWidgets('feature pages are constrained on wide screens', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const contentKey = Key('feature-content');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeaturePageBody(
            child: SizedBox(key: contentKey, width: double.infinity),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(contentKey)).width, 900);
  });

  testWidgets('feature list padding centers tablet content', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late EdgeInsets padding;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            padding = FeaturePageInsets.list(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(padding.left, 166);
    expect(padding.right, 166);
  });
}
