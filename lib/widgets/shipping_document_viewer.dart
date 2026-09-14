import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../data/utils/shipment_documents.dart';

IconData shippingDocumentIcon(String contentType) {
  final type = contentType.toLowerCase();
  if (type.contains('pdf')) {
    return Icons.picture_as_pdf_rounded;
  }
  if (type.contains('image')) {
    return Icons.image_outlined;
  }
  return Icons.insert_drive_file_outlined;
}

Future<void> openShippingDocument({
  required BuildContext context,
  required ShipmentDocumentItem document,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final path = document.path.trim();
  final name = document.name.trim().isEmpty
      ? l10n.document
      : document.name.trim();

  try {
    if (path.isEmpty) {
      throw Exception(l10n.documentPathMissing);
    }

    final url = document.isRemoteUrl
        ? path
        : await Supabase.instance.client.storage
              .from('shipping-documents')
              .createSignedUrl(path, 600);

    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShippingDocumentViewerScreen(
          url: url,
          name: name,
          contentType: document.contentType,
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.couldNotOpenDocument(e.toString()))),
    );
  }
}

class ShippingDocumentViewerScreen extends StatelessWidget {
  const ShippingDocumentViewerScreen({
    super.key,
    required this.url,
    required this.name,
    required this.contentType,
  });

  final String url;
  final String name;
  final String contentType;

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
                      child: Text(
                        AppLocalizations.of(context)!.couldNotLoadImage,
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
