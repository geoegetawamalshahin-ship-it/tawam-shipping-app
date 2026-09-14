import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/support_service.dart';

class SupportController extends GetxController {
  SupportController(this._supportService);

  final SupportService _supportService;

  final RxList<Map<String, dynamic>> requests = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();
  final RxString selectedFilter = 'all'.obs;
  final RxBool isSubmitting = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? _listeningUserId;

  User? get currentUser => _supportService.currentUser;

  Future<DocumentReference<Map<String, dynamic>>> createSupportRequest(
    Map<String, dynamic> data,
  ) {
    return _supportService.createSupportRequest(data);
  }

  Future<DocumentReference<Map<String, dynamic>>> submitSupportRequest(
    Map<String, dynamic> data,
  ) async {
    isSubmitting.value = true;
    try {
      return await _supportService.createSupportRequest(data);
    } finally {
      isSubmitting.value = false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSupportRequests(
    String userId,
  ) {
    return _supportService.watchSupportRequests(userId);
  }

  void setFilter(String value) {
    selectedFilter.value = value;
  }

  List<Map<String, dynamic>> get filteredRequests {
    final filter = selectedFilter.value;
    if (filter == 'all') {
      return requests.toList();
    }

    return requests.where((request) {
      return normalizeSupportStatus((request['status'] ?? 'new').toString()) ==
          filter;
    }).toList();
  }

  void startListening({bool force = false}) {
    final user = currentUser;

    if (user == null) {
      stopListening();
      requests.clear();
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

    _subscription = watchSupportRequests(user.uid).listen(
      (snapshot) {
        final items = snapshot.docs.map((doc) {
          return <String, dynamic>{...doc.data(), 'id': doc.id};
        }).toList();

        items.sort((a, b) {
          final aTime = a['createdAt'];
          final bTime = b['createdAt'];

          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }

          return 0;
        });

        requests.assignAll(items);
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
    requests.clear();
    isLoading.value = false;
    loadError.value = null;
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }

  String normalizeSupportStatus(String raw) {
    final status = raw
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (status == 'resolved' || status == 'closed' || status == 'completed') {
      return 'resolved';
    }

    if (status == 'in_progress' || status == 'processing' || status == 'open') {
      return 'in_progress';
    }

    return 'new';
  }
}
