import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/services_section.dart';

void main() {
  testWidgets(
    'services preserve raw values, multiple selection and deselection',
    (tester) async {
      final selected = <String>{'packing'};
      final events = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ShippingServicesSection(
                title: 'Services',
                subtitle: 'Choose multiple',
                services: const ['packing', 'delivery'],
                selectedServices: selected,
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
                borderColor: Colors.grey,
                shadowColor: Colors.blue,
                textColor: Colors.black,
                labelColor: Colors.grey,
                primaryColor: Colors.blue,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      );
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'تغليف'))
            .selected,
        isTrue,
      );
      await tester.tap(find.text('توصيل'));
      await tester.pumpAndSettle();
      expect(selected, {'packing', 'delivery'});
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'توصيل'))
            .selected,
        isTrue,
      );
      await tester.tap(find.text('تغليف'));
      await tester.pumpAndSettle();
      expect(selected, {'delivery'});
      expect(events, ['delivery:true', 'packing:false']);
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'تغليف'))
            .selected,
        isFalse,
      );
    },
  );

  testWidgets(
    'chip chrome matches shipping and international additional services',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShippingServicesSection(
              title: 'Select services',
              subtitle: 'You can choose more than one',
              services: const ['Customs Clearance', 'Packing Materials'],
              selectedServices: const ['Customs Clearance'],
              serviceLabel: (value) => value,
              onSelectionChanged: (_, _) {},
              borderColor: const Color(0xFFE2EAF2),
              shadowColor: const Color(0xFF062B55),
              textColor: const Color(0xFF101B2D),
              labelColor: const Color(0xFF7E8A9A),
              primaryColor: const Color(0xFF0B4F9C),
              fillColor: const Color(0xFFF7F9FC),
            ),
          ),
        ),
      );

      expect(find.text('Select services'), findsOneWidget);
      expect(find.text('You can choose more than one'), findsOneWidget);

      final selected = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Customs Clearance'),
      );
      final unselected = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Packing Materials'),
      );

      expect(selected.showCheckmark, isTrue);
      expect(selected.checkmarkColor, Colors.white);
      expect(selected.selectedColor, const Color(0xFF0B4F9C));
      expect(selected.backgroundColor, const Color(0xFFF7F9FC));
      expect(selected.labelStyle?.fontSize, 9.5);
      expect(selected.labelStyle?.fontWeight, FontWeight.w700);
      expect(selected.labelStyle?.color, Colors.white);
      expect(unselected.labelStyle?.color, const Color(0xFF101B2D));
      expect(unselected.selected, isFalse);

      final selectedShape = selected.shape as RoundedRectangleBorder;
      expect(selectedShape.borderRadius, BorderRadius.circular(30));
    },
  );
}
