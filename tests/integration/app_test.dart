// Imports the Flutter Driver API
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'package:ansicolor/ansicolor.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

final Directory snapshots = Directory('./integration/snapshots');
final Directory fixturesDir = Directory('./integration/fixtures');
String pass = (AnsiPen()..green())('[TEST PASS]');
String err = (AnsiPen()..red())('[TEST ERROR]');

String addJavaScriptClosure(String input) {
  return '(function(){\n$input\n})();';
}

void main() {
  bool hasNotMatchSnapshot = false;
  if (!snapshots.existsSync()) {
    snapshots.createSync();
  }

  group('Test Kraken App', () {
    FlutterDriver driver;

    int _countDifferentPixels(Uint8List imageA, List<int> imageB) {
      if (imageA.length != imageB.length) {
        return -1;
      }

      int delta = 0;
      for (int i = 0; i < imageA.length; i+=1) {
        if (imageA[i] != imageB[i]) delta++;
      }
      return (delta / 4).floor();
    }

    Future<bool> matchSnapshots(String fixture, List<int> screenPixels) async {
      final snap = File(path.join(snapshots.path, fixture + '.png'));
      if (snap.existsSync()) {
        Uint8List snapPixels = snap.readAsBytesSync();
        int diffCounts = _countDifferentPixels(snapPixels, screenPixels);
        if (diffCounts == 0) {
          print('$pass $fixture snaphost is equal!');
          return true;
        } else {
          hasNotMatchSnapshot = true;
          final newSnap = File(path.join(snapshots.path, fixture + '.current.png'));
          newSnap.writeAsBytes(screenPixels);
          if (diffCounts == -1) {
            stderr.write('$err $fixture snapshot is NOT equal with old ones\n');
          } else {
            stderr.write('$err $fixture snaphost is NOT equal with $diffCounts} pixels. '
                'please compare manually with ${snap.path} and ${newSnap.path}\n');
          }
          return false;
        }
      } else {
        await snap.writeAsBytes(screenPixels);
        print('Wrote ${snap.path} successfully!');
        return true;
      }
    }

    // Connect flutter driver.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Disconnect after tests.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    List<FileSystemEntity> fixtures = fixturesDir.listSync();

    for (FileSystemEntity fixture in fixtures) {
      if (fixture.path.endsWith('.js')) {
        String basename = path.basename(fixture.path);
        basename = basename.substring(0, basename.length - 3);

        test('Match Snapshot $basename', () async {
          String payload = addJavaScriptClosure(File(fixture.path).readAsStringSync());
          String imageListJSON = await driver.requestData(jsonEncode({
            'type': 'startup',
            'case': basename,
            'payload': payload,
          }));

          // Transform List<dynamic> to List<int>
          List<int> snapshot = (jsonDecode(imageListJSON) as List).cast<int>().toList();
          expect(await matchSnapshots(basename, snapshot), true,
            reason: 'Snapshot "$basename" NOT equal.');
        });
      }
    }

    if (hasNotMatchSnapshot) {
      fail('Some snapshot not matched, please check the log above.');
    }
  });
}
