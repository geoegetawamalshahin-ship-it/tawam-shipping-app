import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../data/utils/form_initials.dart';
import '../data/utils/form_submit_precheck.dart';
import '../data/utils/quote_reference.dart';
import '../data/utils/value_formatters.dart';
import 'booking_controller.dart';

class CreateBookingFormController extends GetxController {
  CreateBookingFormController(
    this._bookingController, {
    this.initialServiceType,
  });

  final BookingController _bookingController;
  final String? initialServiceType;

  final pickupController = TextEditingController();
  final deliveryController = TextEditingController();
  final cargoController = TextEditingController();
  final weightController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();

  final services = const [
    'Sea Freight',
    'Air Freight',
    'Land Freight',
    'Car Shipping',
    'International Moving',
    'Parcel Shipping',
  ];

  final preferredTimes = const ['Morning', 'Afternoon', 'Evening', 'Flexible'];

  final selectedService = 'Land Freight'.obs;
  final preferredTime = 'Flexible'.obs;
  final pickupDate = Rxn<DateTime>();
  final customerName = 'TAWAM Customer'.obs;
  final customerEmail = ''.obs;
  final loadingProfile = true.obs;

  BookingController get bookings => _bookingController;

  @override
  void onInit() {
    super.onInit();
    final initial = resolvedServiceType(services, initialServiceType);
    if (initial != null) {
      selectedService.value = initial;
    }
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = _bookingController.currentUser;
    if (user == null) {
      loadingProfile.value = false;
      return;
    }

    String name = user.displayName?.trim() ?? '';
    String email = user.email?.trim() ?? '';
    String phone = user.phoneNumber?.trim() ?? '';

    try {
      final data = await _bookingController.loadUserProfile(user.uid);
      name = firstNonEmpty([
        data['name'],
        data['fullName'],
        data['customerName'],
        name,
      ]);
      email = firstNonEmpty([data['email'], data['customerEmail'], email]);
      phone = firstNonEmpty([
        data['phone'],
        data['phoneNumber'],
        data['customerPhone'],
        phone,
      ]);
    } catch (_) {}

    customerName.value = name.isEmpty ? 'TAWAM Customer' : name;
    customerEmail.value = email;
    phoneController.text = phone;
    loadingProfile.value = false;
  }

  Map<String, dynamic> buildBookingData({
    required String userId,
    required String bookingReference,
  }) {
    final phone = phoneController.text.trim();
    return {
      'userId': userId,
      'bookingReference': bookingReference,
      'requestType': 'booking',
      'customerName': customerName.value,
      'customerEmail': customerEmail.value,
      'customerPhone': phone,
      'fullName': customerName.value,
      'email': customerEmail.value,
      'phone': phone,
      'serviceType': selectedService.value,
      'pickupLocation': pickupController.text.trim(),
      'deliveryLocation': deliveryController.text.trim(),
      'from': pickupController.text.trim(),
      'to': deliveryController.text.trim(),
      'pickupDate': Timestamp.fromDate(pickupDate.value!),
      'shipmentDate': Timestamp.fromDate(pickupDate.value!),
      'preferredTime': preferredTime.value,
      'cargoType': cargoController.text.trim(),
      'cargo': cargoController.text.trim(),
      'weightKg': double.parse(weightController.text.trim()),
      'quantity': int.parse(quantityController.text.trim()),
      'lengthCm': parseOptionalDouble(lengthController.text),
      'widthCm': parseOptionalDouble(widthController.text),
      'heightCm': parseOptionalDouble(heightController.text),
      'notes': notesController.text.trim(),
      'status': 'pending',
      'adminNote': '',
      'adminUpdatedAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'source': 'customer_app',
    };
  }

  Future<FormSubmitOutcome> submit({required bool formValid}) async {
    final blocked = formSubmitPrecheck(
      alreadySubmitting: _bookingController.isSubmitting.value,
      formValid: formValid,
      signedIn: _bookingController.currentUser != null,
      requireDate: true,
      date: pickupDate.value,
    );
    if (blocked != null) return blocked;
    try {
      final bookingReference = buildBookingReference();
      await _bookingController.submitBookingRequest(
        buildBookingData(
          userId: _bookingController.currentUser!.uid,
          bookingReference: bookingReference,
        ),
      );
      return FormSubmitOutcome.success(reference: bookingReference);
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
    pickupController.dispose();
    deliveryController.dispose();
    cargoController.dispose();
    weightController.dispose();
    quantityController.dispose();
    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
