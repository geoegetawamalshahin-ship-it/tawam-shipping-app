import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/firestore_collections.dart';

class BookingService {
  BookingService(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<Map<String, dynamic>> loadUserProfile(String userId) async {
    final snapshot = await _firestore.collection(FirestoreCollections.users).doc(userId).get();
    return snapshot.data() ?? <String, dynamic>{};
  }

  Future<DocumentReference<Map<String, dynamic>>> createBookingRequest(
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(FirestoreCollections.shipmentRequests).add(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookingRequests(
    String userId,
  ) {
    return _firestore
        .collection(FirestoreCollections.shipmentRequests)
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
