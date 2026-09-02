import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportService {
  SupportService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMine() {
    final user = currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('support_requests')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  Future<void> submit(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw StateError('Authentication required');
    await _firestore.collection('support_requests').add({
      ...data,
      'userId': user.uid,
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
