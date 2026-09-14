import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/services/quote_service.dart';
import '../data/utils/quote_reference.dart';
import '../data/utils/volume_math.dart';
import 'customer_quote_profile_mixin.dart';
import 'quote_controller.dart';

class AirFreightController extends GetxController
    with CustomerQuoteProfileMixin {
  AirFreightController(this._quoteService, this._quoteController);

  static const volumetricDivisor = 6000.0;

  final QuoteService _quoteService;
  final QuoteController _quoteController;

  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final cargoController = TextEditingController();
  final weightController = TextEditingController();
  final piecesController = TextEditingController(text: '1');
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final notesController = TextEditingController();

  final serviceMode = 'Door to Door'.obs;
  final airServiceType = 'Standard'.obs;
  final packageType = 'Boxes'.obs;
  final readyDate = Rxn<DateTime>();
  final dangerousGoods = false.obs;
  final insuranceRequested = false.obs;
  final additionalServices = <String>{}.obs;
  final revision = 0.obs;

  final serviceModes = const [
    'Door to Door',
    'Airport to Airport',
    'Door to Airport',
    'Airport to Door',
  ];

  final packageTypes = const ['Boxes', 'Pallets', 'Loose Cargo', 'Crates'];

  final availableServices = const [
    'Customs Clearance',
    'Pickup',
    'Delivery',
    'Export Documentation',
    'Packing',
  ];

  QuoteController get quotes => _quoteController;

  double get grossWeight => double.tryParse(weightController.text.trim()) ?? 0;

  int get pieces => int.tryParse(piecesController.text.trim()) ?? 0;

  double get length => double.tryParse(lengthController.text.trim()) ?? 0;

  double get width => double.tryParse(widthController.text.trim()) ?? 0;

  double get height => double.tryParse(heightController.text.trim()) ?? 0;

  double get volumeCbmValue => volumeCbm(
    lengthCm: length,
    widthCm: width,
    heightCm: height,
    pieces: pieces,
  );

  double get volumetricWeight => airVolumetricWeightKg(
    lengthCm: length,
    widthCm: width,
    heightCm: height,
    pieces: pieces,
    divisor: volumetricDivisor,
  );

  double get chargeableWeight => math.max(grossWeight, volumetricWeight);

  @override
  void onInit() {
    super.onInit();
    for (final controller in [
      weightController,
      piecesController,
      lengthController,
      widthController,
      heightController,
    ]) {
      controller.addListener(_bump);
    }
  }

  void _bump() => revision.value++;

  void observeForm() {
    serviceMode.value;
    airServiceType.value;
    packageType.value;
    readyDate.value;
    dangerousGoods.value;
    insuranceRequested.value;
    revision.value;
    additionalServices.length;
    loadingProfile.value;
    customerName.value;
    quotes.isSubmitting.value;
  }

  Future<void> loadProfile(String emptyNameFallback) {
    return loadCustomerProfile(
      readUserDocument: (uid) => _quoteService.loadUserProfile(uid),
      emptyNameFallback: emptyNameFallback,
    );
  }

  void toggleService(String service) {
    if (additionalServices.contains(service)) {
      additionalServices.remove(service);
    } else {
      additionalServices.add(service);
    }
    additionalServices.refresh();
  }

  Future<FormSubmitOutcome> submit({required bool formValid}) async {
    if (_quoteController.isSubmitting.value) {
      return const FormSubmitOutcome.failure(FormSubmitError.submitting);
    }
    if (!formValid) {
      return const FormSubmitOutcome.failure(FormSubmitError.invalidForm);
    }
    if (readyDate.value == null) {
      return const FormSubmitOutcome.failure(FormSubmitError.missingDate);
    }
    if (length <= 0 || width <= 0 || height <= 0) {
      return const FormSubmitOutcome.failure(FormSubmitError.missingDimensions);
    }

    final user = _quoteController.currentUser;
    if (user == null) {
      return const FormSubmitOutcome.failure(FormSubmitError.unsigned);
    }

    try {
      final quoteNumber = buildQuoteNumber();
      final quoteData = <String, dynamic>{
        ...customerPayload(user.uid),
        'quoteNumber': quoteNumber,
        'requestType': 'quote',
        'serviceType': 'Air Freight',
        'from': originController.text.trim(),
        'to': destinationController.text.trim(),
        'origin': originController.text.trim(),
        'destination': destinationController.text.trim(),
        'serviceMode': serviceMode.value,
        'airServiceType': airServiceType.value,
        'packageType': packageType.value,
        'cargoType': cargoController.text.trim(),
        'cargo': cargoController.text.trim(),
        'quantity': pieces,
        'pieces': pieces,
        'weightKg': grossWeight,
        'grossWeightKg': grossWeight,
        'lengthCm': length,
        'widthCm': width,
        'heightCm': height,
        'volumeCbm': volumeCbmValue,
        'volumetricWeightKg': volumetricWeight,
        'chargeableWeightKg': chargeableWeight,
        'dangerousGoods': dangerousGoods.value,
        'insuranceRequested': insuranceRequested.value,
        'additionalServices': additionalServices.toList(),
        'readyDate': Timestamp.fromDate(readyDate.value!),
        'pickupDate': Timestamp.fromDate(readyDate.value!),
        'notes': notesController.text.trim(),
        'status': 'new',
        'quotedPrice': null,
        'currency': 'AED',
        'adminNote': '',
        'adminUpdatedAt': null,
        'source': 'customer_app',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _quoteController.submitQuoteRequest(quoteData);
      return FormSubmitOutcome.success(reference: quoteNumber);
    } on FirebaseException catch (error) {
      return FormSubmitOutcome.failure(
        FormSubmitError.firebase,
        firebaseMessage: error.message,
      );
    } catch (_) {
      return const FormSubmitOutcome.failure(FormSubmitError.generic);
    }
  }

  @override
  void onClose() {
    disposeTextControllers([
      originController,
      destinationController,
      cargoController,
      weightController,
      piecesController,
      lengthController,
      widthController,
      heightController,
      notesController,
    ]);
    super.onClose();
  }
}
