import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CacheManager {
  void deleteCache({bool clearAll = false}) async {
    final Directory tempDir = await getTemporaryDirectory();
    List<FileSystemEntity> list =
        tempDir.listSync(followLinks: false, recursive: clearAll);
    List<FileSystemEntity> temp = new List<FileSystemEntity>();
    list.forEach((element) {
      if (element is File) {
        temp.add(element);
      }
    });
    temp.forEach((element) {
      element.deleteSync(recursive: true);
    });
    debugPrint("Cache cleared");
  }
}
