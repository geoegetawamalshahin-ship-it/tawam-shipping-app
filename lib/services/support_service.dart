import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/firestore_collections.dart';

class SupportService {
  SupportService(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<DocumentReference<Map<String, dynamic>>> createSupportRequest(
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(FirestoreCollections.supportRequests).add(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSupportRequests(
    String userId,
  ) {
    return _firestore
        .collection(FirestoreCollections.supportRequests)
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
