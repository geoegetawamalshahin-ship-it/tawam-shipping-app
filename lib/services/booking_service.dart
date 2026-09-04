import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  BookingService(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<Map<String, dynamic>> loadUserProfile(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    return snapshot.data() ?? <String, dynamic>{};
  }

  Future<DocumentReference<Map<String, dynamic>>> createBookingRequest(
    Map<String, dynamic> data,
  ) {
    return _firestore.collection('shipment_requests').add(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookingRequests(
    String userId,
  ) {
    return _firestore
        .collection('shipment_requests')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
