import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/notes_field.dart';

void main() {
  late TextEditingController controller;

  setUp(() {
    controller = TextEditingController();
  });

  tearDown(() {
    controller.dispose();
  });

  InputDecoration decorationOf(WidgetTester tester) {
    return tester.widget<TextField>(find.byType(TextField)).decoration!;
  }

  testWidgets('five-form notes keep prefix icon and hint height 1.45', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShippingNotesField(
            controller: controller,
            hintText: 'Notes',
            textColor: const Color(0xFF101B2D),
            hintColor: const Color(0xFFA1ACB9),
            primaryColor: const Color(0xFF0B4F9C),
            fillColor: const Color(0xFFF7F9FC),
            borderColor: const Color(0xFFE2EAF2),
          ),
        ),
      ),
    );

    final decoration = decorationOf(tester);
    expect(decoration.prefixIcon, isNotNull);
    expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);
    expect(decoration.hintStyle?.height, 1.45);
    expect(
      (decoration.border as OutlineInputBorder).borderSide.color,
      const Color(0xFFE2EAF2),
    );
  });

  testWidgets('air notes omit prefix icon height and idle border side', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShippingNotesField(
            controller: controller,
            hintText: 'Notes',
            textColor: const Color(0xFF101B2D),
            hintColor: const Color(0xFFA1ACB9),
            primaryColor: const Color(0xFF0B4F9C),
            fillColor: const Color(0xFFF7F9FC),
            borderColor: const Color(0xFFE2EAF2),
            showPrefixIcon: false,
            hintHeight: null,
            includeIdleBorderSide: false,
          ),
        ),
      ),
    );

    final decoration = decorationOf(tester);
    expect(decoration.prefixIcon, isNull);
    expect(find.byIcon(Icons.edit_note_rounded), findsNothing);
    expect(decoration.hintStyle?.height, isNull);
    expect(decoration.hintStyle?.fontSize, 10);
    expect(
      (decoration.border as OutlineInputBorder).borderSide,
      const BorderSide(),
    );
    expect(
      (decoration.enabledBorder as OutlineInputBorder).borderSide.color,
      const Color(0xFFE2EAF2),
    );
    expect(
      (decoration.focusedBorder as OutlineInputBorder).borderSide.width,
      1.4,
    );
  });
}
