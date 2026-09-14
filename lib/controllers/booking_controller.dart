import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../data/services/booking_service.dart';

class BookingController extends GetxController {
  BookingController(this._bookingService);

  final BookingService _bookingService;

  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> bookingDocs =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();
  final RxString selectedFilter = 'all'.obs;
  final RxBool isSubmitting = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? _listeningUserId;

  User? get currentUser => _bookingService.currentUser;

  Future<Map<String, dynamic>> loadUserProfile(String userId) {
    return _bookingService.loadUserProfile(userId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createBookingRequest(
    Map<String, dynamic> data,
  ) {
    return _bookingService.createBookingRequest(data);
  }

  Future<DocumentReference<Map<String, dynamic>>> submitBookingRequest(
    Map<String, dynamic> data,
  ) async {
    if (isSubmitting.value) {
      throw StateError('already_submitting');
    }
    isSubmitting.value = true;
    try {
      return await _bookingService.createBookingRequest(data);
    } finally {
      isSubmitting.value = false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookingRequests(
    String userId,
  ) {
    return _bookingService.watchBookingRequests(userId);
  }

  void setFilter(String value) {
    selectedFilter.value = value;
  }

  void startListening({bool force = false}) {
    final user = currentUser;

    if (user == null) {
      stopListening();
      bookingDocs.clear();
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

    _subscription = watchBookingRequests(user.uid).listen(
      (snapshot) {
        final docs = snapshot.docs.toList();

        docs.sort((a, b) {
          final aDate = a.data()['createdAt'];
          final bDate = b.data()['createdAt'];

          final aMilliseconds = aDate is Timestamp
              ? aDate.millisecondsSinceEpoch
              : 0;

          final bMilliseconds = bDate is Timestamp
              ? bDate.millisecondsSinceEpoch
              : 0;

          return bMilliseconds.compareTo(aMilliseconds);
        });

        final bookings = docs.where((doc) {
          final data = doc.data();
          final requestType = (data['requestType'] ?? '')
              .toString()
              .toLowerCase();

          return requestType.isEmpty || requestType == 'booking';
        }).toList();

        bookingDocs.assignAll(bookings);
        isLoading.value = false;
        loadError.value = null;
      },
      onError: (error) {
        isLoading.value = false;
        loadError.value = error.toString();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _listeningUserId = null;
    bookingDocs.clear();
    isLoading.value = false;
    loadError.value = null;
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }
}
