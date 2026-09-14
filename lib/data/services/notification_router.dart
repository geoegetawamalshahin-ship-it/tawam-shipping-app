import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/app_routes.dart';
import '../../controllers/locale_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../l10n/app_localizations.dart';

class NotificationRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Map<String, String>? _pendingPayload;
  static bool _autoOpenPending = false;
  static bool homeReady = false;

  static Map<String, String> payloadFromMessage({
    required Map<String, dynamic> data,
    String? title,
    String? body,
  }) {
    return {
      'type': (data['type'] ?? '').toString(),
      'referenceId': (data['referenceId'] ?? '').toString(),
      'event': (data['event'] ?? '').toString(),
      'title': (title ?? data['title'] ?? '').toString(),
      'body': (body ?? data['message'] ?? data['body'] ?? '').toString(),
      'trackingNumber': (data['trackingNumber'] ?? '').toString(),
    };
  }

  static void remember(Map<String, String> payload, {bool autoOpen = false}) {
    _pendingPayload = payload;
    _autoOpenPending = autoOpen;
  }

  static Future<void> consumePending(BuildContext context) async {
    homeReady = true;
    final payload = _pendingPayload;
    final shouldOpen = _autoOpenPending;
    _pendingPayload = null;
    _autoOpenPending = false;
    if (payload == null) return;

    if (shouldOpen) {
      await openFromPayload(context, payload);
      return;
    }

    showForegroundBanner(context, payload);
  }

  static void showForegroundBanner(
    BuildContext context,
    Map<String, String> payload,
  ) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final event = payload['event'];
    final params = <String, dynamic>{
      'trackingNumber': payload['trackingNumber'] ?? '',
    };
    final title = LocaleController.resolveNotificationTitle(
      l10n,
      event: event,
      type: payload['type'],
      storedTitle: payload['title'],
      storedMessage: payload['body'],
    );
    final body = LocaleController.resolveNotificationBody(
      l10n,
      event: event,
      type: payload['type'],
      storedTitle: payload['title'],
      storedMessage: payload['body'],
      params: params,
    );

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final snackBarController = messenger.showSnackBar(
      SnackBar(
        content: Text(
          body.isEmpty ? title : '$title\n$body',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        persist: false,
        action: SnackBarAction(
          label: l10n.viewDetails,
          onPressed: () {
            if (!context.mounted) return;
            openFromPayload(context, payload);
          },
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      snackBarController.close();
    });
  }

  static Future<void> openFromPayload(
    BuildContext context,
    Map<String, String> payload,
  ) async {
    final type = (payload['type'] ?? '').trim().toLowerCase();
    final referenceId = (payload['referenceId'] ?? '').trim();
    final l10n = AppLocalizations.of(context);

    if (type == 'support') {
      await Get.toNamed(
        AppRoutes.mySupportRequests,
        arguments: referenceId.isEmpty ? null : referenceId,
      );
      return;
    }

    if (type == 'quote') {
      await Get.toNamed(
        AppRoutes.myQuotes,
        arguments: referenceId.isEmpty ? null : referenceId,
      );
      return;
    }

    if (type == 'shipment' && referenceId.isNotEmpty) {
      try {
        final document = await Get.find<NotificationController>().loadShipment(
          referenceId,
        );

        if (!context.mounted) return;

        if (!document.exists || document.data() == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.shipmentNotFoundShort ?? ''),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final shipment = <String, dynamic>{
          ...document.data()!,
          'id': document.id,
        };

        await Get.toNamed(AppRoutes.shipmentDetails, arguments: shipment);
      } catch (_) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.couldNotOpenShipmentDetails ?? ''),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    await Get.toNamed(AppRoutes.notifications);
  }
}
