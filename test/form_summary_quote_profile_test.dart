import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tawam_shipping_app/controllers/air_freight_controller.dart';
import 'package:tawam_shipping_app/controllers/auth_controller.dart';
import 'package:tawam_shipping_app/controllers/get_quote_form_controller.dart';
import 'package:tawam_shipping_app/controllers/land_freight_controller.dart';
import 'package:tawam_shipping_app/controllers/locale_controller.dart';
import 'package:tawam_shipping_app/controllers/profile_controller.dart';
import 'package:tawam_shipping_app/controllers/quote_controller.dart';
import 'package:tawam_shipping_app/data/models/form_submit_outcome.dart';
import 'package:tawam_shipping_app/data/services/auth_service.dart';
import 'package:tawam_shipping_app/data/services/profile_image_service.dart';
import 'package:tawam_shipping_app/data/services/quote_service.dart';
import 'package:tawam_shipping_app/widgets/shipping/form_summary_listener.dart';

class _FakeUser extends Fake implements User {
  _FakeUser(this.uid, {this.displayName, this.email});

  @override
  final String uid;
  @override
  final String? displayName;
  @override
  final String? email;

  @override
  String? get phoneNumber => null;
}

class _FakeQuoteService extends Fake implements QuoteService {
  User? user;
  Completer<Map<String, dynamic>>? profileGate;
  var createCalls = 0;

  @override
  User? get currentUser => user;

  @override
  Future<Map<String, dynamic>> loadUserProfile(String userId) {
    return profileGate!.future;
  }

  @override
  Future<DocumentReference<Map<String, dynamic>>> createQuoteRequest(
    Map<String, dynamic> data,
  ) async {
    createCalls += 1;
    throw StateError('quote saved');
  }
}

class _FakeAuthService extends Fake implements AuthService {}

class _FakeImages extends Fake implements ProfileImageService {}

class _FakeAuthController extends AuthController {
  _FakeAuthController() : super(_FakeAuthService());

  User? user;
  Completer<Map<String, dynamic>?>? documentGate;
  Completer<Map<String, int>>? statsGate;

  @override
  User? get currentUser => user;

  @override
  Future<Map<String, dynamic>?> loadUserDocument(String userId) {
    return documentGate!.future;
  }

  @override
  Future<Map<String, int>> loadProfileStats(String userId) {
    return statsGate!.future;
  }

  @override
  Uint8List? bytesFromProfilePhoto(dynamic value) => null;

