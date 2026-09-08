import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/form_controls.dart';

void main() {
  testWidgets('dropdown shows translated labels and returns original values', (tester) async {
    String? selected;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: shippingDropdown(
      value: 'first', items: const ['first', 'second'],
      onChanged: (value) => selected = value,
      primaryColor: Colors.blue,
      decoration: const InputDecoration(labelText: 'Service'),
      itemLabel: (item) => item == 'first' ? 'الأول' : 'الثاني',
    ))));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الثاني').last);
    await tester.pumpAndSettle();
    expect(selected, 'second');
    expect(find.text('الثاني'), findsWidgets);
  });

  testWidgets('dimension editing retains controller listeners for calculations', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? observed;
    controller.addListener(() => observed = controller.text);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: shippingDimensionField(
      controller: controller, label: 'Length', textDark: Colors.black,
      textGrey: Colors.grey, primaryBlue: Colors.blue,
      softGrey: Colors.white, border: Colors.grey,
    ))));
    await tester.enterText(find.byType(TextFormField), '12.5');
    expect(controller.text, '12.5');
    expect(observed, '12.5');
  });

  testWidgets('option switch sends the new value to the owning page', (tester) async {
    bool? changed;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: shippingOptionSwitch(
      icon: Icons.shield, title: 'Insurance', subtitle: 'Optional', value: false,
      onChanged: (value) => changed = value,
      softBlue: Colors.white, primaryBlue: Colors.blue,
      textDark: Colors.black, textGrey: Colors.grey,
    ))));
    await tester.tap(find.byType(Switch));
    expect(changed, isTrue);
  });
}
