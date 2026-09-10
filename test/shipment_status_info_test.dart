import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/utils/shipment_status_info.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_ar.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

void main() {
  test('status map keeps labels colors progress and details descriptions', () {
    final en = AppLocalizationsEn();
    final ar = AppLocalizationsAr();

    final pending = shipmentStatusInfo(en, 'pending');
    expect(pending.label, en.pendingUpper);
    expect(pending.description, en.statusDescPending);
    expect(pending.color, const Color(0xFFB26A00));
    expect(pending.background, const Color(0xFFFFF4DF));
    expect(pending.icon, Icons.schedule_rounded);
    expect(pending.progress, .10);

    final unknown = shipmentStatusInfo(en, 'not-a-status');
    expect(unknown.label, en.pendingUpper);
    expect(unknown.progress, .10);

    final confirmed = shipmentStatusInfo(en, 'confirmed');
    expect(confirmed.label, en.confirmedUpper);
    expect(confirmed.description, en.statusDescConfirmed);
    expect(confirmed.progress, .25);
    expect(confirmed.icon, Icons.verified_rounded);

    expect(shipmentStatusInfo(en, 'prepared').progress, .36);
    expect(shipmentStatusInfo(en, 'in_transit').progress, .58);

    final customs = shipmentStatusInfo(en, 'customs');
    final clearance = shipmentStatusInfo(en, 'customs_clearance');
    expect(customs.label, en.customsUpper);
    expect(clearance.label, en.customsUpper);
    expect(customs.progress, .72);
    expect(clearance.progress, .72);
    expect(customs.color, const Color(0xFFB26A00));

    expect(shipmentStatusInfo(en, 'out_for_delivery').progress, .88);

    final delivered = shipmentStatusInfo(en, 'delivered');
    expect(delivered.label, en.deliveredUpper);
    expect(delivered.description, en.statusDescDelivered);
    expect(delivered.color, const Color(0xFF16765C));
    expect(delivered.progress, 1);

    final cancelled = shipmentStatusInfo(en, 'cancelled');
    expect(cancelled.label, en.cancelledUpper);
    expect(cancelled.color, const Color(0xFFD72638));
    expect(cancelled.progress, 0);

    expect(shipmentStatusInfo(ar, 'in_transit').label, ar.inTransitUpper);
    expect(
      shipmentStatusInfo(ar, 'in_transit').description,
      ar.statusDescInTransit,
    );
  });

  test('timeline icons keep contains order after normalizeStatus', () {
    expect(shipmentTimelineIcon(''), Icons.circle_outlined);
    expect(shipmentTimelineIcon('   '), Icons.circle_outlined);
    expect(shipmentTimelineIcon('unknown-event'), Icons.circle_outlined);
    expect(shipmentTimelineIcon('cancelled'), Icons.circle_outlined);

    expect(
      shipmentTimelineIcon('  DELIVERED  '),
      Icons.check_circle_outline_rounded,
    );
    expect(
      shipmentTimelineIcon('out-for-delivery'),
      Icons.check_circle_outline_rounded,
    );
    expect(
      shipmentTimelineIcon('custom_delivery'),
      Icons.check_circle_outline_rounded,
    );
    expect(
      shipmentTimelineIcon('in_transit_delivered'),
      Icons.check_circle_outline_rounded,
    );

    expect(shipmentTimelineIcon('customs'), Icons.gavel_outlined);
    expect(shipmentTimelineIcon('customs_clearance'), Icons.gavel_outlined);

    expect(shipmentTimelineIcon('in_transit'), Icons.local_shipping_outlined);
    expect(shipmentTimelineIcon('departed'), Icons.local_shipping_outlined);
    expect(shipmentTimelineIcon('moving'), Icons.local_shipping_outlined);

    expect(shipmentTimelineIcon('confirmed'), Icons.verified_outlined);
    expect(shipmentTimelineIcon('approved'), Icons.verified_outlined);
    expect(
      shipmentTimelineIcon('confirmed_warehouse'),
      Icons.verified_outlined,
    );

    expect(shipmentTimelineIcon('prepared'), Icons.inventory_2_outlined);
    expect(shipmentTimelineIcon('warehouse'), Icons.inventory_2_outlined);
  });
}
