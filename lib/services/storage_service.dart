import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static const String _productBucket = 'product-images';
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  static Future<String?> uploadProductImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.length > _maxFileSizeBytes) {
        throw StorageUploadException(
          'Image exceeds 5 MB limit. Please choose a smaller file.',
        );
      }

      final client = Supabase.instance.client;
      final extension = _sanitizeExtension(file.name);
      final fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}$extension';
      final contentType =
          lookupMimeType(file.name, headerBytes: bytes) ?? 'image/jpeg';

      await client.storage
          .from(_productBucket)
          .uploadBinary(
            fileName,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: contentType,
            ),
          );

      return client.storage.from(_productBucket).getPublicUrl(fileName);
    } on StorageUploadException {
      rethrow;
    } catch (error) {
      throw StorageUploadException('Failed to upload image: $error');
    }
  }

  static String _sanitizeExtension(String fileName) {
    final extension = p.extension(fileName);
    if (extension.isEmpty) {
      return '.jpg';
    }
    final normalized = extension.toLowerCase();
    switch (normalized) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.webp':
        return normalized;
      default:
        return '.jpg';
    }
  }
}

class StorageUploadException implements Exception {
  final String message;
  StorageUploadException(this.message);

  @override
  String toString() => message;
}
