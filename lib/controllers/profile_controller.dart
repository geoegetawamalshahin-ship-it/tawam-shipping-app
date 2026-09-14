import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models/user_profile.dart';
import '../data/services/auth_service.dart';
import '../data/services/profile_image_service.dart';
import 'auth_controller.dart';
import 'locale_controller.dart';

class ProfileController extends GetxController {
  ProfileController(this._authController, this._authService, this._images);

  final AuthController _authController;
  final AuthService _authService;
  final ProfileImageService _images;

  final fullName = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final company = 'Not provided'.obs;
  final address = 'Not provided'.obs;
  final selectedLanguage = 'English'.obs;
  final customerId = ''.obs;
  final shipmentsCount = 0.obs;
  final inTransitCount = 0.obs;
  final quotesCount = 0.obs;
  final isLoading = true.obs;
  final loadError = RxnString();
  final notificationsEnabled = true.obs;
  final profilePhotoBytes = Rxn<Uint8List>();
  final isUpdatingPhoto = false.obs;
  final messageCode = RxnString();

  bool _profileRequested = false;
  bool _statsRequested = false;
  bool _closed = false;
  var _profileRequestId = 0;
  var _statsRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadStats();
  }

  @override
  void onClose() {
    _closed = true;
    _profileRequestId++;
    _statsRequestId++;
    super.onClose();
  }

  bool _isCurrentUser(int requestId, int currentId, String userId) {
    return !_closed &&
        requestId == currentId &&
        _authController.currentUser?.uid == userId;
  }

  Future<void> loadProfile({bool force = false}) async {
    if (!force && _profileRequested) return;
    _profileRequested = true;
    final user = _authController.currentUser;
    if (user == null) {
      _profileRequested = false;
      isLoading.value = false;
      return;
    }

    final userId = user.uid;
    final requestId = ++_profileRequestId;
    isLoading.value = true;
    loadError.value = null;

    try {
      final data = await _authController.loadUserDocument(userId);
      if (!_isCurrentUser(requestId, _profileRequestId, userId)) return;

      final profile = UserProfile.fromMap(userId, data);
      final shortUid = userId.length >= 8 ? userId.substring(0, 8) : userId;

      final photoBytes = _authController.bytesFromProfilePhoto(
        profile.profilePhoto,
      );
      final downloadedBytes =
          photoBytes ??
          await _authController.downloadProfilePhoto(profile.profilePhotoPath);
      if (!_isCurrentUser(requestId, _profileRequestId, userId)) return;

      fullName.value = profile.name.isEmpty
          ? (user.displayName ?? '')
          : profile.name;
      email.value = profile.email.isEmpty ? (user.email ?? '') : profile.email;
      phone.value = profile.phone;
      company.value = profile.company.isEmpty
          ? 'Not provided'
          : profile.company;
      address.value = profile.address.isEmpty
          ? 'Not provided'
          : profile.address;
      selectedLanguage.value = profile.language.isEmpty
          ? 'English'
          : profile.language;
      notificationsEnabled.value = profile.notificationsEnabled;
      customerId.value = profile.customerId.isEmpty
          ? 'TW-${shortUid.toUpperCase()}'
          : profile.customerId;
      profilePhotoBytes.value = downloadedBytes;
      isLoading.value = false;

      if (!_isCurrentUser(requestId, _profileRequestId, userId)) return;
      LocaleController.setLanguage(selectedLanguage.value);
      await Get.updateLocale(LocaleController.locale.value);
    } catch (_) {
      if (!_isCurrentUser(requestId, _profileRequestId, userId)) return;
      _profileRequested = false;
      isLoading.value = false;
      loadError.value = 'unable_to_load';
    }
  }

  Future<void> loadStats({bool force = false}) async {
    if (!force && _statsRequested) return;
    _statsRequested = true;
    final user = _authController.currentUser;
    if (user == null) return;
    final userId = user.uid;
    final requestId = ++_statsRequestId;
    try {
      final stats = await _authController.loadProfileStats(userId);
      if (!_isCurrentUser(requestId, _statsRequestId, userId)) return;
      shipmentsCount.value = stats['shipmentsCount'] ?? 0;
      inTransitCount.value = stats['inTransitCount'] ?? 0;
      quotesCount.value = stats['quotesCount'] ?? 0;
    } catch (_) {
      if (!_isCurrentUser(requestId, _statsRequestId, userId)) return;
      messageCode.value = 'generic';
    }
  }

  Future<String> saveEditedProfile({
    required String name,
    required String phone,
    required String company,
    required String address,
  }) async {
    final user = _authController.currentUser;
    if (user == null) return 'unsigned';

    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    final trimmedCompany = company.trim();
    final trimmedAddress = address.trim();
    final companyValue = trimmedCompany.isEmpty
        ? 'Not provided'
        : trimmedCompany;
    final addressValue = trimmedAddress.isEmpty
        ? 'Not provided'
        : trimmedAddress;

    try {
      await _authController.mergeUserFields(user.uid, {
        'name': trimmedName,
        'phone': trimmedPhone,
        'company': companyValue,
        'address': addressValue,
      });
      await _authController.updateDisplayName(trimmedName);
      if (_closed) return 'unsigned';
      fullName.value = trimmedName;
      this.phone.value = trimmedPhone;
      this.company.value = companyValue;
      this.address.value = addressValue;
      return 'updated';
    } catch (_) {
      return 'failed';
    }
  }

  Future<void> saveNotificationPreference(bool value) async {
    final user = _authController.currentUser;
    if (user == null) return;

    notificationsEnabled.value = value;
    try {
      await _authController.mergeUserFields(user.uid, {
        'notificationsEnabled': value,
      });
      if (value) {
        await _authController.enablePushToken(user.uid);
      } else {
        await _authController.disablePushToken(user.uid);
      }
    } catch (_) {
      notificationsEnabled.value = !value;
      messageCode.value = 'generic';
    }
  }

  Future<String?> pickAndSavePhoto(ImageSource source) async {
    final user = _authController.currentUser;
    if (user == null) return 'generic';

    final previous = profilePhotoBytes.value;
    var didPreview = false;

    try {
      final originalBytes = await _images.pickCompressed(source);
      if (originalBytes == null) return null;
      if (originalBytes.isEmpty) return 'update_photo';

      final bytes = await _images.prepareProfilePhoto(originalBytes);
      if (bytes.isEmpty || bytes.length > 500 * 1024) {
        return 'update_photo';
      }

      profilePhotoBytes.value = bytes;
      isUpdatingPhoto.value = true;
      didPreview = true;

      await _authController.persistProfilePhoto(user.uid, bytes);
      isUpdatingPhoto.value = false;
      return 'updated';
    } on PlatformException catch (e) {
      if (didPreview) profilePhotoBytes.value = previous;
      isUpdatingPhoto.value = false;
      final code = e.code.toLowerCase();
      if (code.contains('camera')) return 'camera';
      if (code.contains('photo') || code.contains('gallery')) return 'photos';
      return 'update_photo';
    } catch (_) {
      if (didPreview) profilePhotoBytes.value = previous;
      isUpdatingPhoto.value = false;
      return 'update_photo';
    }
  }

  Future<String?> removeProfilePhoto() async {
    final user = _authController.currentUser;
    if (user == null) return 'generic';
    final previous = profilePhotoBytes.value;
    profilePhotoBytes.value = null;
    isUpdatingPhoto.value = true;
    try {
      await _authController.deleteStoredProfilePhoto(user.uid);
      isUpdatingPhoto.value = false;
      return 'removed';
    } catch (_) {
      profilePhotoBytes.value = previous;
      isUpdatingPhoto.value = false;
      return 'remove_failed';
    }
  }

  Future<void> mergeProfileFields(Map<String, dynamic> data) {
    final user = _authController.currentUser;
    if (user == null) return Future.value();
    return _authController.mergeUserFields(user.uid, data);
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _authController.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<String?> requestAccountDeletion({required String password}) {
    return _authController.requestAccountDeletion(password: password);
  }

  AuthController get auth => _authController;

  AuthService get authService => _authService;
}
