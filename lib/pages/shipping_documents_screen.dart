import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/utils/shipment_documents.dart';
import '../widgets/shipping_document_viewer.dart';
import '../controllers/shipping_documents_controller.dart';
import '../l10n/app_localizations.dart';

class ShippingDocumentsScreen extends StatefulWidget {
  const ShippingDocumentsScreen({super.key});

  @override
  State<ShippingDocumentsScreen> createState() =>
      _ShippingDocumentsScreenState();
}

class _ShippingDocumentsScreenState extends State<ShippingDocumentsScreen> {
  static const Color _primaryBlue = Color(0xFF07569E);
  static const Color _darkNavy = Color(0xFF10233F);
  static const Color _pageBackground = Color(0xFFF4F7FB);
  static const Color _mutedText = Color(0xFF8B95A3);

  late final ShippingDocumentsController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.find<ShippingDocumentsController>();
  }

  Future<void> _openDocument(Map<String, dynamic> document) async {
    final item = _c.documentItemOf(document);
    if (item == null) return;
    await openShippingDocument(context: context, document: item);
  }

  Future<void> _refresh() => _c.refreshDocuments();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _darkNavy),
        ),
        title: Text(
          l10n.shippingDocuments,
          style: const TextStyle(
            color: _darkNavy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Obx(() {
        if (_c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _primaryBlue),
          );
        }

        if (_c.loadError.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.couldNotLoadDocuments,
                    style: const TextStyle(
                      color: _darkNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _refresh,
                    child: Text(l10n.tryAgainLower),
                  ),
                ],
              ),
            ),
          );
        }

        final documents = _c.documents.toList();

        if (documents.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 250), _EmptyDocuments()],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: documents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final document = documents[index];

              final nameRaw = document['name'].toString().trim();
              final name = nameRaw.isEmpty ? l10n.document : nameRaw;
              final trackingNumber = document['trackingNumber'].toString();
              final contentType = document['contentType'].toString();

              return InkWell(
                onTap: () => _openDocument(document),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE7EDF5)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D10233F),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FD),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          shippingDocumentIcon(contentType),
                          color: _primaryBlue,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _darkNavy,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              trackingNumber,
                              style: const TextStyle(
                                color: _mutedText,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              formatDocumentSize(document['size']),
                              style: const TextStyle(
                                color: _mutedText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF16765C),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _EmptyDocuments extends StatelessWidget {
  const _EmptyDocuments();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Icon(
            Icons.folder_copy_outlined,
            color: Color(0xFF07569E),
            size: 70,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noDocumentsYet,
            style: const TextStyle(
              color: Color(0xFF10233F),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.documentsEmptyBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8B95A3),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
