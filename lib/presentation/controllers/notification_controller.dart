import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/services/notification_service.dart';

class NotificationController extends GetxController {
  NotificationController(this._service);

  final NotificationService _service;
  User? get currentUser => _service.currentUser;
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMine() =>
      _service.watchMine();
  Future<Map<String, dynamic>?> loadShipment(String id) =>
      _service.loadShipment(id);
  Future<bool> markAllAsRead() => _service.markAllAsRead();
  Future<void> setRead(String id, bool isRead) =>
      _service.setRead(id, isRead);
  Future<void> delete(String id) => _service.delete(id);
}
