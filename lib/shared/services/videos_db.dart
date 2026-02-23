import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class VideosDb {
  static const String _assetPath = 'assets/data/videos.json';
  static const String _fileName = 'videos.json';

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    await file.parent.create(recursive: true);

    return file;
  }

  Future<void> init() async {
    final file = await _localFile();

    final exists = await file.exists();
    if (!exists) {
      final assetJson = await rootBundle.loadString(_assetPath);
      await file.writeAsString(assetJson);
    }
  }

  Future<Map<String, dynamic>> readAll() async {
    await init();

    final file = await _localFile();
    final text = await file.readAsString();
    final decoded = jsonDecode(text);

    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  Future<void> writeAll(Map<String, dynamic> data) async {
    await init();

    final file = await _localFile();
    final text = const JsonEncoder.withIndent('  ').convert(data);
    await file.writeAsString(text);
  }

  Future<void> createFolder(String folderName) async {
    final name = folderName.trim();
    if (name.isEmpty) return;

    final data = await readAll();
    data.putIfAbsent(name, () => <String, dynamic>{});
    await writeAll(data);
  }

  Future<List<String>> listFolders() async {
    final data = await readAll();
    final folders = data.keys.toList()..sort();
    return folders;
  }
}
