import 'dart:convert';
import 'dart:typed_data';

import '../utils/api_client_exception.dart';
import 'base_provider.dart';

class FileProvider extends BaseProvider {
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  static const Map<String, String> _contentTypeByExtension = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
    required String folder,
  }) async {
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    final contentType = _contentTypeByExtension[extension];
    if (contentType == null) {
      throw ApiClientException('Dozvoljeni formati slike su: JPG, PNG i WebP.');
    }
    if (bytes.length > maxFileSizeBytes) {
      throw ApiClientException(
        'Slika je prevelika. Maksimalna dozvoljena veličina je 5 MB.',
      );
    }

    final response = await apiPostMultipart(
      'Files/upload',
      fileBytes: bytes,
      fileName: fileName,
      contentType: contentType,
      fields: {'folder': folder},
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['url'] as String;
  }
}
