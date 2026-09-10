import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/counted_section_header.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();

  testWidgets('keeps page titles and shows the count', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CountedSectionHeader(
            title: en.shipmentPortfolio,
            subtitle: en.selectShipmentDetails,
            count: 4,
          ),
        ),
      ),
    );

    expect(find.text(en.shipmentPortfolio), findsOneWidget);
    expect(find.text(en.selectShipmentDetails), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('support history keeps its own copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CountedSectionHeader(
            title: en.supportHistory,
            subtitle: en.tapAnyCase,
            count: 0,
          ),
        ),
      ),
    );

    expect(find.text(en.supportHistory), findsOneWidget);
    expect(find.text(en.tapAnyCase), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
