import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/services/quote_service.dart';

class QuoteController extends GetxController {
  QuoteController(this._service);

  final QuoteService _service;

  User? get currentUser => _service.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<Map<String, dynamic>> loadCurrentUserProfile() =>
      _service.loadCurrentUserProfile();

  Future<DocumentReference<Map<String, dynamic>>> submit(
    Map<String, dynamic> data,
  ) => _service.submit(data);

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyQuotes() =>
      _service.watchForCurrentUser();

  Future<void> recordDecision(String quoteId, String decision) =>
      _service.recordDecision(quoteId, decision);
}
