import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/controllers/volume_calculator_controller.dart';
import 'package:tawam_shipping_app/data/utils/quote_reference.dart';
import 'package:tawam_shipping_app/data/utils/volume_math.dart';

void main() {
  test('volume formulas match the previous calculator screen', () {
    final result = calculateShippingVolume(
      lengthCm: 100,
      widthCm: 80,
      heightCm: 50,
      quantity: 2,
      actualWeightKg: 40,
    );

    expect(result.hasCalculated, isTrue);
    expect(result.cbm, closeTo(0.8, 0.0001));
    expect(result.airVolumetricWeight, closeTo(800000 / 6000, 0.0001));
    expect(result.courierVolumetricWeight, closeTo(800000 / 5000, 0.0001));
    expect(result.chargeableAirWeight, closeTo(800000 / 6000, 0.0001));
  });

  test('volume calculator ignores incomplete dimensions', () {
    final result = calculateShippingVolume(
      lengthCm: 0,
      widthCm: 80,
      heightCm: 50,
      quantity: 1,
      actualWeightKg: 10,
    );
    expect(result.hasCalculated, isFalse);
    expect(result.cbm, 0);
  });

  test('chargeable air weight uses the greater of actual and volumetric', () {
    final result = calculateShippingVolume(
      lengthCm: 10,
      widthCm: 10,
      heightCm: 10,
      quantity: 1,
      actualWeightKg: 50,
    );
    expect(result.airVolumetricWeight, closeTo(1000 / 6000, 0.0001));
    expect(result.chargeableAirWeight, 50);
  });

  test('quote and booking references keep the previous format', () {
    final stamp = DateTime(2026, 9, 14, 12, 5, 7);
    expect(buildQuoteNumber(stamp), 'QR-20260914-120507');
    expect(buildBookingReference(stamp), 'BK-20260914-120507');
  });

  test('volume calculator controller clears results on reset', () {
    final controller = VolumeCalculatorController();
    controller.lengthController.text = '100';
    controller.widthController.text = '100';
    controller.heightController.text = '100';
    controller.quantityController.text = '1';
    controller.actualWeightController.text = '10';
    controller.calculateLive();
    expect(controller.result.value.hasCalculated, isTrue);

    controller.reset();
    expect(controller.result.value.hasCalculated, isFalse);
    expect(controller.quantityController.text, '1');
    controller.onClose();
  });
}
