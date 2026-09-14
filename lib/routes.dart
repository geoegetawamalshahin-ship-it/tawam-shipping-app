import 'package:get/get.dart';

import 'constant/app_routes.dart';
import 'page_bindings.dart';
import 'pages/air_freight_screen.dart';
import 'pages/car_shipping_screen.dart';
import 'pages/create_booking_screen.dart';
import 'pages/forgot_password_screen.dart';
import 'pages/get_quote_screen.dart';
import 'pages/home_screen.dart';
import 'pages/international_moving_screen.dart';
import 'pages/land_freight_screen.dart';
import 'pages/login_screen.dart';
import 'pages/my_bookings_screen.dart';
import 'pages/my_quotes_screen.dart';
import 'pages/my_support_requests_screen.dart';
import 'pages/notifications_screen.dart';
import 'pages/parcel_shipping_screen.dart';
import 'pages/privacy_policy_screen.dart';
import 'pages/profile_screen.dart';
import 'pages/register_screen.dart';
import 'pages/request_quote_screen.dart';
import 'pages/sea_freight_screen.dart';
import 'pages/shipment_details_screen.dart';
import 'pages/shipment_request_page.dart';
import 'pages/shipments_screen.dart';
import 'pages/shipping_documents_screen.dart';
import 'pages/splash_screen.dart';
import 'pages/support_screen.dart';
import 'pages/terms_conditions_screen.dart';
import 'pages/track_shipment_screen.dart';
import 'pages/volume_calculator_screen.dart';

final List<GetPage<dynamic>> appPages = [
  GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
  GetPage(
    name: AppRoutes.login,
    page: () => const LoginScreen(),
    binding: LoginBinding(),
  ),
  GetPage(
    name: AppRoutes.register,
    page: () => const RegisterScreen(),
    binding: RegisterBinding(),
  ),
  GetPage(
    name: AppRoutes.forgotPassword,
    page: () => const ForgotPasswordScreen(),
    binding: ForgotPasswordBinding(),
  ),
  GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
  GetPage(
    name: AppRoutes.airFreight,
    page: () => const AirFreightScreen(),
    binding: AirFreightBinding(),
  ),
  GetPage(
    name: AppRoutes.seaFreight,
    page: () => const SeaFreightScreen(),
    binding: SeaFreightBinding(),
  ),
  GetPage(
    name: AppRoutes.landFreight,
    page: () => const LandFreightScreen(),
    binding: LandFreightBinding(),
  ),
  GetPage(
    name: AppRoutes.carShipping,
    page: () => const CarShippingScreen(),
    binding: CarShippingBinding(),
  ),
  GetPage(
    name: AppRoutes.parcelShipping,
    page: () => const ParcelShippingScreen(),
    binding: ParcelShippingBinding(),
  ),
  GetPage(
    name: AppRoutes.internationalMoving,
    page: () => const InternationalMovingScreen(),
    binding: InternationalMovingBinding(),
  ),
  GetPage(
    name: AppRoutes.getQuote,
    page: () => const GetQuoteScreen(),
    binding: GetQuoteBinding(),
  ),
  GetPage(
    name: AppRoutes.requestQuote,
    page: () => const RequestQuoteScreen(),
    binding: RequestQuoteBinding(),
  ),
  GetPage(
    name: AppRoutes.createBooking,
    page: () => const CreateBookingScreen(),
    binding: CreateBookingBinding(),
  ),
  GetPage(
    name: AppRoutes.myQuotes,
    page: () => MyQuotesScreen(
      initialQuoteId: Get.arguments is String ? Get.arguments as String : null,
    ),
  ),
  GetPage(name: AppRoutes.myBookings, page: () => const MyBookingsScreen()),
  GetPage(
    name: AppRoutes.support,
    page: () => const SupportScreen(),
    binding: SupportFormBinding(),
  ),
  GetPage(
    name: AppRoutes.mySupportRequests,
    page: () => MySupportRequestsScreen(
      initialRequestId: Get.arguments is String
          ? Get.arguments as String
          : null,
    ),
  ),
  GetPage(
    name: AppRoutes.trackShipment,
    page: () => const TrackShipmentScreen(),
    binding: TrackShipmentBinding(),
  ),
  GetPage(
    name: AppRoutes.shipmentDetails,
    page: () => const ShipmentDetailsScreen(),
    binding: ShipmentDetailsBinding(),
  ),
  GetPage(name: AppRoutes.shipments, page: () => const ShipmentsScreen()),
  GetPage(
    name: AppRoutes.shippingDocuments,
    page: () => const ShippingDocumentsScreen(),
    binding: ShippingDocumentsBinding(),
  ),
  GetPage(
    name: AppRoutes.volumeCalculator,
    page: () => const VolumeCalculatorScreen(),
    binding: VolumeCalculatorBinding(),
  ),
  GetPage(
    name: AppRoutes.profile,
    page: () => const ProfileScreen(),
    binding: ProfileBinding(),
  ),
  GetPage(
    name: AppRoutes.notifications,
    page: () => const NotificationsScreen(),
  ),
  GetPage(
    name: AppRoutes.privacyPolicy,
    page: () => const PrivacyPolicyScreen(),
  ),
  GetPage(
    name: AppRoutes.termsConditions,
    page: () => const TermsConditionsScreen(),
  ),
  GetPage(
    name: AppRoutes.shipmentRequest,
    page: () => const ShipmentRequestPage(),
    binding: ShipmentRequestBinding(),
  ),
];
