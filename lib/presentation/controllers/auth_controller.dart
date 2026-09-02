import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/models/auth_result.dart';
import '../../data/models/registration_data.dart';
import '../../data/services/auth_service.dart';
import '../../locale_controller.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthService _authService;
  final RxBool isBusy = false.obs;

  User? get currentUser => _authService.currentUser;

  Future<AuthResult<void>> signIn({
    required String email,
    required String password,
  }) async {
    if (isBusy.value) return const AuthResult.failure('operation-in-progress');
    isBusy.value = true;
    try {
      await _authService.signIn(email: email, password: password);
      await LocaleController.restoreFromFirestore();
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (error) {
      return AuthResult.failure(error.code);
    } finally {
      isBusy.value = false;
    }
  }

  Future<AuthResult<void>> register(RegistrationData data) async {
    if (isBusy.value) return const AuthResult.failure('operation-in-progress');
    isBusy.value = true;
    try {
      await _authService.register(data);
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (error) {
      return AuthResult.failure(error.code);
    } finally {
      isBusy.value = false;
    }
  }

  Future<AuthResult<void>> sendPasswordReset(String email) async {
    if (isBusy.value) return const AuthResult.failure('operation-in-progress');
    isBusy.value = true;
    try {
      await _authService.sendPasswordReset(email);
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (error) {
      return AuthResult.failure(error.code);
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> signOut() => _authService.signOut();
}
