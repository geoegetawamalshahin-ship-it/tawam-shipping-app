import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/soft_back_header.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();

  testWidgets('get-quote metrics stay on the shared header', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SoftBackHeader(
            title: en.getAQuoteTitle,
            subtitle: en.tawamAlShahinTransport,
            trailingIcon: Icons.verified_outlined,
            onBack: () {},
            height: 82,
            shadowColor: const Color(0xFF062B55),
            shadowAlpha: .07,
            shadowBlur: 20,
            shadowOffset: const Offset(0, 6),
            borderColor: const Color(0xFFE3EAF2),
            backIconColor: const Color(0xFF062B55),
            backIconSize: 23,
            titleColor: const Color(0xFF111827),
            titleFontWeight: FontWeight.w800,
            titleLetterSpacing: -0.3,
            subtitleColor: const Color(0xFF0B4F9C),
            subtitleFontSize: 9.5,
            subtitleFontWeight: FontWeight.w700,
            trailingBackground: const Color(0xFFEAF3FF),
            trailingIconColor: const Color(0xFF0B4F9C),
            trailingIconSize: 23,
          ),
        ),
      ),
    );

    expect(find.byType(SoftBackHeader), findsOneWidget);
    expect(tester.getSize(find.byType(SoftBackHeader)).height, 82);
    expect(
      tester.widget<Text>(find.text(en.getAQuoteTitle)).style?.letterSpacing,
      -0.3,
    );
    expect(tester.widget<Icon>(find.byIcon(Icons.verified_outlined)).size, 23);
  });

  testWidgets('support requests keep title size 19 and gap 13', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SoftBackHeader(
            title: en.mySupportRequests,
            subtitle: en.tawamAlShahinTransport,
            trailingIcon: Icons.support_agent_rounded,
            onBack: () {},
            height: 82,
            shadowColor: const Color(0xFF062B55),
            shadowAlpha: .06,
            shadowBlur: 20,
            shadowOffset: const Offset(0, 6),
            borderColor: const Color(0xFFE2EAF2),
            backIconColor: const Color(0xFF062B55),
            backIconSize: 22,
            leadingGap: 13,
            titleColor: const Color(0xFF101B2D),
            titleFontSize: 19,
            titleFontWeight: FontWeight.w900,
            titleLetterSpacing: -.35,
            subtitleColor: const Color(0xFF0B4F9C),
            subtitleFontSize: 9,
            subtitleFontWeight: FontWeight.w800,
            trailingBackground: const Color(0xFFEAF3FF),
            trailingIconColor: const Color(0xFF0B4F9C),
            trailingIconSize: 22,
          ),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text(en.mySupportRequests)).style?.fontSize,
      19,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 13,
      ),
      findsOneWidget,
    );
    expect(tester.widget<Icon>(find.byIcon(Icons.arrow_back_rounded)).size, 22);
  });
}
