import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../data/services/live_location_service.dart';
import '../data/services/shipment_service.dart';

class ShipmentDetailsController extends GetxController {
  ShipmentDetailsController(
    this._shipmentService,
    this._liveLocationService, {
    required Map<String, dynamic> shipment,
  }) : shipment = Map<String, dynamic>.from(shipment).obs;

  final ShipmentService _shipmentService;
  final LiveLocationService _liveLocationService;

  final RxMap<String, dynamic> shipment;
  final liveLocation = RxnString();
  final liveLastUpdated = RxnString();
  final liveLatitude = RxnDouble();
  final liveLongitude = RxnDouble();
  final isLoadingLiveLocation = false.obs;
  final liveLocationError = RxnString();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  Timer? _liveLocationTimer;

  @override
  void onInit() {
    super.onInit();
    _startLiveListener();
    loadLiveLocation();
    _liveLocationTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => loadLiveLocation(),
    );
  }

  void _startLiveListener() {
    final documentId = (shipment['id'] ?? '').toString().trim();
    if (documentId.isEmpty) return;

    _subscription = _shipmentService.watchShipment(documentId).listen((
      document,
    ) {
      if (!document.exists || document.data() == null) return;
      shipment.assignAll({...document.data()!, 'id': document.id});
    }, onError: (_) {});
  }

  Future<void> loadLiveLocation() async {
    final trackingMode = (shipment['trackingMode'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (trackingMode != 'gps') return;
    if (isLoadingLiveLocation.value) return;

    final shipmentId = (shipment['id'] ?? '').toString().trim();
    final user = _shipmentService.currentUser;
    if (shipmentId.isEmpty || user == null) return;

    isLoadingLiveLocation.value = true;
    liveLocationError.value = null;

    final result = await _liveLocationService.fetchLiveLocation(shipmentId);
    if (result.isSuccess) {
      final location = result.location!;
      liveLocation.value = location.address;
      liveLastUpdated.value = location.lastUpdated;
      liveLatitude.value = location.latitude;
      liveLongitude.value = location.longitude;
      liveLocationError.value = null;
    } else {
      liveLocationError.value = result.errorMessage ?? 'generic';
    }
    isLoadingLiveLocation.value = false;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _liveLocationTimer?.cancel();
    super.onClose();
  }
}
