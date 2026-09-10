class ShipmentDocumentItem {
  const ShipmentDocumentItem({
    required this.name,
    required this.path,
    required this.contentType,
    this.size,
    this.uploadedAt,
  });

  final String name;
  final String path;
  final String contentType;
  final Object? size;
  final Object? uploadedAt;

  bool get canOpen => path.trim().isNotEmpty;

  bool get isRemoteUrl {
    final value = path.trim().toLowerCase();
    return value.startsWith('http://') || value.startsWith('https://');
  }
}

List<ShipmentDocumentItem> shipmentDocumentsOf(Map<String, dynamic> shipment) {
  final rawDocuments = shipment['documents'];
  if (rawDocuments is! List) {
    return const [];
  }

  final documents = <ShipmentDocumentItem>[];

  for (final rawDocument in rawDocuments) {
    if (rawDocument is! Map) {
      continue;
    }

    final data = Map<String, dynamic>.from(rawDocument);
    final path = _firstText(data, const [
      'path',
      'storagePath',
      'url',
      'fileUrl',
    ]);
    if (path.isEmpty) {
      continue;
    }

    documents.add(
      ShipmentDocumentItem(
        name: _firstText(data, const ['name', 'fileName', 'filename']),
        path: path,
        contentType: _firstText(data, const ['contentType', 'mimeType']),
        size: _firstValue(data, const ['size', 'fileSize']),
        uploadedAt: _firstValue(data, const ['uploadedAt']),
      ),
    );
  }

  return documents;
}

String formatDocumentSize(Object? value) {
  final bytes = value is int
      ? value
      : int.tryParse(value?.toString() ?? '') ?? 0;

  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  return '$bytes B';
}

String _firstText(Map<String, dynamic> data, List<String> keys) {
  final value = _firstValue(data, keys);
  if (value == null) {
    return '';
  }
  return value.toString().trim();
}

Object? _firstValue(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    if (!data.containsKey(key)) {
      continue;
    }

    final value = data[key];
    if (value == null) {
      continue;
    }

    if (value is String && value.trim().isEmpty) {
      continue;
    }

    return value;
  }

  return null;
}
