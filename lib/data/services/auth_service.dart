import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/registration_data.dart';

class AuthService {
  const AuthService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register(RegistrationData data) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: data.email.trim(),
      password: data.password,
    );
    final user = credential.user!;

    await user.updateDisplayName(data.name.trim());
    await _firestore.collection('users').doc(user.uid).set({
      'name': data.name.trim(),
      'phone': data.phone.trim(),
      'email': data.email.trim(),
      'role': 'customer',
      'customerId': 'TW-${user.uid.substring(0, 8).toUpperCase()}',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();
}
