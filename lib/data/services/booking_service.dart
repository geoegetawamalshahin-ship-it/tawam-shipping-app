import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  BookingService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> loadCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return const <String, dynamic>{};
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    return snapshot.data() ?? const <String, dynamic>{};
  }

  Future<DocumentReference<Map<String, dynamic>>> submit(
    Map<String, dynamic> data,
  ) => _firestore.collection('shipment_requests').add(data);

  Stream<QuerySnapshot<Map<String, dynamic>>> watchForCurrentUser() {
    final user = currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('shipment_requests')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }
}
