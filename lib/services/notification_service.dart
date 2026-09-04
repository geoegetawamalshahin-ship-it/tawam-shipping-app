import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  NotificationService(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> loadShipment(
    String documentId,
  ) {
    return _firestore.collection('shipments').doc(documentId).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchNotifications(
    String userId,
  ) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<bool> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) {
      return false;
    }

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
    return true;
  }

  Future<void> setReadState(String id, {required bool isRead}) {
    return _firestore.collection('notifications').doc(id).update({
      'isRead': isRead,
    });
  }

  Future<void> deleteNotification(String id) {
    return _firestore.collection('notifications').doc(id).delete();
  }
}
