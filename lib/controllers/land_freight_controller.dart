import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/services/quote_service.dart';
import '../data/utils/form_submit_precheck.dart';
import '../data/utils/land_weight.dart';
import '../data/utils/quote_reference.dart';
import '../data/utils/value_formatters.dart';
import 'customer_quote_profile_mixin.dart';
import 'quote_controller.dart';

class LandFreightController extends GetxController
    with CustomerQuoteProfileMixin {
  LandFreightController(this._quoteService, this._quoteController);

  final QuoteService _quoteService;
  final QuoteController _quoteController;

  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final cargoController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final weightController = TextEditingController();
  final volumeController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final temperatureController = TextEditingController();
  final notesController = TextEditingController();

  final loadType = 'FTL'.obs;
  final weightUnit = 'KG'.obs;
  final serviceMode = 'Door to Door'.obs;
  final truckType = 'Recommend for Me'.obs;
  final packageType = 'Pallets'.obs;
  final readyDate = Rxn<DateTime>();
  final dangerousGoods = false.obs;
  final insuranceRequested = false.obs;
  final oversizedCargo = false.obs;
  final additionalServices = <String>{}.obs;

  final weightUnits = const ['KG', 'TON'];
  final serviceModes = const [
    'Door to Door',
    'Depot to Depot',
    'Door to Depot',
    'Depot to Door',
  ];
  final truckTypes = const [
    'Recommend for Me',
    'Curtain Side',
    'Box Truck',
    'Flatbed',
    'Reefer',
    'Lowbed',
  ];
  final packageTypes = const [
    'Pallets',
    'Boxes',
    'Crates',
    'Bags',
    'Loose Cargo',
  ];
  final availableServices = const [
    'Customs Clearance',
    'Pickup',
    'Delivery',
    'Border Documentation',
    'Loading / Unloading',
  ];

  QuoteController get quotes => _quoteController;

  List<Listenable> get summaryListenables => [
    originController,
    destinationController,
    quantityController,
    weightController,
    volumeController,
    lengthController,
    widthController,
    heightController,
    temperatureController,
  ];

  double currentVolume() {
    return double.tryParse(volumeController.text.trim()) ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    for (final controller in [
      lengthController,
      widthController,
      heightController,
      quantityController,
    ]) {
      addManagedListener(controller, calculateVolume);
    }
  }

  void calculateVolume() {
    if (loadType.value != 'LTL') return;
    final length = double.tryParse(lengthController.text.trim()) ?? 0;
    final width = double.tryParse(widthController.text.trim()) ?? 0;
    final height = double.tryParse(heightController.text.trim()) ?? 0;
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    if (length <= 0 || width <= 0 || height <= 0 || quantity <= 0) return;
    final value = ((length * width * height * quantity) / 1000000)
        .toStringAsFixed(3);
    if (volumeController.text != value) {
      volumeController.text = value;
    }
  }

  void observeForm() {
    loadType.value;
    weightUnit.value;
    serviceMode.value;
    truckType.value;
    packageType.value;
    readyDate.value;
    dangerousGoods.value;
    insuranceRequested.value;
    oversizedCargo.value;
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
    final enteredWeight = double.parse(weightController.text.trim());
    final weight = landWeightKg(
      enteredWeight: enteredWeight,
      unit: weightUnit.value,
    );
    final temperature = truckType.value == 'Reefer'
        ? double.tryParse(temperatureController.text.trim())
        : null;
    final isLtl = loadType.value == 'LTL';
    return {
      ...customerPayload(userId),
      'quoteNumber': quoteNumber,
      'requestType': 'quote',
      'serviceType': 'Land Freight',
      'from': originController.text.trim(),
      'to': destinationController.text.trim(),
      'origin': originController.text.trim(),
      'destination': destinationController.text.trim(),
      'pickupLocation': originController.text.trim(),
      'deliveryLocation': destinationController.text.trim(),
      'serviceMode': serviceMode.value,
      'loadType': loadType.value,
      'shipmentType': loadType.value,
      'truckType': truckType.value,
      'trailerType': truckType.value,
      'packageType': isLtl ? packageType.value : null,
      'quantity': quantity,
      'numberOfTrucks': loadType.value == 'FTL' ? quantity : null,
      'pieces': isLtl ? quantity : null,
      'temperatureControlled': truckType.value == 'Reefer',
      'targetTemperatureC': temperature,
      'cargoType': cargoController.text.trim(),
      'cargo': cargoController.text.trim(),
      'enteredWeight': enteredWeight,
      'weightUnit': weightUnit.value,
      'weightKg': weight,
      'grossWeightKg': weight,
      'volumeCbm': currentVolume(),
      'lengthCm': isLtl ? parseOptionalDouble(lengthController.text) : null,
      'widthCm': isLtl ? parseOptionalDouble(widthController.text) : null,
      'heightCm': isLtl ? parseOptionalDouble(heightController.text) : null,
      'dangerousGoods': dangerousGoods.value,
      'oversizedCargo': oversizedCargo.value,
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
    final length = double.tryParse(lengthController.text.trim()) ?? 0;
    final width = double.tryParse(widthController.text.trim()) ?? 0;
    final height = double.tryParse(heightController.text.trim()) ?? 0;
    final blocked = formSubmitPrecheck(
      alreadySubmitting: _quoteController.isSubmitting.value,
      formValid: formValid,
      signedIn: _quoteController.currentUser != null,
      requireDate: true,
      date: readyDate.value,
      dimensionsOk:
          loadType.value != 'LTL' || (length > 0 && width > 0 && height > 0),
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
      cargoController,
      quantityController,
      weightController,
      volumeController,
      lengthController,
      widthController,
      heightController,
      temperatureController,
      notesController,
    ]);
    super.onClose();
  }
}
