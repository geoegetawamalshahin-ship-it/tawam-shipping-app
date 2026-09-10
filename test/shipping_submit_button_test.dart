import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/submit_button.dart';

void main() {
  testWidgets('submit callback is blocked while loading and restored afterwards', (tester) async {
    var calls = 0;
    Future<void> render(bool submitting, String label, IconData icon) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ShippingSubmitButton(
        submitting: submitting, onSubmit: () => calls++,
        primaryColor: Colors.blue, label: label, icon: icon,
      ))));
    }
    await render(false, 'Submit quote', Icons.request_quote_outlined);
    await tester.tap(find.byType(ElevatedButton));
    expect(calls, 1);
    await render(true, 'Submit quote', Icons.request_quote_outlined);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Submit quote'), findsNothing);
    await tester.tap(find.byType(ElevatedButton));
    expect(calls, 1);
    await render(false, 'إرسال طلب عرض سعر', Icons.flight_takeoff_rounded);
    expect(find.byIcon(Icons.flight_takeoff_rounded), findsOneWidget);
    expect(find.text('إرسال طلب عرض سعر'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(calls, 2);
  });
}
