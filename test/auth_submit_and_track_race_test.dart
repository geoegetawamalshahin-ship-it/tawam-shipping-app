import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tawam_shipping_app/controllers/auth_controller.dart';
import 'package:tawam_shipping_app/controllers/auth_form_controllers.dart';
import 'package:tawam_shipping_app/controllers/track_shipment_controller.dart';
import 'package:tawam_shipping_app/data/services/auth_service.dart';
import 'package:tawam_shipping_app/data/services/shipment_service.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/pages/login_screen.dart';

class _FakeAuthService extends Fake implements AuthService {}

class _HangingAuthController extends AuthController {
  _HangingAuthController() : super(_FakeAuthService());

  var signInCalls = 0;
  final signInGate = Completer<UserCredential>();

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    signInCalls += 1;
    return signInGate.future;
  }
}

class _UnusedShipmentService extends Fake implements ShipmentService {}

class _TrackHarness extends TrackShipmentController {
  _TrackHarness() : super(_UnusedShipmentService());

  final lookups = <Completer<TrackedShipmentMatch?>>[];
  final watchIds = <String>[];

  @override
  String? get activeUserId => 'user-1';

  @override
  Future<TrackedShipmentMatch?> lookupShipment({
    required String userId,
    required String trackingNumber,
  }) {
    final completer = Completer<TrackedShipmentMatch?>();
    lookups.add(completer);
    return completer.future;
  }

  @override
  Stream<TrackedShipmentMatch?> watchShipment(String documentId) {
    watchIds.add(documentId);
    return const Stream<TrackedShipmentMatch?>.empty();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets(
    'repeated login taps do not show a false credential error or extra request',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
          return;
        }
        previousOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousOnError);

      final auth = _HangingAuthController();
      Get.put<AuthController>(auth);
      Get.put(LoginFormController(auth));

      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      );
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'user@tawam.com');
      await tester.enterText(fields.at(1), 'secret1');
      await tester.showKeyboard(fields.at(1));

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(auth.signInCalls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Email or password is incorrect'), findsNothing);

      final submit = find.byType(ElevatedButton);
      await tester.ensureVisible(submit);
      await tester.tap(submit, warnIfMissed: false);
      await tester.pump();

      expect(auth.signInCalls, 1);
      expect(find.text('Email or password is incorrect'), findsNothing);
    },
  );

  test(
    'closing track before lookup completes never starts a subscription',
    () async {
      final controller = _TrackHarness();

      controller.trackingController.text = 'TW-1';
      final pending = controller.track();
      expect(controller.lookups, hasLength(1));

      controller.onClose();
      controller.lookups.single.complete(
        const TrackedShipmentMatch(
          id: 'doc-1',
          data: {'trackingNumber': 'TW-1'},
        ),
      );
      await pending;

      expect(controller.watchIds, isEmpty);
      expect(controller.subscriptionForTest, isNull);
    },
  );

  test(
    'a slower earlier search does not replace the latest track result',
    () async {
      final controller = _TrackHarness();
      addTearDown(controller.onClose);

      controller.trackingController.text = 'OLD';
      final first = controller.track();
      controller.trackingController.text = 'NEW';
      final second = controller.track();
      expect(controller.lookups, hasLength(2));

      controller.lookups[0].complete(
        const TrackedShipmentMatch(
          id: 'old-id',
          data: {'trackingNumber': 'OLD'},
        ),
      );
      await first;

      expect(controller.shipment.value, isNull);
      expect(controller.watchIds, isEmpty);
      expect(controller.isSearching.value, isTrue);

      controller.lookups[1].complete(
        const TrackedShipmentMatch(
          id: 'new-id',
          data: {'trackingNumber': 'NEW'},
        ),
      );
      await second;

      expect(controller.shipment.value?['id'], 'new-id');
      expect(controller.shipment.value?['trackingNumber'], 'NEW');
      expect(controller.watchIds, ['new-id']);
    },
  );
}
