import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/utils/volume_math.dart';

class VolumeCalculatorController extends GetxController {
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final actualWeightController = TextEditingController();

  final result = const VolumeCalculatorResult.empty().obs;

  @override
  void onInit() {
    super.onInit();
    for (final controller in [
      lengthController,
      widthController,
      heightController,
      quantityController,
      actualWeightController,
    ]) {
      controller.addListener(calculateLive);
    }
  }

  void calculateLive() {
    result.value = calculateShippingVolume(
      lengthCm: double.tryParse(lengthController.text.trim()) ?? 0,
      widthCm: double.tryParse(widthController.text.trim()) ?? 0,
      heightCm: double.tryParse(heightController.text.trim()) ?? 0,
      quantity: int.tryParse(quantityController.text.trim()) ?? 0,
      actualWeightKg: double.tryParse(actualWeightController.text.trim()) ?? 0,
    );
  }

  void reset() {
    lengthController.clear();
    widthController.clear();
    heightController.clear();
    quantityController.text = '1';
    actualWeightController.clear();
    result.value = const VolumeCalculatorResult.empty();
  }

  @override
  void onClose() {
    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();
    quantityController.dispose();
    actualWeightController.dispose();
    super.onClose();
  }
}
