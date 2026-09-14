import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/shipment_service.dart';
import '../data/utils/form_initials.dart';

class TrackedShipmentMatch {
  const TrackedShipmentMatch({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;
}

class TrackShipmentController extends GetxController {
  TrackShipmentController(this._shipmentService, {this.initialTrackingNumber});

  final ShipmentService _shipmentService;
  final String? initialTrackingNumber;

  final trackingController = TextEditingController();
  final isSearching = false.obs;
  final showResult = false.obs;
  final shipment = Rxn<Map<String, dynamic>>();
  final messageCode = RxnString();

  var _closed = false;
  var _requestId = 0;
  StreamSubscription<TrackedShipmentMatch?>? _subscription;

  @visibleForTesting
  StreamSubscription<TrackedShipmentMatch?>? get subscriptionForTest =>
      _subscription;

  @visibleForTesting
  String? get activeUserId => _shipmentService.currentUser?.uid;

  bool _isCurrentRequest(int requestId) => !_closed && requestId == _requestId;

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

  @visibleForTesting
  Future<TrackedShipmentMatch?> lookupShipment({
    required String userId,
    required String trackingNumber,
  }) async {
    final snapshot = await _shipmentService.findShipment(
      userId: userId,
      trackingNumber: trackingNumber,
    );
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return TrackedShipmentMatch(id: doc.id, data: doc.data());
  }

  @visibleForTesting
  Stream<TrackedShipmentMatch?> watchShipment(String documentId) {
    return _shipmentService.watchShipment(documentId).map((document) {
      if (!document.exists || document.data() == null) return null;
      return TrackedShipmentMatch(id: document.id, data: document.data()!);
    });
  }

  Future<void> track() async {
    if (_closed) return;

    final trackingNumber = trackingController.text.trim().toUpperCase();
    messageCode.value = null;

    if (trackingNumber.isEmpty) {
      messageCode.value = 'empty';
      return;
    }

    final userId = activeUserId;
    if (userId == null) {
      messageCode.value = 'unsigned';
      return;
    }

    final requestId = ++_requestId;
    final pendingCancel = _subscription?.cancel();
    _subscription = null;
    if (pendingCancel != null) {
      await pendingCancel;
      if (!_isCurrentRequest(requestId)) return;
    }

    isSearching.value = true;
    showResult.value = false;
    shipment.value = null;

    try {
      final match = await lookupShipment(
        userId: userId,
        trackingNumber: trackingNumber,
      );
      if (!_isCurrentRequest(requestId)) return;

      if (match == null) {
        isSearching.value = false;
        showResult.value = false;
        shipment.value = null;
        messageCode.value = 'not_found';
        return;
      }

      _applyShipment(documentId: match.id, data: match.data);
      if (!_isCurrentRequest(requestId)) return;

      _subscription = watchShipment(match.id).listen(
        (document) {
          if (!_isCurrentRequest(requestId)) return;
          if (document == null) {
            isSearching.value = false;
            showResult.value = false;
            shipment.value = null;
            messageCode.value = 'unavailable';
            return;
          }
          _applyShipment(documentId: document.id, data: document.data);
        },
        onError: (_) {
          if (!_isCurrentRequest(requestId)) return;
          messageCode.value = 'interrupted';
        },
      );
    } catch (_) {
      if (!_isCurrentRequest(requestId)) return;
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
    _closed = true;
    _requestId++;
    _subscription?.cancel();
    _subscription = null;
    trackingController.dispose();
    super.onClose();
  }
}
