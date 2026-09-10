import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipment_status/info_card.dart';

void main() {
  const border = Color(0xFFE2EAF2);
  const softBlue = Color(0xFFEAF3FF);
  const primaryBlue = Color(0xFF0B4F9C);
  const textGrey = Color(0xFF7E8A9A);
  const textDark = Color(0xFF101B2D);

  Future<void> pumpCard(WidgetTester tester, {required double minHeight}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            child: ShipmentInfoCard(
              icon: Icons.inventory_2_outlined,
              label: 'CARGO',
              value: 'Electronics',
              minHeight: minHeight,
              borderColor: border,
              iconBackground: softBlue,
              iconColor: primaryBlue,
              labelColor: textGrey,
              valueColor: textDark,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('track card keeps minHeight 106', (tester) async {
    await pumpCard(tester, minHeight: 106);
    final card = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(ShipmentInfoCard),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(card.constraints, const BoxConstraints(minHeight: 106));
    expect(
      (card.decoration! as BoxDecoration).borderRadius,
      BorderRadius.circular(19),
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.inventory_2_outlined)).size,
      19,
    );
    expect(tester.widget<Text>(find.text('CARGO')).style?.letterSpacing, .55);
    expect(tester.widget<Text>(find.text('Electronics')).style?.fontSize, 10.8);
  });

  testWidgets('details card keeps minHeight 107', (tester) async {
    await pumpCard(tester, minHeight: 107);
    final card = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(ShipmentInfoCard),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(card.constraints, const BoxConstraints(minHeight: 107));
    expect(find.text('CARGO'), findsOneWidget);
  });
}
