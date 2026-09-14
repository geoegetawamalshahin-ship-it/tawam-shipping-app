import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constant/firestore_collections.dart';

class ShipmentRequestService {
  ShipmentRequestService(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<Map<String, dynamic>?> loadUserDocument(String userId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  Future<void> createShipmentRequest({
    required String requestId,
    required Map<String, dynamic> data,
  }) {
    return _firestore
        .collection(FirestoreCollections.shipmentRequests)
        .doc(requestId)
        .set(data);
  }

  DocumentReference<Map<String, dynamic>> newRequestReference() {
    return _firestore.collection(FirestoreCollections.shipmentRequests).doc();
  }
}
