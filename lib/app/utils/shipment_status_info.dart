import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../locale_controller.dart';
import 'value_formatters.dart';

const Color _statusPrimaryBlue = Color(0xFF0B4F9C);
const Color _statusSuccess = Color(0xFF16765C);
const Color _statusWarning = Color(0xFFB26A00);
const Color _statusDanger = Color(0xFFD72638);
const Color _statusBlueBackground = Color(0xFFEAF3FF);
const Color _statusWarningBackground = Color(0xFFFFF4DF);
const Color _statusSuccessBackground = Color(0xFFEAF8F0);
const Color _statusDangerBackground = Color(0xFFFFECEF);

class ShipmentStatusInfo {
  const ShipmentStatusInfo({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
    required this.progress,
    required this.description,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData icon;
  final double progress;
  final String description;
}

ShipmentStatusInfo shipmentStatusInfo(AppLocalizations l10n, String status) {
  switch (status) {
    case 'confirmed':
      return ShipmentStatusInfo(
        label: l10n.confirmedUpper,
        color: _statusPrimaryBlue,
        background: _statusBlueBackground,
        icon: Icons.verified_rounded,
        progress: .25,
        description: l10n.statusDescConfirmed,
      );
    case 'prepared':
      return ShipmentStatusInfo(
        label: l10n.preparedUpper,
        color: _statusPrimaryBlue,
        background: _statusBlueBackground,
        icon: Icons.fact_check_rounded,
        progress: .36,
        description: l10n.statusDescPrepared,
      );
    case 'in_transit':
      return ShipmentStatusInfo(
        label: l10n.inTransitUpper,
        color: _statusPrimaryBlue,
        background: _statusBlueBackground,
        icon: Icons.local_shipping_rounded,
        progress: .58,
        description: l10n.statusDescInTransit,
      );
    case 'customs':
    case 'customs_clearance':
      return ShipmentStatusInfo(
        label: l10n.customsUpper,
        color: _statusWarning,
        background: _statusWarningBackground,
        icon: Icons.gavel_rounded,
        progress: .72,
        description: l10n.statusDescCustoms,
      );
    case 'out_for_delivery':
      return ShipmentStatusInfo(
        label: l10n.outForDeliveryUpper,
        color: _statusPrimaryBlue,
        background: _statusBlueBackground,
        icon: Icons.route_rounded,
        progress: .88,
        description: l10n.statusDescOutForDelivery,
      );
    case 'delivered':
      return ShipmentStatusInfo(
        label: l10n.deliveredUpper,
        color: _statusSuccess,
        background: _statusSuccessBackground,
        icon: Icons.check_circle_rounded,
        progress: 1,
        description: l10n.statusDescDelivered,
      );
    case 'cancelled':
      return ShipmentStatusInfo(
        label: l10n.cancelledUpper,
        color: _statusDanger,
        background: _statusDangerBackground,
        icon: Icons.cancel_rounded,
        progress: 0,
        description: l10n.statusDescCancelled,
      );
    case 'pending':
    default:
      return ShipmentStatusInfo(
        label: l10n.pendingUpper,
        color: _statusWarning,
        background: _statusWarningBackground,
        icon: Icons.schedule_rounded,
        progress: .10,
        description: l10n.statusDescPending,
      );
  }
}

IconData shipmentTimelineIcon(String value) {
  final status = LocaleController.normalizeStatus(value);

  if (status.contains('deliver')) {
    return Icons.check_circle_outline_rounded;
  }

  if (status.contains('custom')) {
    return Icons.gavel_outlined;
  }

  if (status.contains('transit') ||
      status.contains('depart') ||
      status.contains('moving')) {
    return Icons.local_shipping_outlined;
  }

  if (status.contains('confirm') || status.contains('approve')) {
    return Icons.verified_outlined;
  }

  if (status.contains('prepare') || status.contains('warehouse')) {
    return Icons.inventory_2_outlined;
  }

  return Icons.circle_outlined;
}

String prettyShipmentStatus(
  AppLocalizations l10n,
  String value, {
  bool mapShipmentCreated = false,
}) {
  final raw = value.trim();
  if (raw.isEmpty) {
    return l10n.shipmentUpdate;
  }
  if (mapShipmentCreated && raw.toLowerCase() == 'shipment_created') {
    return l10n.notifShipmentCreatedTitle;
  }
  final normalized = LocaleController.normalizeStatus(raw);
  const known = {
    'pending',
    'confirmed',
    'prepared',
    'in_transit',
    'customs_clearance',
    'out_for_delivery',
    'delivered',
    'cancelled',
  };

  if (known.contains(normalized)) {
    return LocaleController.statusLabel(l10n, raw);
  }

  return LocaleController.optionLabel(l10n, raw);
}

const List<String> shipmentTrackLocationKeys = [
  'currentLocation',
  'currentArea',
  'lastLocation',
  'location',
];

const List<String> shipmentDetailsLocationKeys = [
  'currentLocationName',
  ...shipmentTrackLocationKeys,
];

String shipmentCurrentLocation({
  required Map<String, dynamic> shipment,
  required String status,
  required String pickup,
  required String delivery,
  List<String> locationKeys = shipmentTrackLocationKeys,
}) {
  final liveLocation = stringFromKeys(shipment, locationKeys, fallback: '');

  if (liveLocation.isNotEmpty) {
    return liveLocation;
  }

  if (status == 'delivered' || status == 'out_for_delivery') {
    return delivery;
  }

  if (status == 'pending' || status == 'confirmed' || status == 'prepared') {
    return pickup;
  }

  return '';
}

const List<String> shipmentTrackHistoryKeys = [
  'trackingHistory',
  'timeline',
  'history',
];

const List<String> shipmentDetailsHistoryKeys = [
  'statusHistory',
  ...shipmentTrackHistoryKeys,
];

const List<String> shipmentTrackHistoryTimeKeys = [
  'timestamp',
  'updatedAt',
  'date',
  'time',
];

const List<String> shipmentDetailsHistoryTimeKeys = [
  'changedAt',
  ...shipmentTrackHistoryTimeKeys,
];

class ShipmentHistoryItem {
  const ShipmentHistoryItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });

