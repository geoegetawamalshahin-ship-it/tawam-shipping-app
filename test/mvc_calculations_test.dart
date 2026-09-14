import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/controllers/volume_calculator_controller.dart';
import 'package:tawam_shipping_app/data/models/form_submit_outcome.dart';
import 'package:tawam_shipping_app/data/utils/form_submit_precheck.dart';
import 'package:tawam_shipping_app/data/utils/land_weight.dart';
import 'package:tawam_shipping_app/data/utils/moving_services.dart';
import 'package:tawam_shipping_app/data/utils/volume_math.dart';
import 'package:tawam_shipping_app/widgets/auth_password_field.dart';
import 'package:tawam_shipping_app/widgets/profile_chrome.dart';
import 'package:tawam_shipping_app/widgets/support_quick_contact_card.dart';

void main() {
  test('form submit precheck blocks a second submit', () {
    final blocked = formSubmitPrecheck(
      alreadySubmitting: true,
      formValid: true,
      signedIn: true,
    );
    expect(blocked, isNotNull);
    expect(blocked!.error, FormSubmitError.submitting);
  });

  test(
    'form submit precheck validates form, date, dimensions, and session',
    () {
      expect(
        formSubmitPrecheck(
          alreadySubmitting: false,
          formValid: false,
          signedIn: true,
        )!.error,
        FormSubmitError.invalidForm,
      );
      expect(
        formSubmitPrecheck(
          alreadySubmitting: false,
          formValid: true,
          signedIn: true,
          requireDate: true,
        )!.error,
        FormSubmitError.missingDate,
      );
      expect(
        formSubmitPrecheck(
          alreadySubmitting: false,
          formValid: true,
          signedIn: true,
          dimensionsOk: false,
        )!.error,
        FormSubmitError.missingDimensions,
      );
      expect(
        formSubmitPrecheck(
          alreadySubmitting: false,
          formValid: true,
          signedIn: false,
        )!.error,
        FormSubmitError.unsigned,
      );
      expect(
        formSubmitPrecheck(
          alreadySubmitting: false,
          formValid: true,
          signedIn: true,
          requireDate: true,
          date: DateTime(2026, 9, 14),
        ),
        isNull,
      );
    },
  );

  test('land TON weight is converted to kilograms', () {
    expect(landWeightKg(enteredWeight: 2, unit: 'TON'), 2000);
    expect(landWeightKg(enteredWeight: 250, unit: 'KG'), 250);
  });

  test(
    'parcel chargeable weight uses the greater of actual and volumetric',
    () {
      const count = 2;
      const length = 40.0;
      const width = 30.0;
      const height = 20.0;
      const actualPerParcel = 1.0;
      final volumetric = airVolumetricWeightKg(
        lengthCm: length,
        widthCm: width,
        heightCm: height,
        pieces: count,
        divisor: 5000,
      );
      final actual = actualPerParcel * count;
      expect(volumetric, closeTo(9.6, 0.0001));
      expect(
        chargeableWeightKg(actual: actual, volumetric: volumetric),
        closeTo(9.6, 0.0001),
      );
      expect(chargeableWeightKg(actual: 20, volumetric: volumetric), 20);
    },
  );

  test('international moving combines flags and extra services', () {
    expect(
      combinedMovingServices(
        packingRequired: true,
        unpackingRequired: false,
        furnitureDisassembly: true,
        storageRequired: false,
        insuranceRequested: true,
        additionalServices: const ['Customs Clearance'],
      ),
      [
        'Professional Packing',
        'Furniture Disassembly',
        'Moving Insurance',
        'Customs Clearance',
      ],
    );
  });

  test('volume calculator controller disposes input controllers', () {
    final controller = VolumeCalculatorController();
    controller.lengthController.text = '10';
    controller.onClose();
    expect(() => controller.lengthController.text = '1', throwsFlutterError);
  });

  testWidgets('extracted support, profile, and auth widgets are usable', (
    tester,
  ) async {
    var tapped = false;
    final password = TextEditingController();
    addTearDown(password.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SupportQuickContactCard(
                icon: Icons.phone,
                label: 'Call',
                subtitle: 'Support',
                color: Colors.blue,
                background: Colors.blue.shade50,
                onTap: () => tapped = true,
              ),
              const ProfileSectionTitle(eyebrow: 'ACCOUNT', title: 'Profile'),
              const ProfileHeaderMetric(value: '3', label: 'Shipments'),
              AuthPasswordField(
                controller: password,
                hintText: 'Password',
                obscureText: true,
                onToggleVisibility: () {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Call'));
    expect(tapped, isTrue);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Shipments'), findsOneWidget);
    expect(find.byType(AuthPasswordField), findsOneWidget);
  });
}
