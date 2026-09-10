import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/utils/shipment_documents.dart';

void main() {
  test('documents stay on the shipment that owns them', () {
    final shipment = {
      'id': 's1',
      'trackingNumber': 'TAS-2026-000079',
      'documents': [
        {
          'name': 'invoice.pdf',
          'path': 'shipments/s1/invoice.pdf',
          'contentType': 'application/pdf',
          'size': 2048,
        },
      ],
    };

    final otherShipment = {'id': 's2', 'trackingNumber': 'TAS-2026-000080'};

    final owned = shipmentDocumentsOf(shipment);
    expect(owned, hasLength(1));
    expect(owned.single.name, 'invoice.pdf');
    expect(owned.single.path, 'shipments/s1/invoice.pdf');
    expect(shipmentDocumentsOf(otherShipment), isEmpty);
  });

  test('admin aliases still attach the file to that shipment only', () {
    final shipment = {
      'documents': [
        {
          'fileName': 'pod.jpg',
          'fileUrl': 'https://example.com/pod.jpg',
          'mimeType': 'image/jpeg',
          'fileSize': 512,
        },
        {'name': 'skipped-empty-path.pdf', 'path': '  '},
      ],
    };

    final documents = shipmentDocumentsOf(shipment);
    expect(documents, hasLength(1));
    expect(documents.single.name, 'pod.jpg');
    expect(documents.single.path, 'https://example.com/pod.jpg');
    expect(documents.single.isRemoteUrl, isTrue);
    expect(documents.single.contentType, 'image/jpeg');
    expect(formatDocumentSize(2048), '2.0 KB');
  });
}
