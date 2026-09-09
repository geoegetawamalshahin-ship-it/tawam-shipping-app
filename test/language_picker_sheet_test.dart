import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/language_picker_sheet.dart';

void main() {
  const languages = ['English', 'Arabic'];

  Future<void> pumpHost(
    WidgetTester tester, {
    required String currentLanguage,
    required Color accentColor,
    required void Function(String? selected) onClosed,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  final selected = await showLanguagePickerSheet(
                    context: context,
                    title: 'Application language',
                    languages: languages,
                    currentLanguage: currentLanguage,
                    languageLabel: (language) =>
                        language == 'Arabic' ? 'العربية' : 'English',
                    textColor: const Color(0xFF111827),
                    accentColor: accentColor,
                    unselectedBorderColor: const Color(0xFFE4EAF1),
                    selectedFillColor: const Color(0xFFEAF4FF),
                    unselectedFillColor: const Color(0xFFF7F9FC),
                    selectedBorderColor: const Color(0xFFB9D8F3),
                  );
                  onClosed(selected);
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('home-style current value shows English selected first', (
    tester,
  ) async {
    String? result;
    await pumpHost(
      tester,
      currentLanguage: 'English',
      accentColor: const Color(0xFF0B4F9C),
      onClosed: (selected) => result = selected,
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Application language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    final englishRow = find.ancestor(
      of: find.text('English'),
      matching: find.byType(InkWell),
    );
    expect(
      find.descendant(
        of: englishRow,
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.language_rounded).first).color,
      const Color(0xFF0B4F9C),
    );
    expect(result, isNull);
  });

  testWidgets('profile-style current value shows Arabic selected', (
    tester,
  ) async {
    await pumpHost(
      tester,
      currentLanguage: 'Arabic',
      accentColor: const Color(0xFF0B5FB3),
      onClosed: (_) {},
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final arabicRow = find.ancestor(
      of: find.text('العربية'),
      matching: find.byType(InkWell),
    );
    expect(
      find.descendant(
        of: arabicRow,
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.check_circle_rounded)).color,
      const Color(0xFF0B5FB3),
    );
  });

  testWidgets('choosing another language pops that stored name', (
    tester,
  ) async {
    String? result;
    await pumpHost(
      tester,
      currentLanguage: 'English',
      accentColor: const Color(0xFF0B4F9C),
      onClosed: (selected) => result = selected,
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(result, 'Arabic');
    expect(find.text('Application language'), findsNothing);
  });

  testWidgets('choosing the current language still returns it', (tester) async {
    String? result;
    await pumpHost(
      tester,
      currentLanguage: 'English',
      accentColor: const Color(0xFF0B4F9C),
      onClosed: (selected) => result = selected,
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(result, 'English');
  });

  testWidgets('dismissing the sheet without a choice returns null', (
    tester,
  ) async {
    String? result = 'unset';
    await pumpHost(
      tester,
      currentLanguage: 'Arabic',
      accentColor: const Color(0xFF0B5FB3),
      onClosed: (selected) => result = selected,
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text('Application language'), findsNothing);
  });
}
