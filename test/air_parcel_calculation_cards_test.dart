import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tawam_shipping_app/controllers/air_freight_controller.dart';
import 'package:tawam_shipping_app/controllers/parcel_shipping_controller.dart';
import 'package:tawam_shipping_app/controllers/quote_controller.dart';
import 'package:tawam_shipping_app/data/services/quote_service.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/pages/air_freight_screen.dart';
import 'package:tawam_shipping_app/pages/parcel_shipping_screen.dart';

class _FakeQuoteService extends Fake implements QuoteService {
  @override
  User? get currentUser => null;
}

Finder _field(TextEditingController controller) {
  return find.byWidgetPredicate(
    (widget) => widget is EditableText && widget.controller == controller,
  );
}

Finder _mainScrollable() {
  return find.byType(Scrollable).first;
}

Future<void> _type(
  WidgetTester tester,
  TextEditingController controller,
  String value,
) async {
  final field = _field(controller);
  await tester.scrollUntilVisible(field, 400, scrollable: _mainScrollable());
  await tester.enterText(field, value);
  await tester.pump();
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 400, scrollable: _mainScrollable());
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeQuoteService quotes;

  setUp(() {
    quotes = _FakeQuoteService();
    Get.put<QuoteService>(quotes);
    Get.put(QuoteController(quotes));
  });

  tearDown(Get.reset);

  Future<void> pumpLocalized(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets(
    'AirFreightScreen calculation card and summary update from weight pieces and dimensions',
    (tester) async {
      Get.put(AirFreightController(quotes, Get.find<QuoteController>()));
      await pumpLocalized(tester, const AirFreightScreen());

      final air = Get.find<AirFreightController>();
      expect(air.packageType.value, 'Boxes');

      await _type(tester, air.piecesController, '2');
      await _type(tester, air.weightController, '10');
      await _type(tester, air.lengthController, '60');
      await _type(tester, air.widthController, '50');
      await _type(tester, air.heightController, '40');

      expect(air.packageType.value, 'Boxes');

      await _reveal(tester, find.text('Cargo volume: 0.240 CBM'));
      expect(find.text('10 KG'), findsWidgets);
      expect(find.text('40 KG'), findsWidgets);
      expect(find.text('Cargo volume: 0.240 CBM'), findsOneWidget);

      await _reveal(tester, find.text('2 Number of Pieces'));
      expect(find.text('2 Number of Pieces'), findsOneWidget);
      expect(find.text('40 KG'), findsWidgets);
      expect(air.packageType.value, 'Boxes');
    },
  );

  testWidgets(
    'ParcelShippingScreen calculation card and summary update from weight count and dimensions',
    (tester) async {
      Get.put(ParcelShippingController(quotes, Get.find<QuoteController>()));
      await pumpLocalized(tester, const ParcelShippingScreen());

      final parcel = Get.find<ParcelShippingController>();
      expect(parcel.packageType.value, 'Box');
      expect(parcel.serviceLevel.value, 'Express');

      await _type(tester, parcel.parcelCountController, '2');
      await _type(tester, parcel.weightController, '10');
      await _type(tester, parcel.lengthController, '60');
      await _type(tester, parcel.widthController, '50');
      await _type(tester, parcel.heightController, '40');

      expect(parcel.packageType.value, 'Box');
      expect(parcel.serviceLevel.value, 'Express');

      await _reveal(
        tester,
        find.text('Total volume: 0.240 CBM • Final carrier formula may vary.'),
      );
      expect(find.text('20 KG'), findsWidgets);
      expect(find.text('48 KG'), findsWidgets);
      expect(
        find.text('Total volume: 0.240 CBM • Final carrier formula may vary.'),
        findsOneWidget,
      );

      await _reveal(tester, find.text('2 Parcels'));
      expect(find.text('2 Parcels'), findsOneWidget);
      expect(find.text('48 KG'), findsWidgets);
      expect(parcel.packageType.value, 'Box');
      expect(parcel.serviceLevel.value, 'Express');
    },
  );
}
