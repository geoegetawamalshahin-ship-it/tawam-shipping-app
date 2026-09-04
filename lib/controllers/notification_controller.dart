import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/notification_service.dart';

class NotificationController extends GetxController {
  NotificationController(this._notificationService);

  final NotificationService _notificationService;

  User? get currentUser => _notificationService.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> loadShipment(
    String documentId,
  ) {
    return _notificationService.loadShipment(documentId);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchNotifications(
    String userId,
  ) {
    return _notificationService.watchNotifications(userId);
  }

  Future<bool> markAllAsRead(String userId) {
    return _notificationService.markAllAsRead(userId);
  }

  Future<void> setReadState(String id, {required bool isRead}) {
    return _notificationService.setReadState(id, isRead: isRead);
  }

  Future<void> deleteNotification(String id) {
    return _notificationService.deleteNotification(id);
  }
}
