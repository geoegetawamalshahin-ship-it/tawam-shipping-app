import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/quote_service.dart';

class QuoteController extends GetxController {
  QuoteController(this._quoteService);

  final QuoteService _quoteService;

  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> quoteDocs =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();
  final RxString selectedFilter = 'all'.obs;
  final RxBool isSubmitting = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? _listeningUserId;

  User? get currentUser => _quoteService.currentUser;

  Future<Map<String, dynamic>> loadUserProfile(String userId) {
    return _quoteService.loadUserProfile(userId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createQuoteRequest(
    Map<String, dynamic> data,
  ) {
    return _quoteService.createQuoteRequest(data);
  }

  Future<DocumentReference<Map<String, dynamic>>> submitQuoteRequest(
    Map<String, dynamic> data,
  ) {
    return _runSubmit(() => _quoteService.createQuoteRequest(data));
  }

  Future<DocumentReference<Map<String, dynamic>>> submitQuote(
    Map<String, dynamic> data,
  ) {
    return _runSubmit(() => _quoteService.createQuote(data));
  }

  Future<T> _runSubmit<T>(Future<T> Function() action) async {
    isSubmitting.value = true;
    try {
      return await action();
    } finally {
      isSubmitting.value = false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchQuoteRequests(
    String userId,
  ) {
    return _quoteService.watchQuoteRequests(userId);
  }

  Future<void> updateCustomerDecision(
    DocumentReference<Map<String, dynamic>> reference,
    String decision,
  ) {
    return _quoteService.updateCustomerDecision(reference, decision);
  }

  void setFilter(String value) {
    selectedFilter.value = value;
  }

  void startListening({bool force = false}) {
    final user = currentUser;

    if (user == null) {
      stopListening();
      quoteDocs.clear();
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

    _subscription = watchQuoteRequests(user.uid).listen(
      (snapshot) {
        final docs = [...snapshot.docs];

        docs.sort((a, b) {
          final aDate = _date(a.data()['createdAt']);
          final bDate = _date(b.data()['createdAt']);
          return bDate.compareTo(aDate);
        });

        quoteDocs.assignAll(docs);
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
    quoteDocs.clear();
    isLoading.value = false;
    loadError.value = null;
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }

  DateTime _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
