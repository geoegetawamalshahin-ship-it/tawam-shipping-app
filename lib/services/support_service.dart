import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportService {
  SupportService(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<DocumentReference<Map<String, dynamic>>> createSupportRequest(
    Map<String, dynamic> data,
  ) {
    return _firestore.collection('support_requests').add(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSupportRequests(
    String userId,
  ) {
    return _firestore
        .collection('support_requests')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
