import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/action_success_dialog.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();

  testWidgets('booking-style dialog keeps radius 27 and pending chip', (
    tester,
  ) async {
    var done = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ActionSuccessDialog(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            borderRadius: 27,
            shadowColor: const Color(0x2E062B55),
            shadowBlur: 30,
            shadowOffset: const Offset(0, 12),
            iconCircleSize: 74,
            iconCircleColor: const Color(0xFFEAF3FF),
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF0B4F9C),
            iconSize: 44,
            afterIconGap: 18,
            title: en.bookingRequestSubmitted,
            titleColor: const Color(0xFF101B2D),
            titleFontSize: 20,
            titleFontWeight: FontWeight.w900,
            afterTitleGap: 9,
            body: en.bookingSentToTawam,
            bodyColor: const Color(0xFF7E8A9A),
            bodyFontSize: 11.5,
            bodyHeight: 1.45,
            bodyFontWeight: FontWeight.w500,
            afterBodyGap: 18,
            middle: const Text('TW-BOOK-1'),
            afterMiddleGap: 18,
            buttonHeight: 52,
            buttonColor: const Color(0xFF062B55),
            buttonRadius: 16,
            buttonLabel: en.doneUpper,
            buttonFontWeight: FontWeight.w900,
            onDone: () => done++,
          ),
        ),
      ),
    );

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.backgroundColor, Colors.transparent);
    expect(dialog.insetPadding, const EdgeInsets.symmetric(horizontal: 24));

    final card = tester.widget<Container>(
      find
          .descendant(of: find.byType(Dialog), matching: find.byType(Container))
          .first,
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(27));
    expect(decoration.boxShadow!.single.blurRadius, 30);

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.check_circle_rounded)).size,
      44,
    );
    expect(find.text('TW-BOOK-1'), findsOneWidget);

    final title = tester.widget<Text>(find.text(en.bookingRequestSubmitted));
    expect(title.style?.fontWeight, FontWeight.w900);
    expect(title.style?.fontSize, 20);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.style?.elevation?.resolve({}), 0);
    expect(button.style?.backgroundColor?.resolve({}), const Color(0xFF062B55));

    await tester.tap(find.byType(ElevatedButton));
    expect(done, 1);
  });

  testWidgets(
    'request-quote-style dialog keeps check_rounded and Done size 15',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ActionSuccessDialog(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              borderRadius: 28,
              shadowColor: const Color(0x26000000),
              shadowBlur: 35,
              shadowOffset: const Offset(0, 16),
              iconCircleSize: 72,
              iconCircleColor: const Color(0xFFE8F7F1),
              icon: Icons.check_rounded,
              iconColor: const Color(0xFF16765C),
              iconSize: 38,
              afterIconGap: 20,
              title: en.quoteRequestSubmitted,
              titleColor: const Color(0xFF10233F),
              titleFontSize: 22,
              titleFontWeight: FontWeight.w800,
              afterTitleGap: 10,
              body: en.quotePreparedSuccess,
              bodyColor: const Color(0xFF8B95A3),
              bodyFontSize: 13.5,
              bodyHeight: 1.55,
              afterBodyGap: 22,
              middle: const Text('Dubai → Paris'),
              afterMiddleGap: 22,
              buttonHeight: 54,
              buttonColor: const Color(0xFF07569E),
              buttonRadius: 17,
              buttonLabel: en.done,
              buttonFontWeight: FontWeight.w800,
              buttonFontSize: 15,
              onDone: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(tester.widget<Icon>(find.byIcon(Icons.check_rounded)).size, 38);

      final body = tester.widget<Text>(find.text(en.quotePreparedSuccess));
      expect(body.style?.fontWeight, isNull);
      expect(body.style?.height, 1.55);
      expect(body.style?.fontSize, 13.5);

      final label = tester.widget<Text>(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.byType(Text),
        ),
      );
      expect(label.data, en.done);
      expect(label.style?.fontSize, 15);
      expect(label.style?.fontWeight, FontWeight.w800);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(
        button.style?.minimumSize?.resolve({})?.height ??
            tester.getSize(find.byType(ElevatedButton)).height,
        54,
      );
    },
  );

  testWidgets('page showDialog ignores barrier taps', (tester) async {
    var done = 0;

    await tester.pumpWidget(
      MaterialApp(
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
                    builder: (dialogContext) => ActionSuccessDialog(
                      padding: const EdgeInsets.fromLTRB(24, 27, 24, 23),
                      borderRadius: 28,
                      shadowColor: const Color(0x26000000),
                      shadowBlur: 38,
                      shadowOffset: const Offset(0, 18),
                      iconCircleSize: 74,
                      iconCircleColor: const Color(0xFFEAF8F0),
                      icon: Icons.check_rounded,
                      iconColor: const Color(0xFF16765C),
                      iconSize: 39,
                      afterIconGap: 19,
                      title: en.requestSuccessfullySent,
                      titleColor: const Color(0xFF101B2D),
                      titleFontSize: 21,
                      titleFontWeight: FontWeight.w900,
                      afterTitleGap: 9,
                      body: en.supportCaseSubmitted,
                      bodyColor: const Color(0xFF7E8A9A),
                      bodyFontSize: 12,
                      bodyHeight: 1.5,
                      afterBodyGap: 18,
                      middle: const Text('Billing'),
                      afterMiddleGap: 20,
                      buttonHeight: 52,
                      buttonColor: const Color(0xFF0B4F9C),
                      buttonRadius: 15,
                      buttonLabel: en.doneUpper,
                      buttonFontWeight: FontWeight.w900,
                      buttonFontSize: 11,
                      buttonLetterSpacing: .5,
                      onDone: () {
                        done++;
                        Navigator.pop(dialogContext);
                      },
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
    expect(find.text('Billing'), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('Billing'), findsOneWidget);
    expect(done, 0);

    final label = tester.widget<Text>(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(Text),
      ),
    );
    expect(label.style?.fontSize, 11);
    expect(label.style?.letterSpacing, .5);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(done, 1);
    expect(find.text('Billing'), findsNothing);
  });
}
