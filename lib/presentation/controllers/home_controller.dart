import 'package:get/get.dart';

import '../../data/services/home_service.dart';
import 'auth_controller.dart';

class HomeController extends GetxController {
  HomeController(this._homeService, this._authController);

  final HomeService _homeService;
  final AuthController _authController;

  String? _notificationUserId;
  Stream<int>? _unreadNotificationCount;

  Stream<int> get unreadNotificationCount {
    final userId = _authController.currentUser?.uid ?? '';
    if (_unreadNotificationCount == null || _notificationUserId != userId) {
      _notificationUserId = userId;
      _unreadNotificationCount = _homeService.unreadNotificationCount(userId);
    }
    return _unreadNotificationCount!;
  }

  Future<void> signOut() => _authController.signOut();
}
