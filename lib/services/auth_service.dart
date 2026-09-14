import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../core/firestore_collections.dart';

class AuthService {
  AuthService(this._firebaseAuth, this._firestore);

  static const _profilePhotoBucket = 'shipping-documents';

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _firebaseAuth.currentUser;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection(FirestoreCollections.users).doc(uid);
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createAccount({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user?.updateDisplayName(name);
    await _userDoc(userCredential.user!.uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'role': 'customer',
      'customerId':
          'TW-${userCredential.user!.uid.substring(0, 8).toUpperCase()}',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  Future<Map<String, dynamic>?> loadUserDocument(String userId) async {
    final snapshot = await _userDoc(userId).get();
    return snapshot.data();
  }

  Future<Map<String, int>> loadProfileStats(String userId) async {
    final shipments = await _firestore
        .collection(FirestoreCollections.shipments)
        .where('userId', isEqualTo: userId)
        .get();

    final quotes = await _firestore
        .collection(FirestoreCollections.quotes)
        .where('userId', isEqualTo: userId)
        .get();

    final inTransit = shipments.docs.where((doc) {
      final status =
          doc.data()['status']?.toString().trim().toLowerCase() ?? '';

      return status == 'in transit' ||
          status == 'in_transit' ||
          status == 'in-transit';
    }).length;

    return {
      'shipmentsCount': shipments.docs.length,
      'inTransitCount': inTransit,
      'quotesCount': quotes.docs.length,
    };
  }

  Future<void> mergeUserFields(String userId, Map<String, dynamic> data) {
    return _userDoc(userId).set(data, SetOptions(merge: true));
  }

  Future<void> updateDisplayName(String name) async {
    await currentUser?.updateDisplayName(name);
  }

  Uint8List? bytesFromProfilePhoto(dynamic value) {
    if (value is Blob) return value.bytes;
    if (value is Uint8List) return value;
    if (value is List<int>) return Uint8List.fromList(value);
    if (value is String && value.isNotEmpty) {
      try {
        return Uint8List.fromList(base64Decode(value));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<Uint8List?> downloadProfilePhoto(String? path) async {
    if (path == null || path.isEmpty) return null;

    try {
      return await Supabase.instance.client.storage
          .from(_profilePhotoBucket)
          .download(path);
    } catch (_) {
      return null;
    }
  }

  Future<void> persistProfilePhoto(String uid, Uint8List bytes) async {
    try {
      await _userDoc(uid).set({
        'profilePhoto': Blob(bytes),
        'profilePhotoPath': FieldValue.delete(),
      }, SetOptions(merge: true));
      return;
    } catch (_) {
      // Some rules or clients reject Blob; store a compact base64 string.
    }

    try {
      await _userDoc(uid).set({
        'profilePhoto': base64Encode(bytes),
        'profilePhotoPath': FieldValue.delete(),
      }, SetOptions(merge: true));
      return;
    } catch (_) {
      // Fall through to the existing documents bucket.
    }

    final isPng =
        bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final path = 'users/$uid/profile.${isPng ? 'png' : 'jpg'}';

    await Supabase.instance.client.storage
        .from(_profilePhotoBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: isPng ? 'image/png' : 'image/jpeg',
          ),
        );

    await _userDoc(uid).set({
      'profilePhoto': FieldValue.delete(),
      'profilePhotoPath': path,
    }, SetOptions(merge: true));
  }

  Future<void> deleteStoredProfilePhoto(String uid) async {
    await _userDoc(uid).set({
      'profilePhoto': FieldValue.delete(),
      'profilePhotoPath': FieldValue.delete(),
    }, SetOptions(merge: true));

    try {
      await Supabase.instance.client.storage.from(_profilePhotoBucket).remove([
        'users/$uid/profile.jpg',
        'users/$uid/profile.png',
      ]);
    } catch (_) {
      // Ignore missing storage objects.
    }
  }

  Future<void> enablePushToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    await _userDoc(uid).set({
      'fcmToken': token,
      'fcmTokens': FieldValue.arrayUnion([token]),
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> disablePushToken(String uid) async {
    final doc = await _userDoc(uid).get();
    final storedToken = doc.data()?['fcmToken']?.toString();

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // Continue clearing the stored token even if deleteToken fails.
    }

    await _userDoc(uid).set({
      'fcmToken': FieldValue.delete(),
      if (storedToken != null && storedToken.isNotEmpty)
        'fcmTokens': FieldValue.arrayRemove([storedToken]),
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> requestAccountDeletion({required String password}) async {
    final user = currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);

    final deletionRef = _firestore
        .collection(FirestoreCollections.accountDeletionRequests)
        .doc(user.uid);

    final deletionDocument = await deletionRef.get();

    if (!deletionDocument.exists) {
      await deletionRef.set({
        'userId': user.uid,
        'email': user.email ?? '',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await deletionRef.update({
      'status': 'deleted',
      'deletedAt': FieldValue.serverTimestamp(),
    });

    await _userDoc(user.uid).delete();
    await user.delete();
  }
}
