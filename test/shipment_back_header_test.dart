import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipment_status/back_header.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

Future<void> _pumpHeader(
  WidgetTester tester, {
  required String title,
  required IconData trailingIcon,
  double trailingIconSize = 22,
  VoidCallback? onBack,
}) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ShipmentBackHeader(
          title: title,
          subtitle: AppLocalizationsEn().tawamAlShahinTransport,
          trailingIcon: trailingIcon,
          trailingIconSize: trailingIconSize,
          onBack: onBack ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('keeps page titles and trailing icons', (tester) async {
    await _pumpHeader(
      tester,
      title: 'Shipment tracking',
      trailingIcon: Icons.location_searching_rounded,
      trailingIconSize: 23,
    );

    expect(find.text('Shipment tracking'), findsOneWidget);
    expect(
      find.text(AppLocalizationsEn().tawamAlShahinTransport),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.byIcon(Icons.location_searching_rounded), findsOneWidget);

    final trailing = tester.widget<Icon>(
      find.byIcon(Icons.location_searching_rounded),
    );
    expect(trailing.size, 23);
  });

  testWidgets('details and shipments keep trailing icon size 22', (
    tester,
  ) async {
    await _pumpHeader(
      tester,
      title: 'Shipment details',
      trailingIcon: Icons.local_shipping_rounded,
    );

    expect(
      tester.widget<Icon>(find.byIcon(Icons.local_shipping_rounded)).size,
      22,
    );
  });

  testWidgets('back still pops via onBack', (tester) async {
    var tapped = false;
    await _pumpHeader(
      tester,
      title: 'Support',
      trailingIcon: Icons.support_agent_rounded,
      trailingIconSize: 23,
      onBack: () => tapped = true,
    );

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    expect(tapped, isTrue);
  });
}
