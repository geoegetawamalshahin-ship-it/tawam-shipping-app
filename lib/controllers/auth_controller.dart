import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthService _authService;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signIn(email: email, password: password);
  }
}
