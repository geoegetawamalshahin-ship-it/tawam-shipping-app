import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/premium_card.dart';

void main() {
  const border = Color(0xFFE3EAF2);
  const shadow = Color(0xFF062B55);

  BoxDecoration decorationOf(WidgetTester tester) {
    final card = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(ShippingPremiumCard),
            matching: find.byType(Container),
          )
          .first,
    );
    return card.decoration! as BoxDecoration;
  }

  testWidgets('six-form defaults keep radius 21 blur 18 and offset 0,7', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShippingPremiumCard(
            borderColor: border,
            shadowColor: shadow,
            child: Text('freight'),
          ),
        ),
      ),
    );

    final decoration = decorationOf(tester);
    expect(decoration.borderRadius, BorderRadius.circular(21));
    expect(decoration.boxShadow!.single.blurRadius, 18);
    expect(decoration.boxShadow!.single.offset, const Offset(0, 7));
    expect(find.text('freight'), findsOneWidget);
  });

  testWidgets('get-quote card keeps radius 20 and blur 12', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShippingPremiumCard(
            borderColor: border,
            shadowColor: shadow,
            borderRadius: 20,
            shadowBlur: 12,
            shadowOffset: Offset(0, 5),
            child: Text('quote'),
          ),
        ),
      ),
    );

    final decoration = decorationOf(tester);
    expect(decoration.borderRadius, BorderRadius.circular(20));
    expect(decoration.boxShadow!.single.blurRadius, 12);
    expect(decoration.boxShadow!.single.offset, const Offset(0, 5));
  });

  testWidgets('booking card keeps default radius 21 with blur 14', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShippingPremiumCard(
            borderColor: border,
            shadowColor: shadow,
            shadowBlur: 14,
            shadowOffset: Offset(0, 5),
            child: Text('booking'),
          ),
        ),
      ),
    );

    final decoration = decorationOf(tester);
    expect(decoration.borderRadius, BorderRadius.circular(21));
    expect(decoration.boxShadow!.single.blurRadius, 14);
    expect(decoration.boxShadow!.single.offset, const Offset(0, 5));
  });

  testWidgets('calculator dimensions card keeps radius 22', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShippingPremiumCard(
            borderColor: Color(0xFFE1E8F0),
            shadowColor: shadow,
            borderRadius: 22,
            shadowBlur: 14,
            shadowOffset: Offset(0, 5),
            child: Text('dimensions'),
          ),
        ),
      ),
    );

    final decoration = decorationOf(tester);
    expect(decoration.borderRadius, BorderRadius.circular(22));
    expect(decoration.boxShadow!.single.blurRadius, 14);
  });
}
