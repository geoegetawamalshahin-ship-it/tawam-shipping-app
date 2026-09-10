import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipment_status/hero_feature.dart';

void main() {
  testWidgets('track defaults keep icon 13 and text 9', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShipmentHeroFeature(
            icon: Icons.verified_outlined,
            label: 'Secure',
          ),
        ),
      ),
    );

    expect(tester.widget<Icon>(find.byIcon(Icons.verified_outlined)).size, 13);
    expect(tester.widget<Text>(find.text('Secure')).style?.fontSize, 9);
    expect(
      tester.widget<Text>(find.text('Secure')).style?.fontWeight,
      FontWeight.w700,
    );
  });

  testWidgets('booking keeps icon 14 and text 9.5', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShipmentHeroFeature(
            icon: Icons.public_rounded,
            label: 'Global',
            iconSize: 14,
            fontSize: 9.5,
          ),
        ),
      ),
    );

    expect(tester.widget<Icon>(find.byIcon(Icons.public_rounded)).size, 14);
    expect(tester.widget<Text>(find.text('Global')).style?.fontSize, 9.5);
  });

  testWidgets('calculator keeps icon 14 and text 9.3', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShipmentHeroFeature(
            icon: Icons.speed_rounded,
            label: 'Instant',
            iconSize: 14,
            fontSize: 9.3,
          ),
        ),
      ),
    );

    expect(tester.widget<Icon>(find.byIcon(Icons.speed_rounded)).size, 14);
    expect(tester.widget<Text>(find.text('Instant')).style?.fontSize, 9.3);
  });
}
