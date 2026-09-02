import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  NotificationService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMine() {
    final user = currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  Future<Map<String, dynamic>?> loadShipment(String id) async {
    final document = await _firestore.collection('shipments').doc(id).get();
    final data = document.data();
    if (!document.exists || data == null) return null;
    return {...data, 'id': document.id};
  }

  Future<bool> markAllAsRead() async {
    final user = currentUser;
    if (user == null) return false;
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();
    if (snapshot.docs.isEmpty) return false;
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
    return true;
  }

  Future<void> setRead(String id, bool isRead) => _firestore
      .collection('notifications')
      .doc(id)
      .update({'isRead': isRead});

  Future<void> delete(String id) =>
      _firestore.collection('notifications').doc(id).delete();
}
