import 'package:get/get.dart';

import '../data/utils/shipment_documents.dart';
import 'shipment_controller.dart';

class ShippingDocumentsController extends GetxController {
  ShippingDocumentsController(this._shipmentController);

  final ShipmentController _shipmentController;

  final documents = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final loadError = RxnString();

  @override
  void onInit() {
    super.onInit();
    refreshDocuments();
  }

  Future<void> refreshDocuments() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      documents.assignAll(await _shipmentController.loadShippingDocuments());
    } catch (_) {
      loadError.value = 'error';
    } finally {
      isLoading.value = false;
    }
  }

  ShipmentDocumentItem? documentItemOf(Map<String, dynamic> document) {
    final item = document['item'];
    return item is ShipmentDocumentItem ? item : null;
  }
}
