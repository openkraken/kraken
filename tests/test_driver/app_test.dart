// Imports the Flutter Driver API
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'package:ansicolor/ansicolor.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

final Directory snapshots = Directory('./snapshots');
String pass = (AnsiPen()..green())('[TEST PASS]');
String err = (AnsiPen()..red())('[TEST ERROR]');

void main() {
  if (!snapshots.existsSync()) {
    snapshots.createSync();
  }

  group('Test Kraken App', () {
    FlutterDriver driver;

    int _countDifferentPixels(Uint8List imageA, Uint8List imageB) {
      if (imageA.length != imageB.length) {
        return -1;
      }

      int delta = 0;
      for (int i = 0; i < imageA.length; i+=1) {
        if (imageA[i] != imageB[i]) delta++;
      }
      return (delta / 4).floor();
    }

    Future<void> matchSnapshots(String fixture) async {
      final List<int> screenPixels = await driver.screenshot();
      final snap = File(path.join(snapshots.path, fixture + '.png'));
      if (snap.existsSync()) {
        Uint8List snapPixels = snap.readAsBytesSync();
        int diffCounts = _countDifferentPixels(snapPixels, screenPixels);
        if (diffCounts == 0) {
          print('$pass $fixture snaphost is equal!');
        } else {
          final newSnap = File(path.join(snapshots.path, fixture + '.current.png'));
          if (diffCounts == -1) {
            print('$err $fixture snapshot is NOT equal with old ones');
          } else {
            print('$err $fixture snaphost is NOT equal with $diffCounts} pixels.');
            print('please compare manually with ${snap.path} and ${newSnap.path}');
          }
          newSnap.writeAsBytes(screenPixels);
        }
      } else {
        await snap.writeAsBytes(screenPixels);
        print('Wrote ${snap.path} successfully!');
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

    Directory fixturesDir = Directory('./fixtures');
    List<FileSystemEntity> fixtures = fixturesDir.listSync();

    for (FileSystemEntity fixture in fixtures) {
      if (fixture.path.endsWith('.js')) {
        String basename = path.basename(fixture.path);
        basename = basename.substring(0, basename.length - 3);

        test('screenshot-$basename}', () async {
          String payload = File(fixture.path).readAsStringSync();
          await driver.requestData(jsonEncode({
            'type': 'startup',
            'payload': payload,
          }));
          await matchSnapshots(basename);
        });
      }
    }
  });
}