  final String title;
  final String description;
  final String time;
  final IconData icon;
}

List<ShipmentHistoryItem> shipmentHistoryItems(
  AppLocalizations l10n,
  Map<String, dynamic> shipment, {
  List<String> historyKeys = shipmentTrackHistoryKeys,
  List<String> timeKeys = shipmentTrackHistoryTimeKeys,
  bool mapShipmentCreated = false,
}) {
  final raw = firstKeyedValue(shipment, historyKeys);

  if (raw is! List || raw.isEmpty) {
    return [];
  }

  final result = <ShipmentHistoryItem>[];

  for (final item in raw) {
    if (item is! Map) {
      continue;
    }

    final map = Map<String, dynamic>.from(item);

    final title = stringFromKeys(map, [
      'title',
      'status',
      'event',
    ], fallback: l10n.shipmentUpdate);

    final description = stringFromKeys(map, [
      'description',
      'note',
      'details',
      'location',
    ], fallback: l10n.shipmentStatusUpdated);

    final time = formatOptionalLocalizedDateTime(
      l10n,
      firstKeyedValue(map, timeKeys),
      emptyFallback: l10n.awaitingUpdate,
    );

    result.add(
      ShipmentHistoryItem(
        title: prettyShipmentStatus(
          l10n,
          title,
          mapShipmentCreated: mapShipmentCreated,
        ),
        description:
            mapShipmentCreated &&
                title.trim().toLowerCase() == 'shipment_created'
            ? l10n.timelineCreatedDesc
            : description,
        time: time,
        icon: shipmentTimelineIcon(title),
      ),
    );
  }

  return result;
}
