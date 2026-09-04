import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuoteService {
  QuoteService(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<Map<String, dynamic>> loadUserProfile(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    return snapshot.data() ?? <String, dynamic>{};
  }

  Future<DocumentReference<Map<String, dynamic>>> createQuoteRequest(
    Map<String, dynamic> data,
  ) {
    return _firestore.collection('quote_requests').add(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchQuoteRequests(
    String userId,
  ) {
    return _firestore
        .collection('quote_requests')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> updateCustomerDecision(
    DocumentReference<Map<String, dynamic>> reference,
    String decision,
  ) {
    return reference.update({
      'customerDecision': decision,
      'customerDecisionAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
