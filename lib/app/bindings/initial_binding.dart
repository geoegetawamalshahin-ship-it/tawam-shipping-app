import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/quote_controller.dart';
import '../../services/auth_service.dart';
import '../../services/quote_service.dart';

/// Application-wide GetX registrations are added here incrementally while
/// preserving each feature's existing behavior.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(
      () => AuthService(FirebaseAuth.instance, FirebaseFirestore.instance),
      fenix: true,
    );
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<AuthService>()),
      fenix: true,
    );
    Get.lazyPut<QuoteService>(
      () => QuoteService(FirebaseAuth.instance, FirebaseFirestore.instance),
      fenix: true,
    );
    Get.lazyPut<QuoteController>(
      () => QuoteController(Get.find<QuoteService>()),
      fenix: true,
    );
  }
}
