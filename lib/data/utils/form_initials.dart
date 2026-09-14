import 'package:flutter/widgets.dart';

String? resolvedServiceType(List<String> services, String? initialServiceType) {
  final initial = initialServiceType?.trim();
  if (initial != null && services.contains(initial)) {
    return initial;
  }
  return null;
}

void applyOptionalText(TextEditingController controller, String? value) {
  final text = value?.trim() ?? '';
  if (text.isNotEmpty) {
    controller.text = text;
  }
}

void applyQuoteDimensionInitials({
  required TextEditingController lengthController,
  required TextEditingController widthController,
  required TextEditingController heightController,
  required TextEditingController weightController,
  required TextEditingController quantityController,
  String? lengthCm,
  String? widthCm,
  String? heightCm,
  String? weightKg,
  String? quantity,
}) {
  lengthController.text = lengthCm?.trim() ?? '';
  widthController.text = widthCm?.trim() ?? '';
  heightController.text = heightCm?.trim() ?? '';
  weightController.text = weightKg?.trim() ?? '';
  applyOptionalText(quantityController, quantity);
}

void applyInitialTrackingNumber(
  TextEditingController controller,
  String? trackingNumber,
) {
  final initial = trackingNumber?.trim().toUpperCase();
  if (initial != null && initial.isNotEmpty) {
    controller.text = initial;
  }
}
