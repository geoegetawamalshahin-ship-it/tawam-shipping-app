import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/utils/shipment_status_info.dart';

String _detailsDisplayedLocation({
  required Map<String, dynamic> shipment,
  required String status,
  required String pickup,
  required String delivery,
  String? liveLocation,
}) {
  return liveLocation?.trim().isNotEmpty == true
      ? liveLocation!.trim()
      : shipmentCurrentLocation(
          shipment: shipment,
          status: status,
          pickup: pickup,
          delivery: delivery,
          locationKeys: shipmentDetailsLocationKeys,
        );
}

void main() {
  test('field keys keep first non-empty source and skip blanks', () {
    final shipment = {
      'currentLocationName': '  ',
      'currentLocation': null,
      'currentArea': '  Salalah  ',
      'lastLocation': 'Old',
      'location': 'Port',
    };

    expect(
      shipmentCurrentLocation(
        shipment: shipment,
        status: 'in_transit',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      'Salalah',
    );
    expect(
      shipmentCurrentLocation(
        shipment: shipment,
        status: 'in_transit',
        pickup: 'Muscat',
        delivery: 'Dubai',
        locationKeys: shipmentDetailsLocationKeys,
      ),
      'Salalah',
    );
  });

  test('currentLocationName is details-only', () {
    final shipment = {
      'currentLocationName': 'Named yard',
      'currentLocation': 'Field location',
    };

    expect(
      shipmentCurrentLocation(
        shipment: shipment,
        status: 'in_transit',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      'Field location',
    );
    expect(
      shipmentCurrentLocation(
        shipment: shipment,
        status: 'in_transit',
        pickup: 'Muscat',
        delivery: 'Dubai',
        locationKeys: shipmentDetailsLocationKeys,
      ),
      'Named yard',
    );

    final nameOnly = {'currentLocationName': 'Named yard'};
    expect(
      shipmentCurrentLocation(
        shipment: nameOnly,
        status: 'in_transit',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      '',
    );
    expect(
      shipmentCurrentLocation(
        shipment: nameOnly,
        status: 'in_transit',
        pickup: 'Muscat',
        delivery: 'Dubai',
        locationKeys: shipmentDetailsLocationKeys,
      ),
      'Named yard',
    );
  });

  test('status fallbacks apply only when location fields are empty', () {
    expect(
      shipmentCurrentLocation(
        shipment: {},
        status: 'delivered',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      'Dubai',
    );
    expect(
      shipmentCurrentLocation(
        shipment: {},
        status: 'out_for_delivery',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      'Dubai',
    );
    expect(
      shipmentCurrentLocation(
        shipment: {},
        status: 'pending',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      'Muscat',
    );
    expect(
      shipmentCurrentLocation(
        shipment: {},
        status: 'confirmed',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      'Muscat',
    );
    expect(
      shipmentCurrentLocation(
        shipment: {},
        status: 'prepared',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      'Muscat',
    );
    expect(
      shipmentCurrentLocation(
        shipment: {},
        status: 'in_transit',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      '',
    );
    expect(
      shipmentCurrentLocation(
        shipment: {'currentLocation': 'Live field'},
        status: 'delivered',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      'Live field',
    );
  });

  test('details live GPS string wins over stored fields', () {
    final shipment = {
      'currentLocationName': 'Named yard',
      'currentLocation': 'Field location',
    };

    expect(
      _detailsDisplayedLocation(
        shipment: shipment,
        status: 'in_transit',
        pickup: 'Muscat',
        delivery: 'Dubai',
        liveLocation: '  GPS pin  ',
      ),
      'GPS pin',
    );
    expect(
      _detailsDisplayedLocation(
        shipment: shipment,
        status: 'in_transit',
        pickup: 'Muscat',
        delivery: 'Dubai',
        liveLocation: '   ',
      ),
      'Named yard',
    );
    expect(
      _detailsDisplayedLocation(
        shipment: shipment,
        status: 'in_transit',
        pickup: 'Muscat',
        delivery: 'Dubai',
      ),
      'Named yard',
    );
  });
}
