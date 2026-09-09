import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/quote_success_dialog.dart';

void main() {
  for (final language in ['en', 'ar']) {
    testWidgets(
      'success dialog preserves reference and separate actions in $language',
      (tester) async {
        var quotes = 0;
        var done = 0;
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ShippingQuoteSuccessDialog(
                quoteNumber: 'TEST-123',
                onViewQuotes: () => quotes++,
                onDone: () => done++,
                deepBlue: Colors.blue,
                success: Colors.green,
                textDark: Colors.black,
                textGrey: Colors.grey,
                softGrey: Colors.white,
                border: Colors.grey,
                primaryBlue: Colors.blue,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('TEST-123'), findsOneWidget);
        await tester.tap(find.byType(ElevatedButton));
        expect(quotes, 1);
        expect(done, 0);
        await tester.tap(find.byType(OutlinedButton));
        expect(done, 1);
        expect(quotes, 1);
      },
    );
  }

  testWidgets(
    'land-style showDialog ignores barrier taps and keeps Done independent',
    (tester) async {
      var quotes = 0;
      var done = 0;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => ShippingQuoteSuccessDialog(
                        quoteNumber: 'LAND-1',
                        onViewQuotes: () => quotes++,
                        onDone: () {
                          done++;
                          Navigator.pop(dialogContext);
                        },
                        deepBlue: Colors.blue,
                        success: Colors.green,
                        textDark: Colors.black,
                        textGrey: Colors.grey,
                        softGrey: Colors.white,
                        border: Colors.grey,
                        primaryBlue: Colors.blue,
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('LAND-1'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.text('LAND-1'), findsOneWidget);
      expect(quotes, 0);
      expect(done, 0);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      expect(done, 1);
      expect(quotes, 0);
      expect(find.text('LAND-1'), findsNothing);
    },
  );

  testWidgets('air-style Done stays unstyled and independent of My Quotes', (
    tester,
  ) async {
    var quotes = 0;
    var done = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ShippingQuoteSuccessDialog(
            quoteNumber: 'AIR-1',
            onViewQuotes: () => quotes++,
            onDone: () => done++,
            deepBlue: Colors.blue,
            success: Colors.green,
            textDark: Colors.black,
            textGrey: Colors.grey,
            softGrey: Colors.white,
            border: Colors.grey,
            primaryBlue: Colors.blue,
            unstyledDoneButton: true,
          ),
        ),
      ),
    );

    final doneButton = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );
    expect(doneButton.style, isNull);
    expect(tester.widget<Text>(find.text('DONE')).style, isNull);

    await tester.tap(find.byType(OutlinedButton));
    expect(done, 1);
    expect(quotes, 0);
  });

  testWidgets('sea-style My Quotes keeps letterSpacing .35', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ShippingQuoteSuccessDialog(
            quoteNumber: 'SEA-1',
            onViewQuotes: () {},
            onDone: () {},
            deepBlue: Colors.blue,
            success: Colors.green,
            textDark: Colors.black,
            textGrey: Colors.grey,
            softGrey: Colors.white,
            border: Colors.grey,
            primaryBlue: Colors.blue,
            myQuotesLetterSpacing: .35,
          ),
        ),
      ),
    );

    final quotesLabel = tester.widget<Text>(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(Text),
      ),
    );
    expect(quotesLabel.style?.letterSpacing, .35);

    final doneButton = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );
    expect(doneButton.style, isNotNull);
  });
}
