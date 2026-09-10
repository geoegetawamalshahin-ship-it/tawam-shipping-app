import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipment_status/route_point.dart';

void main() {
  testWidgets('pickup stays start-aligned and delivery stays end-aligned', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              Expanded(
                child: ShipmentRoutePoint(
                  label: 'PICKUP',
                  value: 'Sharjah',
                  icon: Icons.radio_button_checked_rounded,
                  alignRight: false,
                ),
              ),
              Expanded(
                child: ShipmentRoutePoint(
                  label: 'DELIVERY',
                  value: 'Dubai',
                  icon: Icons.location_on_outlined,
                  alignRight: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('PICKUP'), findsOneWidget);
    expect(find.text('Sharjah'), findsOneWidget);
    expect(find.text('DELIVERY'), findsOneWidget);
    expect(find.text('Dubai'), findsOneWidget);

    final pickupColumn = tester.widget<Column>(
      find
          .ancestor(of: find.text('PICKUP'), matching: find.byType(Column))
          .first,
    );
    expect(pickupColumn.crossAxisAlignment, CrossAxisAlignment.start);

    final deliveryColumn = tester.widget<Column>(
      find
          .ancestor(of: find.text('DELIVERY'), matching: find.byType(Column))
          .first,
    );
    expect(deliveryColumn.crossAxisAlignment, CrossAxisAlignment.end);

    expect(tester.widget<Text>(find.text('Dubai')).textAlign, TextAlign.end);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.radio_button_checked_rounded)).size,
      17,
    );
  });
}
