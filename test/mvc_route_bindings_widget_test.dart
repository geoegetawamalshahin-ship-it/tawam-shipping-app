import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tawam_shipping_app/constant/app_routes.dart';
import 'package:tawam_shipping_app/controllers/booking_controller.dart';
import 'package:tawam_shipping_app/controllers/create_booking_form_controller.dart';
import 'package:tawam_shipping_app/controllers/get_quote_form_controller.dart';
import 'package:tawam_shipping_app/controllers/quote_controller.dart';
import 'package:tawam_shipping_app/controllers/track_shipment_controller.dart';
import 'package:tawam_shipping_app/data/services/booking_service.dart';
import 'package:tawam_shipping_app/data/services/quote_service.dart';
import 'package:tawam_shipping_app/data/services/shipment_service.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/page_bindings.dart';
import 'package:tawam_shipping_app/pages/create_booking_screen.dart';
import 'package:tawam_shipping_app/pages/get_quote_screen.dart';
import 'package:tawam_shipping_app/pages/track_shipment_screen.dart';

class _FakeQuoteService extends Fake implements QuoteService {
  @override
  User? get currentUser => null;
}

class _FakeBookingService extends Fake implements BookingService {
  @override
  User? get currentUser => null;
}

class _FakeShipmentService extends Fake implements ShipmentService {
  @override
  User? get currentUser => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.put<QuoteService>(_FakeQuoteService());
    Get.put(QuoteController(Get.find<QuoteService>()));
    Get.put<BookingService>(_FakeBookingService());
    Get.put(BookingController(Get.find<BookingService>()));
    Get.put<ShipmentService>(_FakeShipmentService());
  });

  tearDown(Get.reset);

  testWidgets(
    'GetMaterialApp bindings pass quote dimensions, booking type, and tracking number',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/hub',
          getPages: [
            GetPage(
              name: '/hub',
              page: () => const Scaffold(body: SizedBox.shrink()),
            ),
            GetPage(
              name: AppRoutes.getQuote,
              page: () => const GetQuoteScreen(),
              binding: GetQuoteBinding(),
            ),
            GetPage(
              name: AppRoutes.createBooking,
              page: () => const CreateBookingScreen(),
              binding: CreateBookingBinding(),
            ),
            GetPage(
              name: AppRoutes.trackShipment,
              page: () => const TrackShipmentScreen(),
              binding: TrackShipmentBinding(),
            ),
          ],
        ),
      );
      await tester.pump();

      Get.toNamed(
        AppRoutes.getQuote,
        arguments: {
          'serviceType': 'Air Freight',
          'lengthCm': '120',
          'widthCm': '80',
          'heightCm': '60',
          'quantity': '3',
          'weightKg': '25.5',
        },
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final quotes = Get.find<GetQuoteFormController>();
      expect(quotes.selectedService.value, 'Air Freight');
      expect(quotes.lengthController.text, '120');
      expect(quotes.widthController.text, '80');
      expect(quotes.heightController.text, '60');
      expect(quotes.quantityController.text, '3');
      expect(quotes.weightController.text, '25.5');
      expect(find.text('Air Freight'), findsWidgets);
      expect(find.text('120'), findsWidgets);
      expect(find.text('80'), findsWidgets);
      expect(find.text('60'), findsWidgets);
      expect(find.text('25.5'), findsWidgets);

      Get.back();
      await tester.pump();

      Get.toNamed(AppRoutes.createBooking, arguments: 'Air Freight');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final bookings = Get.find<CreateBookingFormController>();
      expect(bookings.selectedService.value, 'Air Freight');
      expect(find.text('Air Freight'), findsWidgets);

      Get.back();
      await tester.pump();

      Get.toNamed(AppRoutes.trackShipment, arguments: ' tw-abc-1 ');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final tracking = Get.find<TrackShipmentController>();
      expect(tracking.trackingController.text, 'TW-ABC-1');
      expect(find.text('TW-ABC-1'), findsWidgets);
    },
  );
}
