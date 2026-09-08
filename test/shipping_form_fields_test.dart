import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/form_fields.dart';

void main() {
  testWidgets('shared field retains editing and validation callbacks', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final formKey = GlobalKey<FormState>();
    String? changed;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Form(
      key: formKey,
      child: shippingTextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Weight'),
        textColor: Colors.black,
        keyboardType: TextInputType.number,
        onChanged: (value) => changed = value,
        validator: (value) => value == '12' ? null : 'Invalid weight',
      ),
    ))));
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Invalid weight'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '12');
    expect(controller.text, '12');
    expect(changed, '12');
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Invalid weight'), findsNothing);
  });

  test('air decoration preserves its original style exceptions', () {
    InputDecoration decoration({bool air = false}) => shippingInputDecoration(
      label: 'Label', hint: 'Hint', icon: Icons.flight,
      primaryColor: Colors.blue, labelColor: Colors.grey,
      fillColor: Colors.white, borderColor: Colors.black,
      labelWeight: air ? null : FontWeight.w600,
      focusedErrorBorderEnabled: !air,
    );
    expect(decoration().labelStyle!.fontWeight, FontWeight.w600);
    expect(decoration().focusedErrorBorder, isNotNull);
    expect(decoration(air: true).labelStyle!.fontWeight, isNull);
    expect(decoration(air: true).focusedErrorBorder, isNull);
  });
}
