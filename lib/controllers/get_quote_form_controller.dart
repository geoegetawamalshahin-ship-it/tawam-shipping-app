import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/services/quote_service.dart';
import '../data/utils/form_initials.dart';
import '../data/utils/form_submit_precheck.dart';
import '../data/utils/quote_reference.dart';
import '../data/utils/value_formatters.dart';
import 'quote_controller.dart';

class GetQuoteFormController extends GetxController {
  GetQuoteFormController(
    this._quoteService,
    this._quoteController, {
    this.initialServiceType,
    this.initialLengthCm,
    this.initialWidthCm,
    this.initialHeightCm,
    this.initialQuantity,
    this.initialWeightKg,
  });

  final QuoteService _quoteService;
  final QuoteController _quoteController;

  final String? initialServiceType;
  final String? initialLengthCm;
  final String? initialWidthCm;
  final String? initialHeightCm;
  final String? initialQuantity;
  final String? initialWeightKg;

  final fromController = TextEditingController();
  final toController = TextEditingController();
  final cargoController = TextEditingController();
  final weightController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final notesController = TextEditingController();

  final services = const [
    'Sea Freight',
    'Air Freight',
    'Land Freight',
    'Car Shipping',
    'International Moving',
    'Parcel Shipping',
  ];

  final selectedService = 'Land Freight'.obs;
  final pickupDate = Rxn<DateTime>();

  QuoteController get quotes => _quoteController;

  @override
  void onInit() {
    super.onInit();
    final initialService = resolvedServiceType(services, initialServiceType);
    if (initialService != null) {
      selectedService.value = initialService;
    }
    applyQuoteDimensionInitials(
      lengthController: lengthController,
      widthController: widthController,
      heightController: heightController,
      weightController: weightController,
      quantityController: quantityController,
      lengthCm: initialLengthCm,
      widthCm: initialWidthCm,
      heightCm: initialHeightCm,
      weightKg: initialWeightKg,
      quantity: initialQuantity,
    );
  }

  Future<FormSubmitOutcome> submit({required bool formValid}) async {
    final blocked = formSubmitPrecheck(
      alreadySubmitting: _quoteController.isSubmitting.value,
      formValid: formValid,
      signedIn: _quoteController.currentUser != null,
    );
    if (blocked != null) return blocked;
    final user = _quoteController.currentUser!;

    try {
      final userData = await _quoteService.loadUserProfile(user.uid);
      final customerName = firstNonEmpty([
        userData['name'],
        userData['fullName'],
        user.displayName,
      ]);
      final customerEmail = firstNonEmpty([userData['email'], user.email]);
      final customerPhone = firstNonEmpty([
        userData['phone'],
        userData['phoneNumber'],
        user.phoneNumber,
      ]);
      final quoteNumber = buildQuoteNumber();
      final quoteData = <String, dynamic>{
        'userId': user.uid,
        'customerName': customerName.isEmpty ? 'Tawam Customer' : customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'quoteNumber': quoteNumber,
        'serviceType': selectedService.value,
        'from': fromController.text.trim(),
        'to': toController.text.trim(),
        'cargoType': cargoController.text.trim(),
        'weightKg': double.parse(weightController.text.trim()),
        'quantity': int.parse(quantityController.text.trim()),
        'lengthCm': parseOptionalDouble(lengthController.text),
        'widthCm': parseOptionalDouble(widthController.text),
        'heightCm': parseOptionalDouble(heightController.text),
        'volumeCbm': () {
          final length = parseOptionalDouble(lengthController.text);
          final width = parseOptionalDouble(widthController.text);
          final height = parseOptionalDouble(heightController.text);
          final quantity = int.tryParse(quantityController.text.trim()) ?? 1;
          if (length == null || width == null || height == null) return null;
          return (length * width * height * quantity) / 1000000;
        }(),
        'pickupDate': pickupDate.value == null
            ? null
            : Timestamp.fromDate(pickupDate.value!),
        'notes': notesController.text.trim(),
        'status': 'new',
        'quotedPrice': null,
        'currency': 'AED',
        'adminNote': '',
        'adminUpdatedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'customer_app',
      };

      final reference = await _quoteController.submitQuoteRequest(quoteData);
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
    fromController.dispose();
    toController.dispose();
    cargoController.dispose();
    weightController.dispose();
    quantityController.dispose();
    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
