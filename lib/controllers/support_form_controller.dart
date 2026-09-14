import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/utils/form_submit_precheck.dart';
import 'support_controller.dart';

class SupportFormController extends GetxController {
  SupportFormController(this._supportController);

  final SupportController _supportController;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final shipmentNumberController = TextEditingController();
  final messageController = TextEditingController();

  final supportCategories = const [
    'Shipment Tracking',
    'Delivery Delay',
    'Request a Quote',
    'Customs Clearance',
    'Payment & Invoice',
    'Damaged Shipment',
    'General Inquiry',
  ];

  final selectedCategory = 'Shipment Tracking'.obs;

  SupportController get listController => _supportController;

  @override
  void onInit() {
    super.onInit();
    final user = _supportController.currentUser;
    if (user != null) {
      final displayName = user.displayName?.trim() ?? '';
      final email = user.email?.trim() ?? '';
      if (displayName.isNotEmpty) nameController.text = displayName;
      if (email.isNotEmpty) emailController.text = email;
    }
  }

  Future<FormSubmitOutcome> submit({required bool formValid}) async {
    final blocked = formSubmitPrecheck(
      alreadySubmitting: _supportController.isSubmitting.value,
      formValid: formValid,
      signedIn: _supportController.currentUser != null,
    );
    if (blocked != null) return blocked;
    final user = _supportController.currentUser!;

    try {
      await _supportController.submitSupportRequest({
        'userId': user.uid,
        'category': selectedCategory.value,
        'shipmentNumber': shipmentNumberController.text.trim().toUpperCase(),
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'message': messageController.text.trim(),
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });
      shipmentNumberController.clear();
      messageController.clear();
      return const FormSubmitOutcome.success();
    } catch (_) {
      return const FormSubmitOutcome.failure(FormSubmitError.generic);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    shipmentNumberController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
