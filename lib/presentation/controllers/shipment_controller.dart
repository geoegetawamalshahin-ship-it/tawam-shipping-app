import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/services/shipment_service.dart';

class ShipmentController extends GetxController {
  ShipmentController(this._service);

  final ShipmentService _service;

  User? get currentUser => _service.currentUser;
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMine() =>
      _service.watchMine();
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> findByTrackingNumber(
    String trackingNumber,
  ) => _service.findByTrackingNumber(trackingNumber);
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchById(String id) =>
      _service.watchById(id);
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> loadMine() =>
      _service.loadMine();
  Future<String> createDocumentUrl(String path) =>
      _service.createDocumentUrl(path);
  Future<Map<String, dynamic>> loadLiveLocation(String shipmentId) =>
      _service.loadLiveLocation(shipmentId);
}
