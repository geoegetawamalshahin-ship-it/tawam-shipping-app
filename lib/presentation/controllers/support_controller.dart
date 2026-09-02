import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/services/support_service.dart';

class SupportController extends GetxController {
  SupportController(this._service);

  final SupportService _service;

  User? get currentUser => _service.currentUser;
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMine() =>
      _service.watchMine();
  Future<void> submit(Map<String, dynamic> data) => _service.submit(data);
}
