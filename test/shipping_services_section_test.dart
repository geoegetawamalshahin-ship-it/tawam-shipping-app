import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/services_section.dart';

void main() {
  testWidgets('services preserve raw values, multiple selection and deselection', (tester) async {
    final selected = <String>{'packing'};
    final events = <String>[];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(
      builder: (context, setState) => ShippingServicesSection(
        title: 'Services', subtitle: 'Choose multiple',
        services: const ['packing', 'delivery'], selectedServices: selected,
        serviceLabel: (value) => value == 'packing' ? 'تغليف' : 'توصيل',
        onSelectionChanged: (service, value) {
          events.add('$service:$value');
          setState(() {
            if (value) {
              selected.add(service);
            } else {
              selected.remove(service);
            }
          });
        },
        borderColor: Colors.grey, shadowColor: Colors.blue,
        textColor: Colors.black, labelColor: Colors.grey,
        primaryColor: Colors.blue, fillColor: Colors.white,
      ),
    ))));
    expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'تغليف')).selected, isTrue);
    await tester.tap(find.text('توصيل'));
    await tester.pumpAndSettle();
    expect(selected, {'packing', 'delivery'});
    expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'توصيل')).selected, isTrue);
    await tester.tap(find.text('تغليف'));
    await tester.pumpAndSettle();
    expect(selected, {'delivery'});
    expect(events, ['delivery:true', 'packing:false']);
    expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'تغليف')).selected, isFalse);
  });
}
