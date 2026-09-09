import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/quote_success_dialog.dart';

void main() {
  for (final language in ['en', 'ar']) {
    testWidgets('success dialog preserves reference and separate actions in $language', (tester) async {
      var quotes = 0;
      var done = 0;
      await tester.pumpWidget(MaterialApp(
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ShippingQuoteSuccessDialog(
          quoteNumber: 'TEST-123', onViewQuotes: () => quotes++, onDone: () => done++,
          deepBlue: Colors.blue, success: Colors.green, textDark: Colors.black,
          textGrey: Colors.grey, softGrey: Colors.white, border: Colors.grey,
          primaryBlue: Colors.blue,
        )),
      ));
      await tester.pumpAndSettle();
      expect(find.text('TEST-123'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(quotes, 1);
      expect(done, 0);
      await tester.tap(find.byType(OutlinedButton));
      expect(done, 1);
      expect(quotes, 1);
    });
  }
}
