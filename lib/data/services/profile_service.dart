import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class ProfileService {
  ProfileService(this._auth, this._firestore, this._messaging, this._supabase);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final SupabaseClient _supabase;

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> loadProfile() async {
    final user = currentUser;
    if (user == null) return const {};
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data() ?? const {};
  }

  Future<Map<String, int>> loadStats() async {
    final user = currentUser;
    if (user == null) return const {'shipments': 0, 'inTransit': 0, 'quotes': 0};
    final results = await Future.wait([
      _firestore.collection('shipments').where('userId', isEqualTo: user.uid).get(),
      _firestore.collection('quotes').where('userId', isEqualTo: user.uid).get(),
    ]);
    final shipments = results[0];
    final quotes = results[1];
    final inTransit = shipments.docs.where((doc) {
      final status = doc.data()['status']?.toString().trim().toLowerCase() ?? '';
      return status == 'in transit' || status == 'in_transit' || status == 'in-transit';
    }).length;
    return {
      'shipments': shipments.docs.length,
      'inTransit': inTransit,
      'quotes': quotes.docs.length,
    };
  }

  Future<void> saveNotificationPreference(bool value) async {
    final user = currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set(
      {'notificationsEnabled': value},
      SetOptions(merge: true),
    );
    if (value) {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final storedToken = doc.data()?['fcmToken']?.toString();
      try {
        await _messaging.deleteToken();
      } catch (_) {}
      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': FieldValue.delete(),
        if (storedToken != null && storedToken.isNotEmpty)
          'fcmTokens': FieldValue.arrayRemove([storedToken]),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set(
      data,
      SetOptions(merge: true),
    );
    await user.updateDisplayName(data['name']?.toString());
  }

  Future<void> savePhoto(Uint8List bytes) async {
    final user = currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'profilePhoto': Blob(bytes),
        'profilePhotoPath': FieldValue.delete(),
      }, SetOptions(merge: true));
      return;
    } catch (_) {}
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'profilePhoto': base64Encode(bytes),
        'profilePhotoPath': FieldValue.delete(),
      }, SetOptions(merge: true));
      return;
    } catch (_) {}
    final isPng = bytes.length >= 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47;
    final path = 'users/${user.uid}/profile.${isPng ? 'png' : 'jpg'}';
    await _supabase.storage.from('shipping-documents').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(upsert: true, contentType: isPng ? 'image/png' : 'image/jpeg'),
    );
    await _firestore.collection('users').doc(user.uid).set({
      'profilePhoto': FieldValue.delete(),
      'profilePhotoPath': path,
    }, SetOptions(merge: true));
  }

  Future<void> deletePhoto() async {
    final user = currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      'profilePhoto': FieldValue.delete(),
      'profilePhotoPath': FieldValue.delete(),
    }, SetOptions(merge: true));
    try {
      await _supabase.storage.from('shipping-documents').remove([
        'users/${user.uid}/profile.jpg',
        'users/${user.uid}/profile.png',
      ]);
    } catch (_) {}
  }

  Future<Uint8List?> downloadPhoto(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      return await _supabase.storage.from('shipping-documents').download(path);
    } catch (_) {
      return null;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = currentUser;
    if (user?.email == null) throw StateError('Authentication required');
    final credential = EmailAuthProvider.credential(
      email: user!.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount(String password) async {
    final user = currentUser;
    if (user?.email == null) throw StateError('Authentication required');
    final credential = EmailAuthProvider.credential(
      email: user!.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    final ref = _firestore.collection('account_deletion_requests').doc(user.uid);
    final document = await ref.get();
    if (!document.exists) {
      await ref.set({
        'userId': user.uid,
        'email': user.email ?? '',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await ref.update({
      'status': 'deleted',
      'deletedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  Future<void> signOut() => _auth.signOut();
}
