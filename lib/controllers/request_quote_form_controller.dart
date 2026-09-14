import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/utils/form_submit_precheck.dart';
import 'quote_controller.dart';

class RequestQuoteFormController extends GetxController {
  RequestQuoteFormController(this._quoteController);

  final QuoteController _quoteController;

  final pickupController = TextEditingController();
  final deliveryController = TextEditingController();
  final cargoController = TextEditingController();
  final weightController = TextEditingController();
  final quantityController = TextEditingController();
  final dateController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final notesController = TextEditingController();

  final cargoTypes = const [
    'General Cargo',
    'Vehicles',
    'Heavy Equipment',
    'Furniture',
    'Electronics',
    'Food Products',
    'Medical Supplies',
    'Other',
  ];

  final shippingModes = const [
    'Road Freight',
    'Air Freight',
    'Sea Freight',
    'Express',
  ];

  final selectedCargoType = 'General Cargo'.obs;
  final selectedShippingMode = 'Road Freight'.obs;
  final pickupDate = Rxn<DateTime>();

  QuoteController get quotes => _quoteController;

  Map<String, dynamic> buildQuoteData({required String userId}) {
    return {
      'userId': userId,
      'pickupLocation': pickupController.text.trim(),
      'deliveryLocation': deliveryController.text.trim(),
      'cargo': cargoController.text.trim(),
      'weight': weightController.text.trim(),
      'quantity': quantityController.text.trim(),
      'shipmentDate': dateController.text.trim(),
      'fullName': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
      'notes': notesController.text.trim(),
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  void applyPickupDate(DateTime date, String formatted) {
    pickupDate.value = date;
    dateController.text = formatted;
  }

  void clearForm() {
    pickupController.clear();
    deliveryController.clear();
    cargoController.clear();
    weightController.clear();
    quantityController.clear();
    dateController.clear();
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    notesController.clear();
    pickupDate.value = null;
  }

  Future<FormSubmitOutcome> submit({required bool formValid}) async {
    final blocked = formSubmitPrecheck(
      alreadySubmitting: _quoteController.isSubmitting.value,
      formValid: formValid,
      signedIn: _quoteController.currentUser != null,
    );
    if (blocked != null) return blocked;
    try {
      await _quoteController.submitQuote(
        buildQuoteData(userId: _quoteController.currentUser!.uid),
      );
      return const FormSubmitOutcome.success();
    } catch (_) {
      return const FormSubmitOutcome.failure(FormSubmitError.generic);
    }
  }

  @override
  void onClose() {
    pickupController.dispose();
    deliveryController.dispose();
    cargoController.dispose();
    weightController.dispose();
    quantityController.dispose();
    dateController.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
