import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mess_prototype/services/server_config.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AvatarCache {
  static const String _directoryName = 'avatars';

  Future<Directory> _getDirectory() async {
    final baseDirectory = await getApplicationSupportDirectory();

    final directory = Directory(p.join(baseDirectory.path, _directoryName));

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  Future<String> saveAvatar({
    required String fileId,
    required List<int> bytes,
    required String extension
  }) async {
    final directory = await _getDirectory();

    final filePath = p.join(directory.path, '$fileId$extension');

    final file = File(filePath);

    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  Future<String?> downloadAvatar({
    required String fileId,
    required String token
  }) async {
    final response = await http.get(
      Uri.parse('$serverUrl/files/$fileId'),
      headers: {
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode != 200) return null;

    final contentType = response.headers['content-type'] ?? 'image/png';

    final extension = _extensionFromMimeType(contentType);

    return saveAvatar(fileId: fileId, bytes: response.bodyBytes, extension: extension);
  }

  Future<String?> getAvatarPath(String fileId) async {
    final directory = await _getDirectory();

    if (!await directory.exists()) {
      return null;
    }

    await for (final entity in directory.list()) {
      if (entity is File && p.basename(entity.path).startsWith('$fileId.')) {
        return entity.path;
      }
    }

    return null;
  }

  Future<void> deleteAvatar(String? path) async {
    if(path == null) return;

    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }

  String _extensionFromMimeType(String mimeType) {
    switch (mimeType.split(';').first.trim()) {
      case 'image/jpeg': return '.jpg';
      case 'image/png': return '.png';
      case 'image/webp': return '.webp';
      case 'image/gif': return '.gif';
      default: return '.img';
    }
  }
}