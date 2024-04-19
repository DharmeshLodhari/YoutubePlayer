import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<File> getFileFromNetworkImage(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));
  final documentDirectory = await getApplicationDocumentsDirectory();
  final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  final File file = File(path.join(documentDirectory.path, '$fileName.png'));
  file.writeAsBytes(response.bodyBytes);
  return file;
}
