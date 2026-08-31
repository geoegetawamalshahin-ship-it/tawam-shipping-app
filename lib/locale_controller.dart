import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

class LocaleController {
  static const List<String> languageNames = ['English', 'Arabic'];

  static final ValueNotifier<Locale> locale = ValueNotifier<Locale>(
    const Locale('en'),
  );

  static String get languageCode => locale.value.languageCode;

  static String get languageName {
    switch (languageCode) {
      case 'ar':
        return 'Arabic';

      default:
        return 'English';
    }
  }

  static String get languageBadge {
    switch (languageCode) {
      case 'ar':
        return 'AR';

      default:
        return 'EN';
    }
  }

  static void setLanguage(String language) {
    switch (language) {
      case 'Arabic':
        locale.value = const Locale('ar');
        break;

      default:
        locale.value = const Locale('en');
    }
  }

  // Restore the saved language from the signed-in user document.
  static Future<void> restoreFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final language = doc.data()?['language']?.toString();
      if (language == null || language.isEmpty) return;

      setLanguage(language);
    } catch (_) {
      // Keep the current in-memory locale if restore fails.
    }
  }

  // Apply the locale immediately and persist it for the signed-in user.
  static Future<void> saveLanguage(String language) async {
    setLanguage(language);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'language': language,
    }, SetOptions(merge: true));
  }

  // Resolve a banner image for the active locale, with English fallback.
  static String bannerAsset(String fileName) {
    final code = languageCode;
    if (code == 'ar') {
      return 'assets/images/banners/$code/$fileName';
    }
    return 'assets/images/banners/en/$fileName';
  }

  static String normalizeStatus(String status) {
    final normalized = status
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (normalized == 'approved') return 'confirmed';
    if (normalized == 'canceled') return 'cancelled';
    if (normalized == 'customs') return 'customs_clearance';
    return normalized;
  }

  // Translate a stored shipment status without changing the backend value.
  static String statusLabel(AppLocalizations l10n, String status) {
    switch (normalizeStatus(status)) {
      case 'confirmed':
        return l10n.statusConfirmed;
      case 'prepared':
        return l10n.statusPrepared;
      case 'in_transit':
        return l10n.statusInTransit;
      case 'customs_clearance':
        return l10n.statusCustoms;
      case 'out_for_delivery':
        return l10n.statusOutForDelivery;
      case 'delivered':
        return l10n.statusDelivered;
      case 'cancelled':
        return l10n.statusCancelled;
      default:
        return l10n.statusPending;
    }
  }

  static String supportStatusLabel(AppLocalizations l10n, String status) {
    switch (status.trim().toLowerCase()) {
      case 'in_progress':
      case 'in progress':
        return l10n.statusInProgress;
      case 'resolved':
      case 'closed':
        return l10n.statusResolved;
      default:
        return l10n.statusNew;
    }
  }

  static String monthAbbrev(AppLocalizations l10n, int month) {
    switch (month) {
      case 1:
        return l10n.monthJan;
      case 2:
        return l10n.monthFeb;
      case 3:
        return l10n.monthMar;
      case 4:
        return l10n.monthApr;
      case 5:
        return l10n.monthMay;
      case 6:
        return l10n.monthJun;
      case 7:
        return l10n.monthJul;
      case 8:
        return l10n.monthAug;
      case 9:
        return l10n.monthSep;
      case 10:
        return l10n.monthOct;
      case 11:
        return l10n.monthNov;
      default:
        return l10n.monthDec;
    }
  }

  static String serviceLabel(AppLocalizations l10n, String service) {
    switch (service) {
      case 'Air Freight':
        return l10n.serviceAirFreight;
      case 'Land Freight':
        return l10n.serviceLandFreight;
      case 'Car Shipping':
        return l10n.serviceCarShipping;
      case 'International Moving':
        return l10n.serviceInternationalMoving;
      case 'Parcel Shipping':
        return l10n.serviceParcelShipping;
      default:
        return l10n.serviceSeaFreight;
    }
  }

  static const Set<String> _knownNotificationEvents = {
    'shipment_created',
    'shipment_pending',
    'shipment_in_transit',
    'shipment_delivered',
    'shipment_out_for_delivery',
    'shipment_confirmed',
    'shipment_customs',
    'shipment_prepared',
    'shipment_cancelled',
    'quote_ready',
    'support_reply',
  };

  // Normalize backend event names without changing the stored value.
  static String _normalizeNotificationEvent(String? event) {
    var value = (event ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    if (value == 'created' ||
        value == 'new_shipment' ||
        value == 'new_shipment_created') {
      return 'shipment_created';
    }
    if (value == 'canceled') value = 'cancelled';
    if (value == 'shipment_canceled') value = 'shipment_cancelled';
    if (value == 'in_transit' || value == 'shipment_update') {
      return 'shipment_in_transit';
    }
    if (value == 'delivered') return 'shipment_delivered';
    if (value == 'out_for_delivery') return 'shipment_out_for_delivery';
    if (value == 'confirmed' || value == 'approved') {
      return 'shipment_confirmed';
    }
    if (value == 'customs' || value == 'customs_clearance') {
      return 'shipment_customs';
    }
    if (value == 'prepared') return 'shipment_prepared';
    if (value == 'cancelled') return 'shipment_cancelled';
    if (value == 'quote' || value == 'quotation' || value == 'quote_ready') {
      return 'quote_ready';
    }
    if (value == 'support' || value == 'support_reply') return 'support_reply';

    return value;
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final needle in needles) {
      if (haystack.contains(needle)) return true;
    }
    return false;
  }

  // Infer a known event from stored English/Arabic title and body.
  static String inferNotificationEvent({
    String? event,
    String? type,
    String? title,
    String? message,
  }) {
    final explicit = _normalizeNotificationEvent(event);
    if (_knownNotificationEvents.contains(explicit)) return explicit;

    final haystack = '${title ?? ''} ${message ?? ''}'.toLowerCase();
    if (_containsAny(haystack, [
      'new shipment created',
      'shipment created',
      'was created for',
      'تم إنشاء شحنة',
      'تم إنشاء الشحنة',
    ])) {
      return 'shipment_created';
    }
    if (_containsAny(haystack, [
      'awaiting processing',
      'بانتظار المعالجة',
      'قيد المعالجة',
    ])) {
      return 'shipment_pending';
    }
    if (_containsAny(haystack, [
      'out for delivery',
      'out for final delivery',
      'out_for_delivery',
      'خرجت للتسليم',
    ])) {
      return 'shipment_out_for_delivery';
    }
    if (_containsAny(haystack, ['delivered', 'تم تسليم'])) {
      return 'shipment_delivered';
    }
    if (_containsAny(haystack, ['customs', 'جمرك'])) {
      return 'shipment_customs';
    }
    if (_containsAny(haystack, [
      'quote ready',
      'quotation is ready',
      'your quotation',
      'عرض السعر',
    ])) {
      return 'quote_ready';
    }
    if (_containsAny(haystack, [
      'support reply',
      'support request',
      'رد الدعم',
      'طلب الدعم',
    ])) {
      return 'support_reply';
    }
    if (_containsAny(haystack, ['confirmed', 'تم تأكيد'])) {
      return 'shipment_confirmed';
    }
    if (_containsAny(haystack, ['prepared', 'تم تجهيز'])) {
      return 'shipment_prepared';
    }
    if (_containsAny(haystack, ['cancelled', 'canceled', 'تم إلغاء'])) {
      return 'shipment_cancelled';
    }
    if (_containsAny(haystack, ['in transit', 'in_transit', 'قيد النقل'])) {
      return 'shipment_in_transit';
    }
    if (_containsAny(haystack, ['shipment update', 'تحديث الشحنة'])) {
      return 'shipment_in_transit';
    }

    final normalizedType = (type ?? '').trim().toLowerCase();
    if (normalizedType == 'quote') return 'quote_ready';
    if (normalizedType == 'support') return 'support_reply';

    return explicit;
  }

  static String extractTrackingNumber(
    Map<String, dynamic>? params,
    String title,
    String message,
  ) {
    final fromParams =
        (params?['trackingNumber'] ?? params?['tracking_number'] ?? '')
            .toString()
            .trim();
    if (fromParams.isNotEmpty) return fromParams;

    final text = '$message $title';
    final patterns = <RegExp>[
      RegExp(r'Shipment\s+([A-Z0-9][A-Z0-9\-_/]{2,})', caseSensitive: false),
      RegExp(r'الشحنة\s+([A-Z0-9][A-Z0-9\-_/]{2,})', caseSensitive: false),
      RegExp(r'\b(TW[-_]?[A-Z0-9]+)\b', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      final value = match?.group(1)?.trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    return '';
  }

  // Translate known notification events; return null to use stored title/message.
  static String? notificationTitle(AppLocalizations l10n, String? event) {
    switch (_normalizeNotificationEvent(event)) {
      case 'shipment_created':
        return l10n.notifShipmentCreatedTitle;
      case 'shipment_pending':
        return l10n.shipmentStatusUpdated;
      case 'shipment_in_transit':
        return l10n.notifShipmentInTransitTitle;
      case 'shipment_delivered':
        return l10n.notifShipmentDeliveredTitle;
      case 'shipment_out_for_delivery':
        return l10n.notifShipmentOutForDeliveryTitle;
      case 'shipment_confirmed':
        return l10n.notifShipmentConfirmedTitle;
      case 'shipment_customs':
        return l10n.notifShipmentCustomsTitle;
      case 'shipment_prepared':
        return l10n.notifShipmentPreparedTitle;
      case 'shipment_cancelled':
        return l10n.notifShipmentCancelledTitle;
      case 'quote_ready':
        return l10n.notifQuoteReadyTitle;
      case 'support_reply':
        return l10n.notifSupportReplyTitle;
      default:
        return null;
    }
  }

  static String? notificationBody(
    AppLocalizations l10n,
    String? event,
    Map<String, dynamic>? params,
  ) {
    final trackingNumber = (params?['trackingNumber'] ?? '').toString().trim();
    final resolvedEvent = _normalizeNotificationEvent(event);

    switch (resolvedEvent) {
      case 'shipment_created':
        return trackingNumber.isEmpty
            ? l10n.notifShipmentGenericBody
            : l10n.notifShipmentCreatedBody(trackingNumber);
      case 'shipment_pending':
        return l10n.statusDescPending;
      case 'shipment_in_transit':
        return trackingNumber.isEmpty
            ? l10n.notifShipmentGenericBody
            : l10n.notifShipmentInTransitBody(trackingNumber);
      case 'shipment_delivered':
        return trackingNumber.isEmpty
            ? l10n.notifShipmentGenericBody
            : l10n.notifShipmentDeliveredBody(trackingNumber);
      case 'shipment_out_for_delivery':
        return trackingNumber.isEmpty
            ? l10n.notifShipmentGenericBody
            : l10n.notifShipmentOutForDeliveryBody(trackingNumber);
      case 'shipment_confirmed':
        return trackingNumber.isEmpty
            ? l10n.notifShipmentGenericBody
            : l10n.notifShipmentConfirmedBody(trackingNumber);
      case 'shipment_customs':
        return trackingNumber.isEmpty
            ? l10n.notifShipmentGenericBody
            : l10n.notifShipmentCustomsBody(trackingNumber);
      case 'shipment_prepared':
        return trackingNumber.isEmpty
            ? l10n.notifShipmentGenericBody
            : l10n.notifShipmentPreparedBody(trackingNumber);
      case 'shipment_cancelled':
        return trackingNumber.isEmpty
            ? l10n.notifShipmentGenericBody
            : l10n.notifShipmentCancelledBody(trackingNumber);
      case 'quote_ready':
        return l10n.notifQuoteReadyBody;
      case 'support_reply':
        return l10n.notifSupportReplyBody;
      default:
        return null;
    }
  }

  // Localized title for in-app and stored notifications.
  static String resolveNotificationTitle(
    AppLocalizations l10n, {
    String? event,
    String? type,
    String? storedTitle,
    String? storedMessage,
  }) {
    final resolvedEvent = inferNotificationEvent(
      event: event,
      type: type,
      title: storedTitle,
      message: storedMessage,
    );
    final localized = notificationTitle(l10n, resolvedEvent);
    if (localized != null) return localized;

    final stored = (storedTitle ?? '').trim();
    if (stored.isNotEmpty) return stored;
    return l10n.notificationDefault;
  }

  // Localized body for in-app and stored notifications.
  static String resolveNotificationBody(
    AppLocalizations l10n, {
    String? event,
    String? type,
    String? storedTitle,
    String? storedMessage,
    Map<String, dynamic>? params,
  }) {
    final resolvedEvent = inferNotificationEvent(
      event: event,
      type: type,
      title: storedTitle,
      message: storedMessage,
    );
    final trackingNumber = extractTrackingNumber(
      params,
      storedTitle ?? '',
      storedMessage ?? '',
    );
    final localized = notificationBody(l10n, resolvedEvent, {
      'trackingNumber': trackingNumber,
    });
    if (localized != null) return localized;

    return (storedMessage ?? '').trim();
  }

  // Localized AM/PM marker for a 24-hour clock value.
  static String timePeriod(AppLocalizations l10n, int hour) {
    return hour >= 12 ? l10n.periodPm : l10n.periodAm;
  }

  // Show a stored option as a localized word, with a fallback when empty.
  static String displayOption(
    AppLocalizations l10n,
    String? value, {
    String? emptyLabel,
  }) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return emptyLabel ?? l10n.notSpecified;
    }
    return optionLabel(l10n, raw);
  }

  // Display label for stored English option values. Unknown values stay as-is.
  static String optionLabel(AppLocalizations l10n, String value) {
    switch (value.trim()) {
      case 'Door to Door':
        return l10n.doorToDoor;
      case 'Port to Port':
        return l10n.portToPort;
      case 'Door to Port':
        return l10n.doorToPort;
      case 'Port to Door':
        return l10n.portToDoor;
      case 'Airport to Airport':
        return l10n.airportToAirport;
      case 'Door to Airport':
        return l10n.doorToAirport;
      case 'Airport to Door':
        return l10n.airportToDoor;
      case 'Depot to Depot':
        return l10n.depotToDepot;
      case 'Door to Depot':
        return l10n.doorToDepot;
      case 'Depot to Door':
        return l10n.depotToDoor;
      case 'Recommend for Me':
        return l10n.recommendForMe;
      case 'Customs Clearance':
        return l10n.customsClearance;
      case 'Pickup':
        return l10n.pickup;
      case 'Delivery':
        return l10n.delivery;
      case 'Export Documentation':
        return l10n.exportDocumentation;
      case 'Packing':
        return l10n.packing;
      case 'Loose Cargo':
        return l10n.looseCargo;
      case 'Boxes':
        return l10n.boxes;
      case 'Pallets':
        return l10n.pallets;
      case 'Full Container':
        return l10n.fullContainer;
      case 'Shared Cargo':
        return l10n.sharedCargo;
      case 'Full Container Load':
        return l10n.fullContainerLoad;
      case 'Less Container Load':
        return l10n.lessContainerLoad;
      case 'Flat Rack':
        return l10n.flatRack;
      case 'Packing List Review':
        return l10n.packingListReview;
      case 'Open Carrier':
        return l10n.openCarrier;
      case 'Enclosed Carrier':
        return l10n.enclosedCarrier;
      case 'RoRo Shipping':
        return l10n.roroShipping;
      case 'Container Shipping':
        return l10n.containerShipping;
      case 'Sedan':
        return l10n.sedan;
      case 'SUV':
        return l10n.suv;
      case 'Van':
        return l10n.van;
      case 'Motorcycle':
        return l10n.motorcycle;
      case 'Luxury / Classic':
        return l10n.luxuryClassic;
      case 'Commercial Vehicle':
        return l10n.commercialVehicle;
      case 'Running':
        return l10n.running;
      case 'Non-Running':
        return l10n.nonRunning;
      case 'Damaged / Accident':
        return l10n.damagedAccident;
      case 'Vehicle Inspection':
        return l10n.vehicleInspection;
      case 'Full Truck Load':
        return l10n.fullTruckLoad;
      case 'Partial Load':
        return l10n.partialLoad;
      case 'Less Than Truck Load':
        return l10n.lessThanTruckLoad;
      case 'Curtain Side':
        return l10n.curtainSide;
      case 'Box Truck':
        return l10n.boxTruck;
      case 'Border Documentation':
        return l10n.borderDocumentation;
      case 'Loading / Unloading':
        return l10n.loadingUnloading;
      case 'Home Move':
        return l10n.homeMove;
      case 'Apartment':
        return l10n.apartment;
      case 'Villa':
        return l10n.villa;
      case 'Townhouse':
        return l10n.townhouse;
      case 'Studio':
        return l10n.studio;
      case 'Office':
        return l10n.office;
      case 'Warehouse':
        return l10n.warehouse;
      case 'Office Move':
        return l10n.officeMove;
      case 'Personal Effects':
      case 'Personal effects':
        return l10n.personalEffects;
      case 'Piano':
        return l10n.piano;
      case 'Safe':
        return l10n.safe;
      case 'Artwork':
        return l10n.artwork;
      case 'Large Appliances':
        return l10n.largeAppliances;
      case 'Fragile Items':
        return l10n.fragileItems;
      case 'High-Value Items':
        return l10n.highValueItems;
      case 'Packing Materials':
        return l10n.packingMaterials;
      case 'Furniture Reassembly':
        return l10n.furnitureReassembly;
      case 'Debris Removal':
        return l10n.debrisRemoval;
      case 'Elevator':
        return l10n.elevator;
      case 'Unpacking':
        return l10n.unpacking;
      case 'Moving Insurance':
        return l10n.movingInsurance;
      case 'Door Pickup':
        return l10n.doorPickup;
      case 'Envelope / Document':
        return l10n.envelopeDocument;
      case 'Padded Bag':
        return l10n.paddedBag;
      case 'Proof of Delivery':
        return l10n.proofOfDelivery;
      case 'Economy':
        return l10n.economy;
      case 'Fragile':
        return l10n.fragile;
      case 'General Cargo':
        return l10n.cargoGeneral;
      case 'Heavy Equipment':
        return l10n.cargoHeavyEquipment;
      case 'Furniture':
        return l10n.cargoFurniture;
      case 'Electronics':
        return l10n.cargoElectronics;
      case 'Food Products':
        return l10n.cargoFoodProducts;
      case 'Medical Supplies':
        return l10n.cargoMedicalSupplies;
      case 'Road Freight':
        return l10n.roadFreight;
      case 'Sea Freight':
        return l10n.serviceSeaFreight;
      case 'Air Freight':
        return l10n.serviceAirFreight;
      case 'Land Freight':
        return l10n.serviceLandFreight;
      case 'Car Shipping':
        return l10n.serviceCarShipping;
      case 'International Moving':
        return l10n.serviceInternationalMoving;
      case 'Parcel Shipping':
        return l10n.serviceParcelShipping;
      case 'Morning':
        return l10n.morning;
      case 'Afternoon':
        return l10n.afternoon;
      case 'Evening':
        return l10n.evening;
      case 'Flexible':
        return l10n.flexible;
      case 'Standard':
        return l10n.standard;
      case 'Express':
        return l10n.express;
      case 'Priority':
        return l10n.priority;
      case 'Crates':
        return l10n.crates;
      case 'Bags':
        return l10n.bags;
      case 'Drop-off':
        return l10n.dropOff;
      case 'Reefer':
        return l10n.reefer;
      case 'Flatbed':
        return l10n.flatbed;
      case 'Lowbed':
        return l10n.lowbed;
      case 'Open Top':
        return l10n.openTop;
      case '20FT Standard':
        return l10n.ft20Standard;
      case '40FT Standard':
        return l10n.ft40Standard;
      case '40FT HC':
        return l10n.ft40Hc;
      case '20FT Reefer':
        return l10n.ft20Reefer;
      case '40FT Reefer':
        return l10n.ft40Reefer;
      case 'Container':
        return l10n.container;
      case 'RoRo':
        return l10n.roroShipping;
      case 'Other':
        return l10n.otherOption;
      case 'Vehicles':
        return l10n.vehicles;
      case 'Household Goods & Personal Effects':
        return l10n.householdGoodsPersonalEffects;
      case 'Office Relocation':
        return l10n.officeRelocation;
      case 'Box':
        return l10n.packageBox;
      case 'Tube':
        return l10n.packageTube;
      case 'Professional Packing':
        return l10n.professionalPacking;
      case 'Furniture Disassembly':
        return l10n.furnitureDisassembly;
      case 'Temporary Storage':
        return l10n.temporaryStorage;
      case 'Shipment Tracking':
        return l10n.catShipmentTracking;
      case 'Delivery Delay':
        return l10n.catDeliveryDelay;
      case 'Request a Quote':
        return l10n.catRequestQuote;
      case 'Payment & Invoice':
        return l10n.catPaymentInvoice;
      case 'Damaged Shipment':
        return l10n.catDamagedShipment;
      case 'General Inquiry':
        return l10n.catGeneralInquiry;
      default:
        return _optionLabelFallback(l10n, value);
    }
  }

  // Translate known status codes; otherwise keep the original stored text.
  static String _optionLabelFallback(AppLocalizations l10n, String value) {
    final raw = value.trim();
    if (raw.isEmpty) return raw;

    final status = normalizeStatus(raw);
    const knownStatuses = {
      'pending',
      'confirmed',
      'prepared',
      'in_transit',
      'customs_clearance',
      'out_for_delivery',
      'delivered',
      'cancelled',
    };
    if (knownStatuses.contains(status)) {
      return statusLabel(l10n, raw);
    }

    return raw;
  }
}
