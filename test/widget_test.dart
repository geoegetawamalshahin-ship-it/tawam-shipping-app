import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/locale_controller.dart';

void main() {
  testWidgets('Material smoke test does not require Firebase', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Tawam'),
        ),
      ),
    );

    expect(find.text('Tawam'), findsOneWidget);
  });

  test('Arabic and English remain the supported application locales', () {
    expect(
      AppLocalizations.supportedLocales,
      const <Locale>[Locale('ar'), Locale('en')],
    );
  });

  test('language switching preserves the existing locale mapping', () {
    addTearDown(() => LocaleController.setLanguage('English'));

    LocaleController.setLanguage('Arabic');
    expect(LocaleController.locale.value, const Locale('ar'));

    LocaleController.setLanguage('English');
    expect(LocaleController.locale.value, const Locale('en'));
  });

  test('backend collection and storage contracts remain unchanged', () {
    final source = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    const collections = <String>{
      'users',
      'shipments',
      'quote_requests',
      'quotes',
      'shipment_requests',
      'support_requests',
      'notifications',
      'account_deletion_requests',
    };

    for (final collection in collections) {
      expect(
        source,
        contains(".collection('$collection')"),
        reason: 'Firestore collection $collection must remain compatible.',
      );
    }

    expect(source, contains(".from('shipping-documents')"));
  });
}
