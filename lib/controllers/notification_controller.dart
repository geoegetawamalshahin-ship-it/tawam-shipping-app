import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../data/services/notification_service.dart';

class NotificationController extends GetxController {
  NotificationController(this._notificationService);

  final NotificationService _notificationService;

  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();
  final RxString selectedFilter = 'All'.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? _listeningUserId;

  User? get currentUser => _notificationService.currentUser;

  int get unreadCount {
    return notifications.toList().where((notification) {
      return notification['isRead'] == false;
    }).length;
  }

  List<Map<String, dynamic>> get filteredNotifications {
    switch (selectedFilter.value) {
      case 'Unread':
        return notifications
            .where((notification) => notification['isRead'] == false)
            .toList();

      case 'Shipments':
        return notifications
            .where((notification) => notification['type'] == 'Shipment')
            .toList();

      case 'Quotes':
        return notifications
            .where((notification) => notification['type'] == 'Quote')
            .toList();

      default:
        return notifications.toList();
    }
  }

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

  void setFilter(String value) {
    selectedFilter.value = value;
  }

  void startListening({bool force = false}) {
    final user = currentUser;

    if (user == null) {
      stopListening();
      notifications.clear();
      isLoading.value = false;
      loadError.value = null;
      return;
    }

    if (!force && _listeningUserId == user.uid && _subscription != null) {
      return;
    }

    isLoading.value = true;
    loadError.value = null;
    _listeningUserId = user.uid;
    _subscription?.cancel();

    _subscription = watchNotifications(user.uid).listen(
      (snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          final timestamp = data['createdAt'] as Timestamp?;
          final date = timestamp?.toDate();

          return <String, dynamic>{
            'id': doc.id,
            'referenceId': (data['referenceId'] ?? '').toString(),
            'title': (data['title'] ?? '').toString(),
            'message': (data['message'] ?? '').toString(),
            'event': data['event']?.toString(),
            'params': _notificationParams(data['params']),
            'type': _normalizeType(data['type']),
            'isRead': data['isRead'] == true,
            'createdAt': date,
          };
        }).toList();

        items.sort((a, b) {
          final aDate = a['createdAt'] as DateTime?;
          final bDate = b['createdAt'] as DateTime?;

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return bDate.compareTo(aDate);
        });

        notifications.assignAll(items);
        isLoading.value = false;
        loadError.value = null;
      },
      onError: (_) {
        isLoading.value = false;
        loadError.value = 'error';
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _listeningUserId = null;
    notifications.clear();
    isLoading.value = false;
    loadError.value = null;
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }

  String _normalizeType(dynamic value) {
    final type = (value ?? '').toString().toLowerCase();

    if (type == 'quote') return 'Quote';
    if (type == 'support') return 'Support';

    return 'Shipment';
  }

  Map<String, dynamic>? _notificationParams(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }
}
