import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/constant/app_routes.dart';
import 'package:tawam_shipping_app/controllers/auth_controller.dart';
import 'package:tawam_shipping_app/data/utils/form_initials.dart';
import 'package:tawam_shipping_app/routes.dart';

void main() {
  test('registered GetX pages point at lib/pages, not lib/screens', () {
    final routesSource = File('lib/routes.dart').readAsStringSync();
    expect(routesSource, contains("import 'pages/"));
    expect(routesSource.contains("import 'screens/"), isFalse);
    expect(File('lib/locale_controller.dart').existsSync(), isFalse);
    expect(File('lib/core/firestore_collections.dart').existsSync(), isFalse);
    expect(File('lib/services/auth_service.dart').existsSync(), isFalse);
    expect(File('lib/app/bindings/initial_binding.dart').existsSync(), isFalse);

    final names = appPages.map((page) => page.name).toSet();
    expect(
      names,
      containsAll(<String>[
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.home,
        AppRoutes.seaFreight,
        AppRoutes.landFreight,
        AppRoutes.carShipping,
        AppRoutes.parcelShipping,
        AppRoutes.internationalMoving,
        AppRoutes.getQuote,
        AppRoutes.createBooking,
        AppRoutes.trackShipment,
        AppRoutes.profile,
        AppRoutes.notifications,
        AppRoutes.shipmentDetails,
      ]),
    );
  });

  test('quote and booking bindings keep initial arguments on controllers', () {
    final bindings = File('lib/page_bindings.dart').readAsStringSync();
    expect(bindings, contains('initialServiceType:'));
    expect(bindings, contains("map['lengthCm']"));
    expect(bindings, contains("map['widthCm']"));
    expect(bindings, contains("map['heightCm']"));
    expect(bindings, contains("map['quantity']"));
    expect(bindings, contains("map['weightKg']"));
    expect(bindings, contains('initialTrackingNumber:'));
  });

  test('ignored widget constructors are gone from pages that use bindings', () {
    expect(
      File('lib/pages/get_quote_screen.dart').readAsStringSync(),
      isNot(contains('initialServiceType')),
    );
    expect(
      File('lib/pages/create_booking_screen.dart').readAsStringSync(),
      isNot(contains('initialServiceType')),
    );
    expect(
      File('lib/pages/track_shipment_screen.dart').readAsStringSync(),
      isNot(contains('initialTrackingNumber')),
    );
    expect(
      File('lib/pages/shipment_details_screen.dart').readAsStringSync(),
      isNot(contains('required this.shipment')),
    );
  });

  test('service type, dimensions, and tracking initials fill controllers', () {
    const services = [
      'Sea Freight',
      'Air Freight',
      'Land Freight',
      'Car Shipping',
      'International Moving',
      'Parcel Shipping',
    ];

    expect(resolvedServiceType(services, 'Air Freight'), 'Air Freight');
    expect(resolvedServiceType(services, ' unknown '), isNull);

    final length = TextEditingController();
    final width = TextEditingController();
    final height = TextEditingController();
    final weight = TextEditingController();
    final quantity = TextEditingController(text: '1');
    addTearDown(length.dispose);
    addTearDown(width.dispose);
    addTearDown(height.dispose);
    addTearDown(weight.dispose);
    addTearDown(quantity.dispose);

    applyQuoteDimensionInitials(
      lengthController: length,
      widthController: width,
      heightController: height,
      weightController: weight,
      quantityController: quantity,
      lengthCm: '120',
      widthCm: '80',
      heightCm: '60',
      weightKg: '25.5',
      quantity: '3',
    );

    expect(length.text, '120');
    expect(width.text, '80');
    expect(height.text, '60');
    expect(weight.text, '25.5');
    expect(quantity.text, '3');

    final tracking = TextEditingController();
    addTearDown(tracking.dispose);
    applyInitialTrackingNumber(tracking, ' tw-abc-1 ');
    expect(tracking.text, 'TW-ABC-1');
  });

  test('password and deletion errors map to UI codes', () {
    expect(
      AuthController.credentialErrorCode('wrong-password'),
      'wrong-password',
    );
    expect(
      AuthController.credentialErrorCode('invalid-credential'),
      'wrong-password',
    );
    expect(
      AuthController.credentialErrorCode('weak-password'),
      'weak-password',
    );
    expect(
      AuthController.credentialErrorCode('requires-recent-login'),
      'requires-recent-login',
    );
    expect(
      AuthController.credentialErrorCode('network-request-failed'),
      'generic',
    );
  });
}
