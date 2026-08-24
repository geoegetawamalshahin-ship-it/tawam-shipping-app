import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdfrx/pdfrx.dart';

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

      final rawDocuments = shipment['documents'];

      if (rawDocuments is List) {
        for (final rawDocument in rawDocuments) {
          if (rawDocument is Map) {
            documents.add({
              'name': (rawDocument['name'] ?? '').toString(),
              'path': (rawDocument['path'] ?? '').toString(),
              'contentType': (rawDocument['contentType'] ?? '').toString(),
              'size': rawDocument['size'] ?? 0,
              'uploadedAt': rawDocument['uploadedAt'],
              'trackingNumber': (shipment['trackingNumber'] ?? '').toString(),
            });
          }
        }
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
    final l10n = AppLocalizations.of(context)!;
    try {
      final path = document['path']?.toString() ?? '';
      final name = document['name']?.toString() ?? '';
      final contentType = document['contentType']?.toString() ?? '';

      if (path.isEmpty) {
        throw Exception(l10n.documentPathMissing);
      }

      final signedUrl = await Supabase.instance.client.storage
          .from('shipping-documents')
          .createSignedUrl(path, 600);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _DocumentViewerScreen(
            url: signedUrl,
            name: name.isEmpty ? l10n.document : name,
            contentType: contentType,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.couldNotOpenDocument(e.toString()))));
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _documentsFuture = _loadDocuments();
    });

    await _documentsFuture;
  }

  String _formatSize(dynamic value) {
    final bytes = value is int ? value : int.tryParse(value.toString()) ?? 0;

    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '$bytes B';
  }

  IconData _documentIcon(String contentType) {
    if (contentType.contains('pdf')) {
      return Icons.picture_as_pdf_rounded;
    }

    if (contentType.contains('image')) {
      return Icons.image_outlined;
    }

    return Icons.insert_drive_file_outlined;
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
                            _documentIcon(contentType),
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
                                _formatSize(document['size']),
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
          const Icon(Icons.folder_copy_outlined, color: Color(0xFF07569E), size: 70),
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

class _DocumentViewerScreen extends StatelessWidget {
  final String url;
  final String name;
  final String contentType;

  const _DocumentViewerScreen({
    required this.url,
    required this.name,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = contentType.toLowerCase().contains('pdf');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF10233F)),
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF10233F),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isPdf
          ? PdfViewer.uri(Uri.parse(url))
          : Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(AppLocalizations.of(context)!.couldNotLoadImage),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
