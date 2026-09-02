import 'package:cloud_firestore/cloud_firestore.dart';

class HomeService {
  const HomeService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<int> unreadNotificationCount(String userId) {
    if (userId.isEmpty) return Stream<int>.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((document) => document.data()['isRead'] != true)
              .length,
        );
  }
}
