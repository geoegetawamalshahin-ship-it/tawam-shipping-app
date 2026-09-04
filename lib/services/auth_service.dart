import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
