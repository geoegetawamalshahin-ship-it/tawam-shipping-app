import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../services/auth_service.dart';

/// Application-wide GetX registrations will be added here incrementally.
///
/// Keeping the initial binding empty preserves the current application
/// behavior while establishing the MVC migration entry point.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(
      () => AuthService(FirebaseAuth.instance),
      fenix: true,
    );
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<AuthService>()),
      fenix: true,
    );
  }
}
