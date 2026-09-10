import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/utils/shipment_status_info.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_ar.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';
import 'package:tawam_shipping_app/locale_controller.dart';

void main() {
  final en = AppLocalizationsEn();
  final ar = AppLocalizationsAr();

  test('known statuses keep statusLabel after trim and normalize', () {
    expect(prettyShipmentStatus(en, '  in_transit  '), en.statusInTransit);
    expect(prettyShipmentStatus(ar, 'IN-TRANSIT'), ar.statusInTransit);
    expect(prettyShipmentStatus(en, 'pending'), en.statusPending);
    expect(prettyShipmentStatus(en, 'confirmed'), en.statusConfirmed);
    expect(prettyShipmentStatus(en, 'approved'), en.statusConfirmed);
    expect(prettyShipmentStatus(en, 'prepared'), en.statusPrepared);
    expect(prettyShipmentStatus(en, 'customs'), en.statusCustoms);
    expect(prettyShipmentStatus(en, 'customs_clearance'), en.statusCustoms);
    expect(
      prettyShipmentStatus(en, 'out_for_delivery'),
      en.statusOutForDelivery,
    );
    expect(prettyShipmentStatus(en, 'delivered'), en.statusDelivered);
    expect(prettyShipmentStatus(en, 'cancelled'), en.statusCancelled);
    expect(prettyShipmentStatus(en, 'canceled'), en.statusCancelled);
  });

  test('empty and unknown keep previous fallbacks', () {
    expect(prettyShipmentStatus(en, ''), en.shipmentUpdate);
    expect(prettyShipmentStatus(en, '   '), en.shipmentUpdate);
    expect(prettyShipmentStatus(ar, ''), ar.shipmentUpdate);

    expect(prettyShipmentStatus(en, 'warehouse-hold'), 'warehouse-hold');
    expect(prettyShipmentStatus(ar, 'warehouse-hold'), 'warehouse-hold');
    expect(
      prettyShipmentStatus(en, 'Door to Door'),
      LocaleController.optionLabel(en, 'Door to Door'),
    );
  });

  test('shipment_created is details-only and unchanged on track', () {
    expect(prettyShipmentStatus(en, 'shipment_created'), 'shipment_created');
    expect(prettyShipmentStatus(ar, 'shipment_created'), 'shipment_created');
    expect(
      prettyShipmentStatus(en, '  SHIPMENT_CREATED  '),
      'SHIPMENT_CREATED',
    );

    expect(
      prettyShipmentStatus(en, 'shipment_created', mapShipmentCreated: true),
      en.notifShipmentCreatedTitle,
    );
    expect(
      prettyShipmentStatus(ar, 'shipment_created', mapShipmentCreated: true),
      ar.notifShipmentCreatedTitle,
    );
    expect(
      prettyShipmentStatus(
        en,
        '  Shipment_Created  ',
        mapShipmentCreated: true,
      ),
      en.notifShipmentCreatedTitle,
    );
    expect(
      prettyShipmentStatus(
        ar,
        '  Shipment_Created  ',
        mapShipmentCreated: true,
      ),
      ar.notifShipmentCreatedTitle,
    );
  });
}
