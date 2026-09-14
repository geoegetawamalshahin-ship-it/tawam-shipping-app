import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/services/shipment_request_service.dart';
import '../data/utils/form_submit_precheck.dart';

class ShipmentRequestController extends GetxController {
  ShipmentRequestController(this._service);

  final ShipmentRequestService _service;

  final pickupController = TextEditingController();
  final deliveryController = TextEditingController();
  final cargoController = TextEditingController();
  final notesController = TextEditingController();
  final expectedDelivery = Rxn<DateTime>();
  final isSubmitting = false.obs;

  Future<FormSubmitOutcome> submit({required bool formValid}) async {
    final blocked = formSubmitPrecheck(
      alreadySubmitting: isSubmitting.value,
      formValid: formValid,
      signedIn: _service.currentUser != null,
    );
    if (blocked != null) return blocked;
    final currentUser = _service.currentUser!;

    isSubmitting.value = true;
    try {
      final userData = await _service.loadUserDocument(currentUser.uid);
      final customerName =
          (userData?['name'] ??
                  userData?['fullName'] ??
                  currentUser.displayName ??
                  'Customer')
              .toString();
      final customerEmail = (userData?['email'] ?? currentUser.email ?? '')
          .toString();

      final requestRef = _service.newRequestReference();
      await _service.createShipmentRequest(
        requestId: requestRef.id,
        data: {
          'userId': currentUser.uid,
          'customerName': customerName,
          'customerEmail': customerEmail,
          'pickupLocation': pickupController.text.trim(),
          'deliveryLocation': deliveryController.text.trim(),
          'cargo': cargoController.text.trim(),
          'expectedDelivery': expectedDelivery.value != null
              ? Timestamp.fromDate(expectedDelivery.value!)
              : null,
          'notes': notesController.text.trim(),
          'status': 'pending_review',
          'requestId': requestRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return FormSubmitOutcome.success(documentId: requestRef.id);
    } catch (_) {
      return const FormSubmitOutcome.failure(FormSubmitError.generic);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    pickupController.dispose();
    deliveryController.dispose();
    cargoController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
