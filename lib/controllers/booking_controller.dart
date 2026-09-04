import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/booking_service.dart';

class BookingController extends GetxController {
  BookingController(this._bookingService);

  final BookingService _bookingService;

  User? get currentUser => _bookingService.currentUser;

  Future<Map<String, dynamic>> loadUserProfile(String userId) {
    return _bookingService.loadUserProfile(userId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createBookingRequest(
    Map<String, dynamic> data,
  ) {
    return _bookingService.createBookingRequest(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBookingRequests(
    String userId,
  ) {
    return _bookingService.watchBookingRequests(userId);
  }
}
