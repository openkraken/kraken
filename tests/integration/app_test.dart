// Imports the Flutter Driver API
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter_driver/flutter_driver.dart';
import 'dart:io';

final Directory specsDirectory = Directory('./integration/.specs');
final Directory snapshotsDirectory = Directory('./integration/snapshots');

final Directory raxComponentsDirectory =
    Directory('./integration/rax-components/build/kraken');

void main() async {
  if (!snapshotsDirectory.existsSync()) {
    snapshotsDirectory.createSync();
  }

  FlutterDriver driver = await FlutterDriver.connect();

  List<FileSystemEntity> specs = specsDirectory.listSync(recursive: true);
  List<Map<String, String>> testPayload = [];
  for (FileSystemEntity file in specs) {
    if (file.path.endsWith('js')) {
      String filename = path.basename(file.path);
      String code = File(file.path).readAsStringSync();
      testPayload.add({
        'filename': filename,
        'filepath': file.path,
        'code': code,
      });
    }
  }

  String status = await driver.requestData(jsonEncode(testPayload));
  await driver.close();

  if (status == 'failed') {
    exit(1);
  }
}
