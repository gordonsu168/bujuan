import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheUtils {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/cache';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  static Future<File> _localFile(String key) async {
    final path = await _localPath;
    return File('$path/$key.json');
  }

  static Future<void> setCache(String key, Map<String, dynamic> data) async {
    try {
      final file = await _localFile(key);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Error saving cache: $e');
    }
  }

  static Future<Map<String, dynamic>?> getCache(String key) async {
    try {
      final file = await _localFile(key);
      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents);
      }
    } catch (e) {
      print('Error reading cache: $e');
    }
    return null;
  }
}
