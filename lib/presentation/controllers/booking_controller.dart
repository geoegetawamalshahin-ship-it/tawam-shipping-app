import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/services/booking_service.dart';

class BookingController extends GetxController {
  BookingController(this._service);

  final BookingService _service;

  User? get currentUser => _service.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<Map<String, dynamic>> loadCurrentUserProfile() =>
      _service.loadCurrentUserProfile();

  Future<DocumentReference<Map<String, dynamic>>> submit(
    Map<String, dynamic> data,
  ) => _service.submit(data);

  Future<void> submitWithGeneratedId(Map<String, dynamic> data) =>
      _service.submitWithGeneratedId(data);

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyBookings() =>
      _service.watchForCurrentUser();
}
