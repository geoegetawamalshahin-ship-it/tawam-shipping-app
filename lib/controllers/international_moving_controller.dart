import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/services/quote_service.dart';
import '../data/utils/form_submit_precheck.dart';
import '../data/utils/moving_services.dart';
import '../data/utils/quote_reference.dart';
import 'customer_quote_profile_mixin.dart';
import 'quote_controller.dart';

class InternationalMovingController extends GetxController
    with CustomerQuoteProfileMixin {
  InternationalMovingController(this._quoteService, this._quoteController);

  final QuoteService _quoteService;
  final QuoteController _quoteController;

  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final roomsController = TextEditingController(text: '2');
  final originFloorController = TextEditingController(text: '0');
  final destinationFloorController = TextEditingController(text: '0');
  final boxesController = TextEditingController(text: '10');
  final largeItemsController = TextEditingController(text: '5');
  final volumeController = TextEditingController();
  final notesController = TextEditingController();

  final moveType = 'Home Move'.obs;
  final propertyType = 'Apartment'.obs;
  final serviceMode = 'Door to Door'.obs;
  final movingDate = Rxn<DateTime>();
  final originElevator = true.obs;
  final destinationElevator = true.obs;
  final packingRequired = true.obs;
  final unpackingRequired = false.obs;
  final furnitureDisassembly = true.obs;
  final storageRequired = false.obs;
  final insuranceRequested = false.obs;
  final specialItems = <String>{}.obs;
  final additionalServices = <String>{}.obs;
  final revision = 0.obs;

  final propertyTypes = const [
    'Apartment',
    'Villa',
    'Townhouse',
    'Studio',
    'Office',
    'Warehouse',
    'Other',
  ];

  final serviceModes = const ['Door to Door', 'Door to Port', 'Port to Door'];

  final specialItemOptions = const [
    'Piano',
    'Safe',
    'Artwork',
    'Large Appliances',
    'Fragile Items',
    'High-Value Items',
  ];

  final additionalServiceOptions = const [
    'Customs Clearance',
    'Packing Materials',
    'Furniture Reassembly',
    'Debris Removal',
  ];

  QuoteController get quotes => _quoteController;

  int get roomsCount {
    final value = int.tryParse(roomsController.text.trim());
    if (value == null || value <= 0) return 1;
    return value;
  }

  int get boxCount {
    final value = int.tryParse(boxesController.text.trim());
    if (value == null || value < 0) return 0;
    return value;
  }

  int get largeItemsCount {
    final value = int.tryParse(largeItemsController.text.trim());
    if (value == null || value < 0) return 0;
    return value;
  }

  double get estimatedVolume =>
      double.tryParse(volumeController.text.trim()) ?? 0;

  List<String> get combinedServices => combinedMovingServices(
    packingRequired: packingRequired.value,
    unpackingRequired: unpackingRequired.value,
    furnitureDisassembly: furnitureDisassembly.value,
    storageRequired: storageRequired.value,
    insuranceRequested: insuranceRequested.value,
    additionalServices: additionalServices,
  );

  @override
  void onInit() {
    super.onInit();
    for (final controller in [
      roomsController,
      boxesController,
      largeItemsController,
      volumeController,
    ]) {
      controller.addListener(() => revision.value++);
    }
  }

  void observeForm() {
    moveType.value;
    propertyType.value;
    serviceMode.value;
    movingDate.value;
    originElevator.value;
    destinationElevator.value;
    packingRequired.value;
    unpackingRequired.value;
    furnitureDisassembly.value;
    storageRequired.value;
    insuranceRequested.value;
    revision.value;
    specialItems.length;
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
    final propertyDisplay = '${moveType.value} • ${propertyType.value}';
    final cargo = moveType.value == 'Office Move'
        ? 'Office Relocation'
        : 'Household Goods & Personal Effects';
    final volume = estimatedVolume > 0 ? estimatedVolume : null;
    return {
      ...customerPayload(userId),
      'quoteNumber': quoteNumber,
      'requestType': 'quote',
      'serviceType': 'International Moving',
      'from': originController.text.trim(),
      'to': destinationController.text.trim(),
      'origin': originController.text.trim(),
      'destination': destinationController.text.trim(),
      'pickupLocation': originController.text.trim(),
      'deliveryLocation': destinationController.text.trim(),
      'serviceMode': serviceMode.value,
      'moveType': moveType.value,
      'propertyType': propertyDisplay,
      'rawPropertyType': propertyType.value,
      'residenceType': propertyType.value,
      'rooms': roomsCount,
      'bedrooms': roomsCount,
      'roomCount': roomsCount,
      'floor': originFloorController.text.trim(),
      'floorNumber': originFloorController.text.trim(),
      'originFloor': originFloorController.text.trim(),
      'destinationFloor': destinationFloorController.text.trim(),
      'hasElevator': originElevator.value,
      'elevator': originElevator.value,
      'originElevator': originElevator.value,
      'destinationElevator': destinationElevator.value,
      'estimatedBoxes': boxCount,
      'boxCount': boxCount,
      'largeItemsCount': largeItemsCount,
      'estimatedVolumeCbm': volume,
      'volumeCbm': volume,
      'specialItems': specialItems.toList(),
      'cargoType': cargo,
      'cargo': cargo,
      'packingRequired': packingRequired.value,
      'packing': packingRequired.value,
      'unpackingRequired': unpackingRequired.value,
      'unpacking': unpackingRequired.value,
      'furnitureDisassembly': furnitureDisassembly.value,
      'disassemblyRequired': furnitureDisassembly.value,
      'storageRequired': storageRequired.value,
      'storage': storageRequired.value,
      'insuranceRequested': insuranceRequested.value,
      'insurance': insuranceRequested.value,
      'additionalServices': combinedServices,
      'movingDate': Timestamp.fromDate(movingDate.value!),
      'readyDate': Timestamp.fromDate(movingDate.value!),
      'pickupDate': Timestamp.fromDate(movingDate.value!),
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
      date: movingDate.value,
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
      roomsController,
      originFloorController,
      destinationFloorController,
      boxesController,
      largeItemsController,
      volumeController,
      notesController,
    ]);
    super.onClose();
  }
}
