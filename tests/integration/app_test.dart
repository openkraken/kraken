// Imports the Flutter Driver API
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter_driver/flutter_driver.dart';
import 'dart:io';

final Directory specsDirectory = Directory('./integration/.specs');
final Directory snapshotsDirectory = Directory('./integration/snapshots');

void main() async {
  if (!snapshotsDirectory.existsSync()) {
    snapshotsDirectory.createSync();
  }

  FlutterDriver driver = await FlutterDriver.connect();

  List<FileSystemEntity> specs = specsDirectory.listSync(recursive: true);
  List<Map<String, String>> mainTestPayload = [];
  for (FileSystemEntity file in specs) {
    if (file.path.endsWith('js')) {
      String filename = path.basename(file.path);
      String code = File(file.path).readAsStringSync();
      mainTestPayload.add({
        'filename': filename,
        'filepath': file.path,
        'code': code,
      });
    }
  }

  var reversedSpecs = specs.reversed;
  List<Map<String, String>> childTestPayload = [];

  for (FileSystemEntity file in reversedSpecs) {
    if (file.path.endsWith('js')) {
      String filename = path.basename(file.path);
      String code = File(file.path).readAsStringSync();
      childTestPayload.add({
        'filename': filename,
        'filepath': file.path,
        'code': code,
      });
    }
  }

  String status = await driver.requestData(jsonEncode([mainTestPayload, childTestPayload]));
  await driver.close();

  if (status == 'failed') {
    exit(1);
  }
}
