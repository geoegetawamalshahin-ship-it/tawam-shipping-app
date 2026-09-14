import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/shipment_service.dart';
import '../data/utils/form_initials.dart';

class TrackShipmentController extends GetxController {
  TrackShipmentController(this._shipmentService, {this.initialTrackingNumber});

  final ShipmentService _shipmentService;
  final String? initialTrackingNumber;

  final trackingController = TextEditingController();
  final isSearching = false.obs;
  final showResult = false.obs;
  final shipment = Rxn<Map<String, dynamic>>();
  final messageCode = RxnString();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  @visibleForTesting
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  get subscriptionForTest => _subscription;

  @override
  void onInit() {
    super.onInit();
    applyInitialTrackingNumber(trackingController, initialTrackingNumber);
  }

  @override
  void onReady() {
    super.onReady();
    if (trackingController.text.trim().isNotEmpty) {
      track();
    }
  }

  Future<void> track() async {
    final trackingNumber = trackingController.text.trim().toUpperCase();
    messageCode.value = null;

    if (trackingNumber.isEmpty) {
      messageCode.value = 'empty';
      return;
    }

    final user = _shipmentService.currentUser;
    if (user == null) {
      messageCode.value = 'unsigned';
      return;
    }

    await _subscription?.cancel();
    _subscription = null;

    isSearching.value = true;
    showResult.value = false;
    shipment.value = null;

    try {
      final snapshot = await _shipmentService.findShipment(
        userId: user.uid,
        trackingNumber: trackingNumber,
      );

      if (snapshot.docs.isEmpty) {
        isSearching.value = false;
        showResult.value = false;
        shipment.value = null;
        messageCode.value = 'not_found';
        return;
      }

      final doc = snapshot.docs.first;
      _applyShipment(documentId: doc.id, data: doc.data());

      _subscription = _shipmentService
          .watchShipment(doc.id)
          .listen(
            (document) {
              if (!document.exists || document.data() == null) {
                isSearching.value = false;
                showResult.value = false;
                shipment.value = null;
                messageCode.value = 'unavailable';
                return;
              }
              _applyShipment(documentId: document.id, data: document.data()!);
            },
            onError: (_) {
              messageCode.value = 'interrupted';
            },
          );
    } catch (_) {
      isSearching.value = false;
      showResult.value = false;
      shipment.value = null;
      messageCode.value = 'failed';
    }
  }

  void _applyShipment({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    isSearching.value = false;
    showResult.value = true;
    shipment.value = {...data, 'id': documentId};
  }

  @override
  void onClose() {
    _subscription?.cancel();
    trackingController.dispose();
    super.onClose();
  }
}
