import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/services/quote_service.dart';
import '../data/utils/form_submit_precheck.dart';
import '../data/utils/quote_reference.dart';
import '../data/utils/value_formatters.dart';
import 'customer_quote_profile_mixin.dart';
import 'quote_controller.dart';

class SeaFreightController extends GetxController
    with CustomerQuoteProfileMixin {
  SeaFreightController(this._quoteService, this._quoteController);

  final QuoteService _quoteService;
  final QuoteController _quoteController;

  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final cargoController = TextEditingController();
  final weightController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final volumeController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final notesController = TextEditingController();

  final shipmentType = 'FCL'.obs;
  final serviceMode = 'Door to Door'.obs;
  final containerType = '40FT HC'.obs;
  final readyDate = Rxn<DateTime>();
  final dangerousGoods = false.obs;
  final insuranceRequested = false.obs;
  final additionalServices = <String>{}.obs;
  final revision = 0.obs;

  final serviceModes = const [
    'Door to Door',
    'Port to Port',
    'Door to Port',
    'Port to Door',
  ];

  final containerTypes = const [
    '20FT Standard',
    '40FT Standard',
    '40FT HC',
    '20FT Reefer',
    '40FT Reefer',
    'Open Top',
    'Flat Rack',
  ];

  final availableServices = const [
    'Customs Clearance',
    'Pickup',
    'Delivery',
    'Packing List Review',
  ];

  QuoteController get quotes => _quoteController;

  @override
  void onInit() {
    super.onInit();
    for (final controller in [
      lengthController,
      widthController,
      heightController,
      quantityController,
    ]) {
      controller.addListener(calculateVolume);
    }
  }

  void calculateVolume() {
    if (shipmentType.value != 'LCL') return;
    final length = double.tryParse(lengthController.text.trim()) ?? 0;
    final width = double.tryParse(widthController.text.trim()) ?? 0;
    final height = double.tryParse(heightController.text.trim()) ?? 0;
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    if (length <= 0 || width <= 0 || height <= 0 || quantity <= 0) return;
    final newValue = ((length * width * height * quantity) / 1000000)
        .toStringAsFixed(3);
    if (volumeController.text != newValue) {
      volumeController.text = newValue;
      revision.value++;
    }
  }

  void observeForm() {
    shipmentType.value;
    serviceMode.value;
    containerType.value;
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

  Map<String, dynamic> buildQuoteData({
    required String userId,
    required String quoteNumber,
  }) {
    final quantity = int.parse(quantityController.text.trim());
    final weight = double.parse(weightController.text.trim());
    final isLcl = shipmentType.value == 'LCL';
    return {
      ...customerPayload(userId),
      'quoteNumber': quoteNumber,
      'requestType': 'quote',
      'serviceType': 'Sea Freight',
      'from': originController.text.trim(),
      'to': destinationController.text.trim(),
      'origin': originController.text.trim(),
      'destination': destinationController.text.trim(),
      'serviceMode': serviceMode.value,
      'shipmentType': shipmentType.value,
      'containerType': shipmentType.value == 'FCL' ? containerType.value : null,
      'quantity': quantity,
      'cargoType': cargoController.text.trim(),
      'cargo': cargoController.text.trim(),
      'weightKg': weight,
      'volumeCbm': parseOptionalDouble(volumeController.text),
      'lengthCm': isLcl ? parseOptionalDouble(lengthController.text) : null,
      'widthCm': isLcl ? parseOptionalDouble(widthController.text) : null,
      'heightCm': isLcl ? parseOptionalDouble(heightController.text) : null,
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
    final user = _quoteController.currentUser!;
    try {
      final quoteNumber = buildQuoteNumber();
      final reference = await _quoteController.submitQuoteRequest(
        buildQuoteData(userId: user.uid, quoteNumber: quoteNumber),
      );
      return FormSubmitOutcome.success(
        reference: quoteNumber,
        documentId: reference.id,
      );
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
      quantityController,
      volumeController,
      lengthController,
      widthController,
      heightController,
      notesController,
    ]);
    super.onClose();
  }
}
