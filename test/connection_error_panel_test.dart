import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/connection_error_panel.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();

  testWidgets('bookings and quotes keep their titles and body weight', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ConnectionErrorPanel(
            title: en.unableToLoadBookings,
            body: en.pleaseCheckConnectionTryAgain,
            retryLabel: en.tryAgain,
            onRetry: () => retried = true,
            borderColor: const Color(0xFFE3EAF2),
            titleColor: const Color(0xFF10233F),
            bodyColor: const Color(0xFF8793A4),
            accentColor: const Color(0xFF0B4F9C),
            bodyFontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    expect(find.text(en.unableToLoadBookings), findsOneWidget);
    expect(find.text(en.pleaseCheckConnectionTryAgain), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

    final body = tester.widget<Text>(
      find.text(en.pleaseCheckConnectionTryAgain),
    );
    expect(body.style?.fontWeight, FontWeight.w500);

    await tester.tap(find.text(en.tryAgain));
    expect(retried, isTrue);
  });

  testWidgets('quotes body stays regular weight', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConnectionErrorPanel(
            title: en.unableToLoadQuotations,
            body: en.pleaseCheckConnectionTryAgain,
            retryLabel: en.tryAgain,
            onRetry: () {},
            borderColor: const Color(0xFFE2E8F0),
            titleColor: const Color(0xFF101B2D),
            bodyColor: const Color(0xFF7E8A9A),
            accentColor: const Color(0xFF0B4F9C),
          ),
        ),
      ),
    );

    expect(find.text(en.unableToLoadQuotations), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.text(en.pleaseCheckConnectionTryAgain))
          .style
          ?.fontWeight,
      FontWeight.w400,
    );
  });
}
