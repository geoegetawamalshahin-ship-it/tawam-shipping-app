import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/booking_service.dart';
import '../../data/services/home_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/profile_service.dart';
import '../../data/services/quote_service.dart';
import '../../data/services/shipment_service.dart';
import '../../data/services/support_service.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/booking_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/notification_controller.dart';
import '../../presentation/controllers/profile_controller.dart';
import '../../presentation/controllers/quote_controller.dart';
import '../../presentation/controllers/shipment_controller.dart';
import '../../presentation/controllers/support_controller.dart';

/// Registers the shared SDK clients once for the whole application.
///
/// Feature controllers depend on these registrations instead of constructing
/// Firebase and Supabase clients directly inside widgets.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);
    Get.put<SupabaseClient>(Supabase.instance.client, permanent: true);
    Get.put<AuthService>(
      AuthService(Get.find<FirebaseAuth>(), Get.find<FirebaseFirestore>()),
      permanent: true,
    );
    Get.put<AuthController>(
      AuthController(Get.find<AuthService>()),
      permanent: true,
    );
    Get.put<HomeService>(
      HomeService(Get.find<FirebaseFirestore>()),
      permanent: true,
    );
    Get.put<QuoteService>(
      QuoteService(Get.find<FirebaseAuth>(), Get.find<FirebaseFirestore>()),
      permanent: true,
    );
    Get.put<BookingService>(
      BookingService(Get.find<FirebaseAuth>(), Get.find<FirebaseFirestore>()),
      permanent: true,
    );
    Get.put<ShipmentService>(
      ShipmentService(
        Get.find<FirebaseAuth>(),
        Get.find<FirebaseFirestore>(),
        Get.find<SupabaseClient>(),
      ),
      permanent: true,
    );
    Get.put<SupportService>(
      SupportService(Get.find<FirebaseAuth>(), Get.find<FirebaseFirestore>()),
      permanent: true,
    );
    Get.put<ProfileService>(
      ProfileService(
        Get.find<FirebaseAuth>(),
        Get.find<FirebaseFirestore>(),
        FirebaseMessaging.instance,
        Get.find<SupabaseClient>(),
      ),
      permanent: true,
    );
    Get.put<NotificationService>(
      NotificationService(
        Get.find<FirebaseAuth>(),
        Get.find<FirebaseFirestore>(),
      ),
      permanent: true,
    );
    Get.lazyPut<QuoteController>(
      () => QuoteController(Get.find<QuoteService>()),
      fenix: true,
    );
    Get.lazyPut<BookingController>(
      () => BookingController(Get.find<BookingService>()),
      fenix: true,
    );
    Get.lazyPut<ShipmentController>(
      () => ShipmentController(Get.find<ShipmentService>()),
      fenix: true,
    );
    Get.lazyPut<SupportController>(
      () => SupportController(Get.find<SupportService>()),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find<ProfileService>()),
      fenix: true,
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(Get.find<NotificationService>()),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<HomeService>(),
        Get.find<AuthController>(),
      ),
      fenix: true,
    );
  }
}
