import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/booking_service.dart';
import '../../data/services/home_service.dart';
import '../../data/services/quote_service.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/booking_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/quote_controller.dart';

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
    Get.lazyPut<QuoteController>(
      () => QuoteController(Get.find<QuoteService>()),
      fenix: true,
    );
    Get.lazyPut<BookingController>(
      () => BookingController(Get.find<BookingService>()),
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
