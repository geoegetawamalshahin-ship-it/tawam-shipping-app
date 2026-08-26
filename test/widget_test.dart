import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
