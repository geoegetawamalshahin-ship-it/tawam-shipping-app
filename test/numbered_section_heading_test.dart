import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/numbered_section_heading.dart';

void main() {
  testWidgets('numbered heading keeps caller texts sizes and colors', (
    tester,
  ) async {
    const badge = Color(0xFF062B55);
    const iconColor = Color(0xFF0B4F9C);
    const titleColor = Color(0xFF10233F);
    const subtitleColor = Color(0xFF8793A4);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NumberedSectionHeading(
            number: '01',
            icon: Icons.straighten_rounded,
            title: 'Cargo dimensions',
            subtitle: 'Enter package size',
            badgeColor: badge,
            iconColor: iconColor,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
          ),
        ),
      ),
    );

    expect(find.text('01'), findsOneWidget);
    expect(find.text('Cargo dimensions'), findsOneWidget);
    expect(find.text('Enter package size'), findsOneWidget);

    final badgeBox = tester.widget<Container>(
      find
          .ancestor(of: find.text('01'), matching: find.byType(Container))
          .first,
    );
    expect(
      badgeBox.constraints,
      const BoxConstraints.tightFor(width: 42, height: 42),
    );
    expect(
      (badgeBox.decoration as BoxDecoration).borderRadius,
      BorderRadius.circular(13),
    );
    expect((badgeBox.decoration as BoxDecoration).color, badge);

    final icon = tester.widget<Icon>(find.byIcon(Icons.straighten_rounded));
    expect(icon.size, 19);
    expect(icon.color, iconColor);

    final title = tester.widget<Text>(find.text('Cargo dimensions'));
    expect(title.style!.color, titleColor);
    expect(title.style!.fontSize, 16.5);
    expect(title.style!.fontWeight, FontWeight.w800);

    final subtitle = tester.widget<Text>(find.text('Enter package size'));
    expect(subtitle.style!.color, subtitleColor);
    expect(subtitle.style!.fontSize, 10.5);
    expect(subtitle.style!.height, 1.35);
  });
}
