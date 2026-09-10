import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app/utils/shipment_documents.dart';
import '../app/widgets/shipping_document_viewer.dart';
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

  late Future<List<Map<String, dynamic>>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _documentsFuture = _loadDocuments();
  }

  Future<List<Map<String, dynamic>>> _loadDocuments() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    final shipments = await FirebaseFirestore.instance
        .collection('shipments')
        .where('userId', isEqualTo: user.uid)
        .get();

    final documents = <Map<String, dynamic>>[];

    for (final shipmentDoc in shipments.docs) {
      final shipment = shipmentDoc.data();

      for (final document in shipmentDocumentsOf(shipment)) {
        documents.add({
          'item': document,
          'name': document.name,
          'path': document.path,
          'contentType': document.contentType,
          'size': document.size ?? 0,
          'uploadedAt': document.uploadedAt,
          'trackingNumber': (shipment['trackingNumber'] ?? '').toString(),
        });
      }
    }

    documents.sort((a, b) {
      final aDate = a['uploadedAt'];
      final bDate = b['uploadedAt'];

      if (aDate is Timestamp && bDate is Timestamp) {
        return bDate.compareTo(aDate);
      }

      return 0;
    });

    return documents;
  }

  Future<void> _openDocument(Map<String, dynamic> document) async {
    final item = document['item'];
    if (item is! ShipmentDocumentItem) {
      return;
    }

    await openShippingDocument(context: context, document: item);
  }

  Future<void> _refresh() async {
    setState(() {
      _documentsFuture = _loadDocuments();
    });

    await _documentsFuture;
  }

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryBlue),
            );
          }

          if (snapshot.hasError) {
            debugPrint('DOCUMENTS ERROR: ${snapshot.error}');
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

          final documents = snapshot.data ?? [];

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
        },
      ),
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
