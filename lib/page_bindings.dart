import 'package:get/get.dart';

import 'controllers/air_freight_controller.dart';
import 'controllers/auth_form_controllers.dart';
import 'controllers/car_shipping_controller.dart';
import 'controllers/create_booking_form_controller.dart';
import 'controllers/get_quote_form_controller.dart';
import 'controllers/international_moving_controller.dart';
import 'controllers/land_freight_controller.dart';
import 'controllers/parcel_shipping_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/request_quote_form_controller.dart';
import 'controllers/sea_freight_controller.dart';
import 'controllers/shipment_details_controller.dart';
import 'controllers/shipment_request_controller.dart';
import 'controllers/shipping_documents_controller.dart';
import 'controllers/support_form_controller.dart';
import 'controllers/track_shipment_controller.dart';
import 'controllers/volume_calculator_controller.dart';
import 'data/services/auth_service.dart';
import 'data/services/live_location_service.dart';
import 'data/services/profile_image_service.dart';
import 'data/services/quote_service.dart';
import 'data/services/shipment_request_service.dart';
import 'data/services/shipment_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/booking_controller.dart';
import 'controllers/quote_controller.dart';
import 'controllers/shipment_controller.dart';
import 'controllers/support_controller.dart';

class AirFreightBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AirFreightController(
        Get.find<QuoteService>(),
        Get.find<QuoteController>(),
      ),
    );
  }
}

class SeaFreightBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SeaFreightController(
        Get.find<QuoteService>(),
        Get.find<QuoteController>(),
      ),
    );
  }
}

class LandFreightBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => LandFreightController(
        Get.find<QuoteService>(),
        Get.find<QuoteController>(),
      ),
    );
  }
}

class CarShippingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => CarShippingController(
        Get.find<QuoteService>(),
        Get.find<QuoteController>(),
      ),
    );
  }
}

class ParcelShippingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ParcelShippingController(
        Get.find<QuoteService>(),
        Get.find<QuoteController>(),
      ),
    );
  }
}

class InternationalMovingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => InternationalMovingController(
        Get.find<QuoteService>(),
        Get.find<QuoteController>(),
      ),
    );
  }
}

class RequestQuoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => RequestQuoteFormController(Get.find<QuoteController>()),
    );
  }
}

class CreateBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => CreateBookingFormController(
        Get.find<BookingController>(),
        initialServiceType: Get.arguments is String
            ? Get.arguments as String
            : null,
      ),
    );
  }
}

class GetQuoteBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final map = args is Map ? Map<String, dynamic>.from(args) : const {};
    Get.lazyPut(
      () => GetQuoteFormController(
        Get.find<QuoteService>(),
        Get.find<QuoteController>(),
        initialServiceType: map['serviceType'] as String?,
        initialLengthCm: map['lengthCm'] as String?,
        initialWidthCm: map['widthCm'] as String?,
        initialHeightCm: map['heightCm'] as String?,
        initialQuantity: map['quantity'] as String?,
        initialWeightKg: map['weightKg'] as String?,
      ),
    );
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginFormController(Get.find<AuthController>()));
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RegisterFormController(Get.find<AuthController>()));
  }
}

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForgotPasswordController(Get.find<AuthController>()));
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ProfileController(
        Get.find<AuthController>(),
        Get.find<AuthService>(),
        Get.find<ProfileImageService>(),
      ),
    );
  }
}

class TrackShipmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => TrackShipmentController(
        Get.find<ShipmentService>(),
        initialTrackingNumber: Get.arguments is String
            ? Get.arguments as String
            : null,
      ),
    );
  }
}

class ShipmentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final shipment = args is Map<String, dynamic> ? args : <String, dynamic>{};
    Get.lazyPut(
      () => ShipmentDetailsController(
        Get.find<ShipmentService>(),
        Get.find<LiveLocationService>(),
        shipment: shipment,
      ),
    );
  }
}

class ShippingDocumentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ShippingDocumentsController(Get.find<ShipmentController>()),
    );
  }
}

class VolumeCalculatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(VolumeCalculatorController.new);
  }
}

class SupportFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupportFormController(Get.find<SupportController>()));
  }
}

class ShipmentRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ShipmentRequestController(Get.find<ShipmentRequestService>()),
    );
  }
}
