// Imports the Flutter Driver API
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter_driver/flutter_driver.dart';
import 'dart:io';

final Directory srcDirectory = Directory('./integration/dist');
final Directory snapshots = Directory('./integration/snapshots');

void main() async {
  if (!snapshots.existsSync()) {
    snapshots.createSync();
  }

  FlutterDriver driver = await FlutterDriver.connect();

  List<FileSystemEntity> sources = srcDirectory.listSync(recursive: true);
  List<Map<String, dynamic>> fileInfo = [];
  for (FileSystemEntity file in sources) {
    if (file.path.endsWith(('js'))) {
      String filename = path.basename(file.path);
      String code = File(file.path).readAsStringSync();
      fileInfo.add({
        'filename': filename,
        'code': code
      });
    }
  }

  await driver.requestData(jsonEncode(fileInfo));

  await driver.close();
}
