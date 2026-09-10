import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/utils/shipment_status_info.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_ar.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();
  final ar = AppLocalizationsAr();

  test('empty or non-list history returns no rows', () {
    expect(shipmentHistoryItems(en, {}), isEmpty);
    expect(shipmentHistoryItems(en, {'trackingHistory': []}), isEmpty);
    expect(shipmentHistoryItems(en, {'trackingHistory': 'nope'}), isEmpty);
    expect(
      shipmentHistoryItems(en, {
        'trackingHistory': ['skip', 1],
      }),
      isEmpty,
    );
  });

  test('track keys ignore statusHistory and changedAt', () {
    final shipment = {
      'statusHistory': [
        {
          'title': 'in_transit',
          'description': 'On the way',
          'changedAt': '2024-06-15T18:05:00',
        },
      ],
      'trackingHistory': [
        {
          'status': 'delivered',
          'note': 'At door',
          'timestamp': '2024-06-16T09:00:00',
        },
      ],
    };

    final track = shipmentHistoryItems(en, shipment);
    expect(track, hasLength(1));
    expect(track.single.title, en.statusDelivered);
    expect(track.single.description, 'At door');
    expect(track.single.icon, Icons.check_circle_outline_rounded);

    final details = shipmentHistoryItems(
      en,
      shipment,
      historyKeys: shipmentDetailsHistoryKeys,
      timeKeys: shipmentDetailsHistoryTimeKeys,
      mapShipmentCreated: true,
    );
    expect(details, hasLength(1));
    expect(details.single.title, en.statusInTransit);
    expect(details.single.description, 'On the way');
  });

  test('shipment_created mapping is details-only', () {
    final shipment = {
      'trackingHistory': [
        {'title': '  Shipment_Created  ', 'description': 'Raw note'},
      ],
    };

    final track = shipmentHistoryItems(en, shipment);
    expect(track.single.title, 'Shipment_Created');
    expect(track.single.description, 'Raw note');

    final detailsEn = shipmentHistoryItems(
      en,
      shipment,
      mapShipmentCreated: true,
    );
    expect(detailsEn.single.title, en.notifShipmentCreatedTitle);
    expect(detailsEn.single.description, en.timelineCreatedDesc);

    final detailsAr = shipmentHistoryItems(
      ar,
      shipment,
      mapShipmentCreated: true,
    );
    expect(detailsAr.single.title, ar.notifShipmentCreatedTitle);
    expect(detailsAr.single.description, ar.timelineCreatedDesc);
  });

  test('title status and event keys keep order and skip blanks', () {
    final items = shipmentHistoryItems(en, {
      'timeline': [
        {
          'title': '  ',
          'status': 'prepared',
          'event': 'ignored',
          'description': '  ',
          'note': 'Warehouse',
        },
      ],
    });

    expect(items.single.title, en.statusPrepared);
    expect(items.single.description, 'Warehouse');
    expect(items.single.time, en.awaitingUpdate);
  });
}
