import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/quote_service.dart';

class QuoteController extends GetxController {
  QuoteController(this._quoteService);

  final QuoteService _quoteService;

  User? get currentUser => _quoteService.currentUser;

  Future<Map<String, dynamic>> loadUserProfile(String userId) {
    return _quoteService.loadUserProfile(userId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createQuoteRequest(
    Map<String, dynamic> data,
  ) {
    return _quoteService.createQuoteRequest(data);
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
}
