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

  // Translate known notification events; return null to use stored title/message.
  static String? notificationTitle(AppLocalizations l10n, String? event) {
    switch ((event ?? '').trim().toLowerCase()) {
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
    final trackingNumber = (params?['trackingNumber'] ?? '').toString();

    switch ((event ?? '').trim().toLowerCase()) {
      case 'shipment_in_transit':
        return l10n.notifShipmentInTransitBody(trackingNumber);
      case 'shipment_delivered':
        return l10n.notifShipmentDeliveredBody(trackingNumber);
      case 'shipment_out_for_delivery':
        return l10n.notifShipmentOutForDeliveryBody(trackingNumber);
      case 'shipment_confirmed':
        return l10n.notifShipmentConfirmedBody(trackingNumber);
      case 'shipment_customs':
        return l10n.notifShipmentCustomsBody(trackingNumber);
      case 'quote_ready':
        return l10n.notifQuoteReadyBody;
      case 'support_reply':
        return l10n.notifSupportReplyBody;
      default:
        return null;
    }
  }
}
