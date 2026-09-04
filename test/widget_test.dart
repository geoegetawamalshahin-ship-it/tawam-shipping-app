import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/responsive_app_frame.dart';
import 'package:tawam_shipping_app/core/firestore_collections.dart';
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

    expect(FirestoreCollections.users, 'users');
    expect(FirestoreCollections.shipments, 'shipments');
    expect(FirestoreCollections.quoteRequests, 'quote_requests');
    expect(FirestoreCollections.shipmentRequests, 'shipment_requests');
    expect(FirestoreCollections.supportRequests, 'support_requests');
    expect(FirestoreCollections.notifications, 'notifications');

    const remainingCollections = <String>{
      'quotes',
      'account_deletion_requests',
    };

    for (final collection in remainingCollections) {
      expect(
        source,
        contains(".collection('$collection')"),
        reason: 'Firestore collection $collection must remain compatible.',
      );
    }

    expect(source, contains(".from('shipping-documents')"));
  });

  testWidgets('responsive frame leaves phone width unchanged', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final childKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponsiveAppFrame(
            child: SizedBox.expand(key: childKey),
          ),
        ),
      ),
    );

    final box = childKey.currentContext!.findRenderObject()! as RenderBox;
    expect(box.size.width, 390);
  });

  testWidgets('responsive frame caps wide tablet content', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final childKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponsiveAppFrame(
            child: SizedBox.expand(key: childKey),
          ),
        ),
      ),
    );

    final box = childKey.currentContext!.findRenderObject()! as RenderBox;
    expect(box.size.width, ResponsiveAppFrame.maxContentWidth);
  });

}
