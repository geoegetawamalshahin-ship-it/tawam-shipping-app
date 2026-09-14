import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/services/quote_service.dart';
import '../data/utils/form_submit_precheck.dart';
import '../data/utils/quote_reference.dart';
import 'customer_quote_profile_mixin.dart';
import 'quote_controller.dart';

class CarShippingController extends GetxController
    with CustomerQuoteProfileMixin {
  CarShippingController(this._quoteService, this._quoteController);

  final QuoteService _quoteService;
  final QuoteController _quoteController;

  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final vehicleCountController = TextEditingController(text: '1');
  final makeController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final vinController = TextEditingController();
  final vehicleValueController = TextEditingController();
  final notesController = TextEditingController();

  final serviceMode = 'Door to Door'.obs;
  final shippingMethod = 'Open Carrier'.obs;
  final vehicleType = 'SUV'.obs;
  final vehicleCondition = 'Running'.obs;
  final valueCurrency = 'AED'.obs;
  final readyDate = Rxn<DateTime>();
  final insuranceRequested = false.obs;
  final priorityHandling = false.obs;
  final additionalServices = <String>{}.obs;
  final revision = 0.obs;

  final serviceModes = const [
    'Door to Door',
    'Port to Port',
    'Door to Port',
    'Port to Door',
  ];

  final vehicleTypes = const [
    'Sedan',
    'SUV',
    'Pickup',
    'Van',
    'Motorcycle',
    'Luxury / Classic',
    'Commercial Vehicle',
    'Other',
  ];

  final vehicleConditions = const [
    'Running',
    'Non-Running',
    'Damaged / Accident',
  ];

  final currencies = const ['AED', 'USD', 'EUR'];

  final availableServices = const [
    'Pickup',
    'Delivery',
    'Customs Clearance',
    'Export Documentation',
    'Vehicle Inspection',
  ];

  QuoteController get quotes => _quoteController;

  int get vehicleCount {
    final value = int.tryParse(vehicleCountController.text.trim());
    if (value == null || value <= 0) return 1;
    return value;
  }

  @override
  void onInit() {
    super.onInit();
    for (final controller in [
      vehicleCountController,
      makeController,
      modelController,
      yearController,
    ]) {
      controller.addListener(() => revision.value++);
    }
  }

  void observeForm() {
    serviceMode.value;
    shippingMethod.value;
    vehicleType.value;
    vehicleCondition.value;
    valueCurrency.value;
    readyDate.value;
    insuranceRequested.value;
    priorityHandling.value;
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

  Map<String, dynamic> buildQuoteData({
    required String userId,
    required String quoteNumber,
  }) {
    final vehicleValue = vehicleValueController.text.trim().isEmpty
        ? null
        : double.tryParse(vehicleValueController.text.trim());
    final cargo =
        '${vehicleType.value} • ${makeController.text.trim()} ${modelController.text.trim()}';
    return {
      ...customerPayload(userId),
      'quoteNumber': quoteNumber,
      'requestType': 'quote',
      'serviceType': 'Car Shipping',
      'from': originController.text.trim(),
      'to': destinationController.text.trim(),
      'origin': originController.text.trim(),
      'destination': destinationController.text.trim(),
      'pickupLocation': originController.text.trim(),
      'deliveryLocation': destinationController.text.trim(),
      'serviceMode': serviceMode.value,
      'shippingMethod': shippingMethod.value,
      'vehicleType': vehicleType.value,
      'vehicleCount': vehicleCount,
      'quantity': vehicleCount,
      'vehicleMake': makeController.text.trim(),
      'make': makeController.text.trim(),
      'vehicleModel': modelController.text.trim(),
      'model': modelController.text.trim(),
      'vehicleYear': int.parse(yearController.text.trim()),
      'year': int.parse(yearController.text.trim()),
      'vehicleCondition': vehicleCondition.value,
      'isRunning': vehicleCondition.value == 'Running',
      'specialLoadingRequired': vehicleCondition.value != 'Running',
      'vin': vinController.text.trim(),
      'chassisNumber': vinController.text.trim(),
      'vehicleValue': vehicleValue,
      'vehicleValueCurrency': valueCurrency.value,
      'insuranceRequested': insuranceRequested.value,
      'priorityHandling': priorityHandling.value,
      'additionalServices': additionalServices.toList(),
      'cargoType': cargo,
      'cargo': cargo,
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
  }

  Future<FormSubmitOutcome> submit({required bool formValid}) async {
    final blocked = formSubmitPrecheck(
      alreadySubmitting: _quoteController.isSubmitting.value,
      formValid: formValid,
      signedIn: _quoteController.currentUser != null,
      requireDate: true,
      date: readyDate.value,
    );
    if (blocked != null) return blocked;
    try {
      final quoteNumber = buildQuoteNumber();
      await _quoteController.submitQuoteRequest(
        buildQuoteData(
          userId: _quoteController.currentUser!.uid,
          quoteNumber: quoteNumber,
        ),
      );
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
      vehicleCountController,
      makeController,
      modelController,
      yearController,
      vinController,
      vehicleValueController,
      notesController,
    ]);
    super.onClose();
  }
}