  @override
  Future<Uint8List?> downloadProfilePhoto(String? path) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.reset();
    LocaleController.setLanguage('English');
  });

  testWidgets(
    'shipping summaries update as soon as origin destination weight and quantity change',
    (tester) async {
      final quotes = _FakeQuoteService();
      final air = AirFreightController(quotes, QuoteController(quotes));
      final land = LandFreightController(quotes, QuoteController(quotes));
      addTearDown(air.onClose);
      addTearDown(land.onClose);
      land.onInit();
      land.loadType.value = 'LTL';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  key: const Key('air-origin'),
                  controller: air.originController,
                ),
                TextField(
                  key: const Key('air-dest'),
                  controller: air.destinationController,
                ),
                TextField(
                  key: const Key('air-weight'),
                  controller: air.weightController,
                ),
                TextField(
                  key: const Key('air-pieces'),
                  controller: air.piecesController,
                ),
                FormSummaryListener(
                  listenables: air.summaryListenables,
                  builder: (_) => Text(
                    'air:${air.originController.text}|${air.destinationController.text}|${air.weightController.text}|${air.pieces}',
                  ),
                ),
                TextField(
                  key: const Key('land-origin'),
                  controller: land.originController,
                ),
                TextField(
                  key: const Key('land-qty'),
                  controller: land.quantityController,
                ),
                TextField(
                  key: const Key('land-weight'),
                  controller: land.weightController,
                ),
                TextField(
                  key: const Key('land-length'),
                  controller: land.lengthController,
                ),
                TextField(
                  key: const Key('land-width'),
                  controller: land.widthController,
                ),
                TextField(
                  key: const Key('land-height'),
                  controller: land.heightController,
                ),
                FormSummaryListener(
                  listenables: land.summaryListenables,
                  builder: (_) => Text(
                    'land:${land.originController.text}|${land.quantityController.text}|${land.weightController.text}|${land.volumeController.text}',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('air-origin')), 'Sharjah');
      await tester.enterText(find.byKey(const Key('air-dest')), 'Jeddah');
      await tester.enterText(find.byKey(const Key('air-weight')), '40');
      await tester.enterText(find.byKey(const Key('air-pieces')), '3');
      await tester.pump();
      expect(find.text('air:Sharjah|Jeddah|40|3'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('land-origin')), 'Dubai');
      await tester.enterText(find.byKey(const Key('land-qty')), '2');
      await tester.enterText(find.byKey(const Key('land-weight')), '18');
      await tester.enterText(find.byKey(const Key('land-length')), '100');
      await tester.enterText(find.byKey(const Key('land-width')), '100');
      await tester.enterText(find.byKey(const Key('land-height')), '100');
      await tester.pump();
      expect(find.text('land:Dubai|2|18|2.000'), findsOneWidget);
    },
  );

  test('two overlapping get-quote submits create only one request', () async {
    final quotes = _FakeQuoteService()
      ..user = _FakeUser('user-1', displayName: 'George', email: 'g@tawam.com')
      ..profileGate = Completer<Map<String, dynamic>>();
    final form = GetQuoteFormController(quotes, QuoteController(quotes));
    addTearDown(form.onClose);

    form.fromController.text = 'A';
    form.toController.text = 'B';
    form.cargoController.text = 'Boxes';
    form.weightController.text = '10';
    form.quantityController.text = '1';

    final first = form.submit(formValid: true);
    final second = form.submit(formValid: true);
    expect(form.isSubmitting.value, isTrue);

    quotes.profileGate!.complete({'name': 'George'});
    final firstOutcome = await first;
    final secondOutcome = await second;

    expect(firstOutcome.error, FormSubmitError.generic);
    expect(secondOutcome.error, FormSubmitError.submitting);
    expect(quotes.createCalls, 1);
  });

  test(
    'closing profile before load completes does not apply stale data',
    () async {
      final auth = _FakeAuthController()
        ..user = _FakeUser('a')
        ..documentGate = Completer<Map<String, dynamic>?>()
        ..statsGate = Completer<Map<String, int>>();
      final profile = ProfileController(
        auth,
        _FakeAuthService(),
        _FakeImages(),
      );

      final pendingProfile = profile.loadProfile();
      final pendingStats = profile.loadStats();
      profile.onClose();
      auth.documentGate!.complete({'name': 'Stale', 'language': 'Arabic'});
      auth.statsGate!.complete({
        'shipmentsCount': 9,
        'inTransitCount': 4,
        'quotesCount': 2,
      });
      await pendingProfile;
      await pendingStats;

      expect(profile.fullName.value, '');
      expect(profile.shipmentsCount.value, 0);
      expect(LocaleController.locale.value, const Locale('en'));
    },
  );

  test(
    'a slower previous profile load does not replace the current account',
    () async {
      final auth = _FakeAuthController()
        ..user = _FakeUser('a')
        ..documentGate = Completer<Map<String, dynamic>?>()
        ..statsGate = Completer<Map<String, int>>()
        ..statsGate!.complete({
          'shipmentsCount': 0,
          'inTransitCount': 0,
          'quotesCount': 0,
        });
      final profile = ProfileController(
        auth,
        _FakeAuthService(),
        _FakeImages(),
      );

      final firstDoc = auth.documentGate!;
      final first = profile.loadProfile();

      auth.user = _FakeUser('b');
      final secondDoc = Completer<Map<String, dynamic>?>();
      auth.documentGate = secondDoc;
      final second = profile.loadProfile(force: true);

      firstDoc.complete({'name': 'Alice', 'language': 'Arabic'});
      await first;
      expect(profile.fullName.value, isNot('Alice'));
      expect(LocaleController.locale.value, const Locale('en'));

      secondDoc.complete({'name': 'Bob', 'language': 'English'});
      await second;
      expect(profile.fullName.value, 'Bob');
    },
  );
}
