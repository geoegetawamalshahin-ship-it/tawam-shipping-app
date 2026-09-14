import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../app/utils/shipment_documents.dart';
import '../locale_controller.dart';
import '../services/shipment_service.dart';

class ShipmentController extends GetxController {
  ShipmentController(this._shipmentService);

  final ShipmentService _shipmentService;

  final RxList<Map<String, dynamic>> shipments = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();
  final RxString selectedFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? _listeningUserId;

  User? get currentUser => _shipmentService.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserShipments(
    String userId,
  ) {
    return _shipmentService.watchUserShipments(userId);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> findShipment({
    required String userId,
    required String trackingNumber,
  }) {
    return _shipmentService.findShipment(
      userId: userId,
      trackingNumber: trackingNumber,
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchShipment(
    String documentId,
  ) {
    return _shipmentService.watchShipment(documentId);
  }

  Future<List<Map<String, dynamic>>> loadShippingDocuments() async {
    final user = currentUser;
    if (user == null) {
      return [];
    }

    final shipments = await _shipmentService.getUserShipments(user.uid);
    final documents = <Map<String, dynamic>>[];

    for (final shipmentDoc in shipments.docs) {
      final shipment = shipmentDoc.data();

      for (final document in shipmentDocumentsOf(shipment)) {
        documents.add({
          'item': document,
          'name': document.name,
          'path': document.path,
          'contentType': document.contentType,
          'size': document.size ?? 0,
          'uploadedAt': document.uploadedAt,
          'trackingNumber': (shipment['trackingNumber'] ?? '').toString(),
        });
      }
    }

    documents.sort((a, b) {
      final aDate = a['uploadedAt'];
      final bDate = b['uploadedAt'];

      if (aDate is Timestamp && bDate is Timestamp) {
        return bDate.compareTo(aDate);
      }

      return 0;
    });

    return documents;
  }

  List<Map<String, dynamic>> visibleShipments(
    String Function(String status) statusLabel,
  ) {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    return shipments.where((shipment) {
      final rawStatus = (shipment['rawStatus'] ?? '').toString();
      final searchable = [
        shipment['number'],
        shipment['origin'],
        shipment['destination'],
        shipment['type'],
        shipment['currentLocation'],
        rawStatus,
        statusLabel(rawStatus),
      ].join(' ').toLowerCase();

      final matchesFilter = filter == 'all' || rawStatus == filter;
      final matchesSearch = query.isEmpty || searchable.contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int countStatus(String status) {
    return shipments
        .where((shipment) => shipment['rawStatus'] == status)
        .length;
  }

  void setFilter(String value) {
    selectedFilter.value = value;
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void clearSearchAndFilters() {
    searchQuery.value = '';
    selectedFilter.value = 'all';
  }

  void startListening({bool force = false}) {
    final user = currentUser;

    if (user == null) {
      stopListening();
      shipments.clear();
      isLoading.value = false;
      loadError.value = null;
      return;
    }

    if (!force && _listeningUserId == user.uid && _subscription != null) {
      return;
    }

    isLoading.value = true;
    loadError.value = null;
    _listeningUserId = user.uid;
    _subscription?.cancel();

    _subscription = watchUserShipments(user.uid).listen(
      (snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          final rawStatus = LocaleController.normalizeStatus(
            (data['status'] ?? 'pending').toString(),
          );
          final cargo = (data['cargo'] ?? data['cargoType'] ?? '')
              .toString()
              .trim();

          return <String, dynamic>{
            ...data,
            'id': doc.id,
            'number': (data['trackingNumber'] ?? '').toString(),
            'origin': (data['pickupLocation'] ?? '').toString(),
            'destination': (data['deliveryLocation'] ?? '').toString(),
            'rawStatus': rawStatus,
            'progress': _shipmentStatusProgress(rawStatus),
            'type': cargo,
            'currentLocation': _shipmentCurrentLocation(data, rawStatus),
          };
        }).toList();

        items.sort((a, b) {
          final aCreated = a['createdAt'];
          final bCreated = b['createdAt'];
          if (aCreated is Timestamp && bCreated is Timestamp) {
            return bCreated.compareTo(aCreated);
          }
          return 0;
        });

        shipments.assignAll(items);
        isLoading.value = false;
        loadError.value = null;
      },
      onError: (_) {
        isLoading.value = false;
        loadError.value = 'error';
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _listeningUserId = null;
    shipments.clear();
    isLoading.value = false;
    loadError.value = null;
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }
}

double _shipmentStatusProgress(String status) {
  switch (status) {
    case 'confirmed':
      return .25;
    case 'prepared':
      return .36;
    case 'in_transit':
      return .58;
    case 'customs':
    case 'customs_clearance':
      return .72;
    case 'out_for_delivery':
      return .88;
    case 'delivered':
      return 1;
    case 'cancelled':
      return 0;
    default:
      return .10;
  }
}

String _shipmentCurrentLocation(Map<String, dynamic> data, String status) {
  for (final key in [
    'currentLocation',
    'currentArea',
    'lastLocation',
    'location',
  ]) {
    final value = data[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }

  final pickup = (data['pickupLocation'] ?? '').toString().trim();
  final delivery = (data['deliveryLocation'] ?? '').toString().trim();

  if (status == 'delivered' || status == 'out_for_delivery') {
    return delivery;
  }

  if (status == 'pending' || status == 'confirmed' || status == 'prepared') {
    return pickup;
  }

  return '';
}
