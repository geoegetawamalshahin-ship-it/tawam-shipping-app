import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/legal/document_chrome.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();

  testWidgets('privacy and terms headers keep distinct copy and icons', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LegalDocumentHeader(
            barTitle: en.privacyPolicy,
            heroTitle: en.privacyPolicy,
            subtitle: en.privacyHeroSubtitle,
            heroIcon: Icons.shield_outlined,
            onBack: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text(en.privacyPolicy), findsNWidgets(2));
    expect(find.text(en.privacyHeroSubtitle), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    expect(tapped, isTrue);
  });

  testWidgets('section cards keep body text and optional bullets', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              LegalSectionCard(
                number: '01',
                icon: Icons.apartment_rounded,
                title: 'About',
                text: 'Terms body',
              ),
              LegalSectionCard(
                number: '02',
                icon: Icons.person_outline_rounded,
                title: 'Collect',
                text: 'Privacy body',
                bullets: ['Name', 'Email'],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Terms body'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
  });
}
