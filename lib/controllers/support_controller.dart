import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/support_service.dart';

class SupportController extends GetxController {
  SupportController(this._supportService);

  final SupportService _supportService;

  User? get currentUser => _supportService.currentUser;

  Future<DocumentReference<Map<String, dynamic>>> createSupportRequest(
    Map<String, dynamic> data,
  ) {
    return _supportService.createSupportRequest(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSupportRequests(
    String userId,
  ) {
    return _supportService.watchSupportRequests(userId);
  }
}
