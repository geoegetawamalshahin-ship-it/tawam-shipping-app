import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/services/quote_service.dart';
import '../data/utils/form_submit_precheck.dart';
import '../data/utils/quote_reference.dart';
import '../data/utils/volume_math.dart';
import 'customer_quote_profile_mixin.dart';
import 'quote_controller.dart';

class ParcelShippingController extends GetxController
    with CustomerQuoteProfileMixin {
  ParcelShippingController(this._quoteService, this._quoteController);

  static const volumetricDivisor = 5000.0;

  final QuoteService _quoteService;
  final QuoteController _quoteController;

  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final parcelCountController = TextEditingController(text: '1');
  final contentsController = TextEditingController();
  final weightController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final declaredValueController = TextEditingController();
  final notesController = TextEditingController();

  final serviceLevel = 'Express'.obs;
  final pickupMethod = 'Door Pickup'.obs;
  final packageType = 'Box'.obs;
  final declaredValueCurrency = 'AED'.obs;
  final readyDate = Rxn<DateTime>();
  final fragile = false.obs;
  final insuranceRequested = false.obs;
  final signatureRequired = false.obs;
  final additionalServices = <String>{}.obs;
  final revision = 0.obs;

  final pickupMethods = const ['Door Pickup', 'Drop-off'];
  final packageTypes = const [
    'Box',
    'Envelope / Document',
    'Padded Bag',
    'Tube',
    'Other',
  ];
  final currencies = const ['AED', 'USD', 'EUR'];
  final availableServices = const [
    'Customs Clearance',
    'Pickup',
    'Delivery',
    'Export Documentation',
    'Proof of Delivery',
  ];

  QuoteController get quotes => _quoteController;

  int get parcelCount {
    final value = int.tryParse(parcelCountController.text.trim());
    if (value == null || value <= 0) return 1;
    return value;
  }

  double get weightPerParcel =>
      double.tryParse(weightController.text.trim()) ?? 0;

  double get length => double.tryParse(lengthController.text.trim()) ?? 0;

  double get width => double.tryParse(widthController.text.trim()) ?? 0;

  double get height => double.tryParse(heightController.text.trim()) ?? 0;

  double get totalActualWeight => weightPerParcel * parcelCount;

  double get totalVolumeCbm => volumeCbm(
    lengthCm: length,
    widthCm: width,
    heightCm: height,
    pieces: parcelCount,
  );

  double get totalVolumetricWeight => airVolumetricWeightKg(
    lengthCm: length,
    widthCm: width,
    heightCm: height,
    pieces: parcelCount,
    divisor: volumetricDivisor,
  );

  double get chargeableWeight => chargeableWeightKg(
    actual: totalActualWeight,
    volumetric: totalVolumetricWeight,
  );

  double? get declaredValue {
    final text = declaredValueController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  @override
  void onInit() {
    super.onInit();
    for (final controller in [
      parcelCountController,
      weightController,
      lengthController,
      widthController,
      heightController,
    ]) {
      controller.addListener(() => revision.value++);
    }
  }

  void observeForm() {
    serviceLevel.value;
    pickupMethod.value;
    packageType.value;
    declaredValueCurrency.value;
    readyDate.value;
    fragile.value;
    insuranceRequested.value;
    signatureRequired.value;
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
    final contents = contentsController.text.trim();
    return {
      ...customerPayload(userId),
      'quoteNumber': quoteNumber,
      'requestType': 'quote',
      'serviceType': 'Parcel Shipping',
      'from': originController.text.trim(),
      'to': destinationController.text.trim(),
      'origin': originController.text.trim(),
      'destination': destinationController.text.trim(),
      'pickupLocation': originController.text.trim(),
      'deliveryLocation': destinationController.text.trim(),
      'parcelServiceType': serviceLevel.value,
      'serviceLevel': serviceLevel.value,
      'pickupMethod': pickupMethod.value,
      'packageType': packageType.value,
      'quantity': parcelCount,
      'pieces': parcelCount,
      'parcelCount': parcelCount,
      'contents': contents,
      'parcelContents': contents,
      'cargoType': contents,
      'cargo': contents,
      'weightPerParcelKg': weightPerParcel,
      'totalActualWeightKg': totalActualWeight,
      'weightKg': totalActualWeight,
      'grossWeightKg': totalActualWeight,
      'lengthCm': length,
      'widthCm': width,
      'heightCm': height,
      'volumeCbm': totalVolumeCbm,
      'volumetricDivisor': volumetricDivisor,
      'volumetricWeightKg': totalVolumetricWeight,
      'chargeableWeightKg': chargeableWeight,
      'declaredValue': declaredValue,
      'declaredValueCurrency': declaredValueCurrency.value,
      'fragile': fragile.value,
      'insuranceRequested': insuranceRequested.value,
      'signatureRequired': signatureRequired.value,
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
      dimensionsOk: length > 0 && width > 0 && height > 0,
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
      parcelCountController,
      contentsController,
      weightController,
      lengthController,
      widthController,
      heightController,
      declaredValueController,
      notesController,
    ]);
    super.onClose();
  }
}
