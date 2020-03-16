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
  List<Map<String, String>> testPayload = [];
  for (FileSystemEntity file in specs) {
    if (file.path.endsWith('js')) {
      String filename = path.basename(file.path);
      String code = File(file.path).readAsStringSync();
      testPayload.add({
        'filename': filename,
        'code': code,
      });
    }
  }

  await driver.requestData(jsonEncode(testPayload));
  await driver.close();
}

Future<ProcessResult> exec(String command, List<String> args,
    { String workingDirectory }) async {
  return await Process.run(command, args,
      workingDirectory: workingDirectory, runInShell: true);
}
