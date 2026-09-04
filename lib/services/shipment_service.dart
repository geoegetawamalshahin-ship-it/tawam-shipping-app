import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShipmentService {
  ShipmentService(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserShipments(
    String userId,
  ) {
    return _firestore
        .collection('shipments')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> findShipment({
    required String userId,
    required String trackingNumber,
  }) {
    return _firestore
        .collection('shipments')
        .where('userId', isEqualTo: userId)
        .where('trackingNumber', isEqualTo: trackingNumber)
        .limit(1)
        .get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchShipment(
    String documentId,
  ) {
    return _firestore
        .collection('shipments')
        .doc(documentId)
        .snapshots();
  }
}
