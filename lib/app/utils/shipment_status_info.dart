import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../locale_controller.dart';

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
