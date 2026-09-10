import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/auth_field_decoration.dart';

void main() {
  test('login decoration keeps padding 20 and omits error borders', () {
    final decoration = authInputDecoration(
      hintText: 'you@business.com',
      icon: Icons.person_outline_rounded,
    );

    expect(
      decoration.contentPadding,
      const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
    );
    expect(decoration.fillColor, const Color(0xFFF7F8FA));
    expect(decoration.errorBorder, isNull);
    expect(decoration.focusedErrorBorder, isNull);
    expect(
      (decoration.focusedBorder as OutlineInputBorder).borderSide.width,
      1.7,
    );
    expect(
      (decoration.focusedBorder as OutlineInputBorder).borderSide.color,
      const Color(0xFF07569E),
    );
    expect(
      (decoration.border as OutlineInputBorder).borderRadius,
      BorderRadius.circular(17),
    );

    final prefix = decoration.prefixIcon! as Icon;
    expect(prefix.icon, Icons.person_outline_rounded);
    expect(prefix.color, const Color(0xFF87909D));
  });

  test('register decoration keeps padding 19 and both error borders', () {
    final decoration = authInputDecoration(
      hintText: 'Name',
      icon: Icons.person_outline_rounded,
      contentPaddingVertical: 19,
      errorBorderEnabled: true,
      focusedErrorBorderEnabled: true,
    );

    expect(
      decoration.contentPadding,
      const EdgeInsets.symmetric(vertical: 19, horizontal: 18),
    );
    expect(decoration.errorBorder, isNotNull);
    expect(
      (decoration.errorBorder as OutlineInputBorder).borderSide.color,
      const Color(0xFFD72638),
    );
    expect(
      (decoration.errorBorder as OutlineInputBorder).borderSide.width,
      1.0,
    );
    expect(decoration.focusedErrorBorder, isNotNull);
    expect(
      (decoration.focusedErrorBorder as OutlineInputBorder).borderSide.width,
      1.7,
    );
  });

  test('forgot decoration keeps error border and omits focused error', () {
    final decoration = authInputDecoration(
      hintText: 'you@business.com',
      icon: Icons.email_outlined,
      errorBorderEnabled: true,
    );

    expect(
      decoration.contentPadding,
      const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
    );
    expect(decoration.errorBorder, isNotNull);
    expect(decoration.focusedErrorBorder, isNull);

    final prefix = decoration.prefixIcon! as Icon;
    expect(prefix.icon, Icons.email_outlined);
  });

  testWidgets('suffix icon stays on the page-owned password field', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextFormField(
            decoration: authInputDecoration(
              hintText: 'Password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.visibility_off_outlined),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
