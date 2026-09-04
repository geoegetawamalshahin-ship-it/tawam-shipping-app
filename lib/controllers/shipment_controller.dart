import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/shipment_service.dart';

class ShipmentController extends GetxController {
  ShipmentController(this._shipmentService);

  final ShipmentService _shipmentService;

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
}
