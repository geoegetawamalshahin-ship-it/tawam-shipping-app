class VolumeCalculatorResult {
  const VolumeCalculatorResult({
    required this.cbm,
    required this.airVolumetricWeight,
    required this.courierVolumetricWeight,
    required this.chargeableAirWeight,
    required this.hasCalculated,
  });

  const VolumeCalculatorResult.empty()
    : cbm = 0,
      airVolumetricWeight = 0,
      courierVolumetricWeight = 0,
      chargeableAirWeight = 0,
      hasCalculated = false;

  final double cbm;
  final double airVolumetricWeight;
  final double courierVolumetricWeight;
  final double chargeableAirWeight;
  final bool hasCalculated;
}

/// Matches the existing volume calculator screen formulas.
VolumeCalculatorResult calculateShippingVolume({
  required double lengthCm,
  required double widthCm,
  required double heightCm,
  required int quantity,
  required double actualWeightKg,
}) {
  if (lengthCm <= 0 || widthCm <= 0 || heightCm <= 0 || quantity <= 0) {
    return const VolumeCalculatorResult.empty();
  }

  final totalCubicCm = lengthCm * widthCm * heightCm * quantity;
  final cbm = totalCubicCm / 1000000;
  final airVolWeight = totalCubicCm / 6000;
  final courierVolWeight = totalCubicCm / 5000;
  final chargeable = actualWeightKg > airVolWeight
      ? actualWeightKg
      : airVolWeight;

  return VolumeCalculatorResult(
    cbm: cbm,
    airVolumetricWeight: airVolWeight,
    courierVolumetricWeight: courierVolWeight,
    chargeableAirWeight: chargeable,
    hasCalculated: true,
  );
}

double airVolumetricWeightKg({
  required double lengthCm,
  required double widthCm,
  required double heightCm,
  required int pieces,
  double divisor = 6000,
}) {
  if (lengthCm <= 0 || widthCm <= 0 || heightCm <= 0 || pieces <= 0) {
    return 0;
  }
  return (lengthCm * widthCm * heightCm * pieces) / divisor;
}

double volumeCbm({
  required double lengthCm,
  required double widthCm,
  required double heightCm,
  required int pieces,
}) {
  if (lengthCm <= 0 || widthCm <= 0 || heightCm <= 0 || pieces <= 0) {
    return 0;
  }
  return (lengthCm * widthCm * heightCm * pieces) / 1000000;
}

double chargeableWeightKg({
  required double actual,
  required double volumetric,
}) {
  return actual > volumetric ? actual : volumetric;
}
