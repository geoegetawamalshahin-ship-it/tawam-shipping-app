import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../data/services/auth_service.dart';
import 'booking_controller.dart';
import 'notification_controller.dart';
import 'profile_controller.dart';
import 'quote_controller.dart';
import 'shipment_controller.dart';
import 'support_controller.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthService _authService;

  User? get currentUser => _authService.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signIn(email: email, password: password);
  }

  Future<void> createAccount({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    return _authService.createAccount(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _authService.sendPasswordResetEmail(email: email);
  }

  Future<Map<String, dynamic>?> loadUserDocument(String userId) {
    return _authService.loadUserDocument(userId);
  }

  Future<Map<String, int>> loadProfileStats(String userId) {
    return _authService.loadProfileStats(userId);
  }

  Future<void> mergeUserFields(String userId, Map<String, dynamic> data) {
    return _authService.mergeUserFields(userId, data);
  }

  Future<void> updateDisplayName(String name) {
    return _authService.updateDisplayName(name);
  }

  Uint8List? bytesFromProfilePhoto(dynamic value) {
    return _authService.bytesFromProfilePhoto(value);
  }

  Future<Uint8List?> downloadProfilePhoto(String? path) {
    return _authService.downloadProfilePhoto(path);
  }

  Future<void> persistProfilePhoto(String uid, Uint8List bytes) {
    return _authService.persistProfilePhoto(uid, bytes);
  }

  Future<void> deleteStoredProfilePhoto(String uid) {
    return _authService.deleteStoredProfilePhoto(uid);
  }

  Future<void> enablePushToken(String uid) {
    return _authService.enablePushToken(uid);
  }

  Future<void> disablePushToken(String uid) {
    return _authService.disablePushToken(uid);
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return credentialErrorCode(e.code);
    } catch (_) {
      return 'generic';
    }
  }

  Future<String?> requestAccountDeletion({required String password}) async {
    try {
      await _authService.requestAccountDeletion(password: password);
      _stopListListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return credentialErrorCode(e.code);
    } catch (_) {
      return 'generic';
    }
  }

  static String credentialErrorCode(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'wrong-password';
      case 'weak-password':
        return 'weak-password';
      case 'requires-recent-login':
        return 'requires-recent-login';
      default:
        return 'generic';
    }
  }

  Future<void> signOut() async {
    _stopListListeners();
    await _authService.signOut();
  }

  void _stopListListeners() {
    if (Get.isRegistered<ShipmentController>()) {
      Get.find<ShipmentController>().stopListening();
    }
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().stopListening();
    }
    if (Get.isRegistered<QuoteController>()) {
      Get.find<QuoteController>().stopListening();
    }
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().stopListening();
    }
    if (Get.isRegistered<SupportController>()) {
      Get.find<SupportController>().stopListening();
    }
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
    }
  }
}
