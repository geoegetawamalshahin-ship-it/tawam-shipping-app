import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/services/profile_service.dart';

class ProfileController extends GetxController {
  ProfileController(this._service);

  final ProfileService _service;
  User? get currentUser => _service.currentUser;
  Future<Map<String, dynamic>> loadProfile() => _service.loadProfile();
  Future<Map<String, int>> loadStats() => _service.loadStats();
  Future<void> saveNotificationPreference(bool value) =>
      _service.saveNotificationPreference(value);
  Future<void> updateProfile(Map<String, dynamic> data) =>
      _service.updateProfile(data);
  Future<void> savePhoto(Uint8List bytes) => _service.savePhoto(bytes);
  Future<void> deletePhoto() => _service.deletePhoto();
  Future<Uint8List?> downloadPhoto(String? path) =>
      _service.downloadPhoto(path);
  Future<void> changePassword(String currentPassword, String newPassword) =>
      _service.changePassword(currentPassword, newPassword);
  Future<void> deleteAccount(String password) =>
      _service.deleteAccount(password);
  Future<void> signOut() => _service.signOut();
}
