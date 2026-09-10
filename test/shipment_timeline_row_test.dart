import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipment_status/timeline_row.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

Finder _connectorFinder() {
  return find.byWidgetPredicate((widget) {
    if (widget is! Container) return false;
    return widget.margin == const EdgeInsets.symmetric(vertical: 4) &&
        (widget.color == const Color(0xFFC7DDF1) ||
            widget.color == const Color(0xFFE3E8EE));
  });
}

Finder _contentPaddingFinder(double bottom) {
  return find.byWidgetPredicate((widget) {
    if (widget is! Padding) return false;
    return widget.padding == EdgeInsets.only(bottom: bottom, top: 2);
  });
}

Future<void> _pumpRow(
  WidgetTester tester, {
  required bool showLine,
  required double contentBottomPadding,
  bool completed = true,
  bool active = false,
  Color? activeColor,
}) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ShipmentTimelineRow(
          title: 'Created',
          description: 'Shipment registered',
          time: 'Yesterday',
          completed: completed,
          active: active,
          showLine: showLine,
          contentBottomPadding: contentBottomPadding,
          icon: Icons.inventory_2_outlined,
          activeColor: activeColor ?? const Color(0xFF0B4F9C),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('track last row hides line and bottom padding', (tester) async {
    await _pumpRow(
      tester,
      showLine: false,
      contentBottomPadding: 0,
      active: true,
    );

    expect(_connectorFinder(), findsNothing);
    expect(_contentPaddingFinder(0), findsOneWidget);
    expect(_contentPaddingFinder(18), findsNothing);
    expect(find.text(AppLocalizationsEn().currentBadge), findsOneWidget);
  });

  testWidgets('track non-last completed row shows line and 18 padding', (
    tester,
  ) async {
    await _pumpRow(tester, showLine: true, contentBottomPadding: 18);

    expect(_connectorFinder(), findsOneWidget);
    expect(
      tester.widget<Container>(_connectorFinder()).color,
      const Color(0xFFC7DDF1),
    );
    expect(_contentPaddingFinder(18), findsOneWidget);
    expect(find.text(AppLocalizationsEn().currentBadge), findsNothing);
  });

  testWidgets('details last row hides line but keeps 18 padding', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      showLine: false,
      contentBottomPadding: 18,
      active: true,
    );

    expect(_connectorFinder(), findsNothing);
    expect(_contentPaddingFinder(18), findsOneWidget);
    expect(_contentPaddingFinder(0), findsNothing);
  });

  testWidgets('waiting connector uses incomplete color', (tester) async {
    await _pumpRow(
      tester,
      showLine: true,
      contentBottomPadding: 18,
      completed: false,
      active: false,
    );

    expect(
      tester.widget<Container>(_connectorFinder()).color,
      const Color(0xFFE3E8EE),
    );

    final title = tester.widget<Text>(find.text('Created'));
    expect(title.style!.color, const Color(0xFF929BA8));
    expect(title.style!.fontSize, 12);
    expect(title.style!.fontWeight, FontWeight.w800);
  });

  testWidgets('keeps texts icon sizes and state colors', (tester) async {
    const danger = Color(0xFFD72638);
    await _pumpRow(
      tester,
      showLine: false,
      contentBottomPadding: 18,
      completed: false,
      active: true,
      activeColor: danger,
    );

    expect(find.text('Created'), findsOneWidget);
    expect(find.text('Shipment registered'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.inventory_2_outlined));
    expect(icon.size, 17);
    expect(icon.color, danger);

    final description = tester.widget<Text>(find.text('Shipment registered'));
    expect(description.style!.color, const Color(0xFF7E8A9A));
    expect(description.style!.fontSize, 9.7);
    expect(description.style!.height, 1.35);

    final time = tester.widget<Text>(find.text('Yesterday'));
    expect(time.style!.color, danger);
    expect(time.style!.fontSize, 8.7);
    expect(time.style!.fontWeight, FontWeight.w700);

    final badge = tester.widget<Text>(
      find.text(AppLocalizationsEn().currentBadge),
    );
    expect(badge.style!.color, danger);
    expect(badge.style!.fontSize, 7.5);
    expect(badge.style!.fontWeight, FontWeight.w900);
    expect(badge.style!.letterSpacing, .4);
  });
}
