import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/date_selector.dart';

void main() {
  testWidgets('date selector forwards taps and reflects owner updates', (tester) async {
    var calls = 0;
    String? selected;
    Future<void> render() => tester.pumpWidget(MaterialApp(home: Scaffold(body: ShippingDateSelector(
      onTap: () => calls++, fillColor: Colors.white, iconBackgroundColor: Colors.white,
      borderColor: Colors.grey, primaryColor: Colors.blue, labelColor: Colors.grey,
      textColor: Colors.black, label: 'Ready date', valueText: selected ?? 'Select date',
      isEmpty: selected == null,
    ))));
    await render();
    expect(find.text('Select date'), findsOneWidget);
    await tester.tap(find.byType(InkWell));
    expect(calls, 1);
    await render();
    expect(find.text('Select date'), findsOneWidget);
    selected = '10/09/2026';
    await render();
    expect(find.text('10/09/2026'), findsOneWidget);
    expect(find.text('Select date'), findsNothing);
    expect(tester.widget<Text>(find.text('10/09/2026')).style!.color, Colors.black);
  });
}
