import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageService {
  ProfileImageService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<Uint8List?> pickCompressed(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 55,
      requestFullMetadata: false,
    );
    if (picked == null) return null;
    return picked.readAsBytes();
  }

  Future<Uint8List> prepareProfilePhoto(Uint8List bytes) async {
    const maxBytes = 350 * 1024;
    if (bytes.length <= maxBytes) return bytes;

    for (final width in <int>[320, 240, 160]) {
      final resized = await _resizePhotoPng(bytes, width);
      if (resized == null) continue;
      if (resized.length <= maxBytes || width == 160) {
        return resized;
      }
    }

    return bytes;
  }

  Future<Uint8List?> _resizePhotoPng(Uint8List bytes, int targetWidth) async {
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (png == null) return null;
      return png.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}
