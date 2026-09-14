import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/utils/shipping_customer_profile.dart';

mixin CustomerQuoteProfileMixin on GetxController {
  final loadingProfile = true.obs;
  final customerName = ''.obs;
  final customerEmail = ''.obs;
  final customerPhone = ''.obs;
  final customerCompany = ''.obs;
  final customerCountry = ''.obs;

  Map<String, dynamic> customerPayload(String userId) {
    return {
      'userId': userId,
      'customerName': customerName.value,
      'customerEmail': customerEmail.value,
      'customerPhone': customerPhone.value,
      'customerCompany': customerCompany.value,
      'customerCountry': customerCountry.value,
      'fullName': customerName.value,
      'email': customerEmail.value,
      'phone': customerPhone.value,
    };
  }

  bool _profileLoadStarted = false;
  final _managedListeners = <Listenable, VoidCallback>{};

  void addManagedListener(Listenable listenable, VoidCallback listener) {
    listenable.addListener(listener);
    _managedListeners[listenable] = listener;
  }

  void removeManagedListeners() {
    for (final entry in _managedListeners.entries) {
      entry.key.removeListener(entry.value);
    }
    _managedListeners.clear();
  }

  Future<void> loadCustomerProfile({
    required Future<Map<String, dynamic>?> Function(String uid)
    readUserDocument,
    required String emptyNameFallback,
    bool force = false,
  }) async {
    if (!force && _profileLoadStarted) return;
    _profileLoadStarted = true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _profileLoadStarted = false;
      loadingProfile.value = false;
      return;
    }

    final profile = await loadShippingCustomerProfile(
      uid: user.uid,
      authName: user.displayName?.trim() ?? '',
      authEmail: user.email?.trim() ?? '',
      authPhone: user.phoneNumber?.trim() ?? '',
      readUserDocument: readUserDocument,
    );

    customerName.value = shippingCustomerDisplayName(
      profile.name,
      emptyNameFallback,
    );
    customerEmail.value = profile.email;
    customerPhone.value = profile.phone;
    customerCompany.value = profile.company;
    customerCountry.value = profile.country;
    loadingProfile.value = false;
  }

  void disposeTextControllers(Iterable<TextEditingController> controllers) {
    removeManagedListeners();
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}
