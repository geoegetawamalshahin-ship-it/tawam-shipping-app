import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/list_empty_card.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();

  testWidgets('bookings empty card keeps full width and title weight 900', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListEmptyCard(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
            borderColor: const Color(0xFFE3EAF2),
            icon: Icons.event_note_outlined,
            iconColor: const Color(0xFF0B4F9C),
            iconSize: 45,
            afterIconGap: 13,
            title: en.noBookingsFound,
            titleColor: const Color(0xFF10233F),
            titleFontWeight: FontWeight.w900,
            afterTitleGap: 6,
            body: en.bookingsEmptyBody,
            bodyColor: const Color(0xFF8793A4),
            bodyFontSize: 11,
          ),
        ),
      ),
    );

    final card = tester.widget<Container>(find.byType(Container));
    expect(card.constraints?.maxWidth, double.infinity);
    expect(
      card.padding,
      const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
    );
    expect(
      (card.decoration! as BoxDecoration).borderRadius,
      BorderRadius.circular(22),
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.event_note_outlined)).size,
      45,
    );
    expect(
      tester.widget<Text>(find.text(en.noBookingsFound)).style?.fontWeight,
      FontWeight.w900,
    );
    expect(
      tester.widget<Text>(find.text(en.bookingsEmptyBody)).style?.height,
      isNull,
    );
    expect(
      tester.widget<Text>(find.text(en.bookingsEmptyBody)).style?.fontSize,
      11,
    );
  });

  testWidgets('quotes empty card keeps top margin and title weight 800', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListEmptyCard(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 38),
            borderColor: const Color(0xFFE2E8F0),
            icon: Icons.request_quote_outlined,
            iconColor: const Color(0xFF0B4F9C),
            iconSize: 42,
            afterIconGap: 14,
            title: en.noQuotationsYet,
            titleColor: const Color(0xFF101B2D),
            titleFontWeight: FontWeight.w800,
            afterTitleGap: 7,
            body: en.quotationsEmptyBody,
            bodyColor: const Color(0xFF7E8A9A),
            bodyFontSize: 11,
            bodyHeight: 1.4,
          ),
        ),
      ),
    );

    final card = tester.widget<Container>(find.byType(Container));
    expect(card.constraints, isNull);
    expect(card.margin, const EdgeInsets.only(top: 12));
    expect(
      tester.widget<Icon>(find.byIcon(Icons.request_quote_outlined)).size,
      42,
    );
    expect(
      tester.widget<Text>(find.text(en.noQuotationsYet)).style?.fontWeight,
      FontWeight.w800,
    );
    expect(
      tester.widget<Text>(find.text(en.quotationsEmptyBody)).style?.height,
      1.4,
    );
  });

  testWidgets('support empty card keeps grey icon and body 10.5', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListEmptyCard(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 42),
            borderColor: const Color(0xFFE2EAF2),
            icon: Icons.support_agent_outlined,
            iconColor: const Color(0xFF9BA6B4),
            iconSize: 45,
            afterIconGap: 14,
            title: en.noSupportRequestsFound,
            titleColor: const Color(0xFF101B2D),
            titleFontWeight: FontWeight.w900,
            afterTitleGap: 6,
            body: en.supportRequestsEmptyBody,
            bodyColor: const Color(0xFF7E8A9A),
            bodyFontSize: 10.5,
            bodyHeight: 1.4,
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.support_agent_outlined));
    expect(icon.size, 45);
    expect(icon.color, const Color(0xFF9BA6B4));
    expect(
      tester
          .widget<Text>(find.text(en.supportRequestsEmptyBody))
          .style
          ?.fontSize,
      10.5,
    );
  });
}
