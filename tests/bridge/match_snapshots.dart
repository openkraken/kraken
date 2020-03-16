import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:kraken/element.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;

final Directory snapshots = Directory('./integration/snapshots');

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

Future<bool> matchImageSnapshot(Uint8List bytes, String filename) async {
  List<int> screenPixels = bytes.toList();
  final snap = File(path.join(snapshots.path, '$filename.png'));
  if (snap.existsSync()) {
    Uint8List snapPixels = snap.readAsBytesSync();
    int diffCounts = _countDifferentPixels(snapPixels, screenPixels);
    if (diffCounts == 0) {
      return true;
    } else {
      final newSnap = File(path.join(snapshots.path, '$filename.current.png'));
      newSnap.writeAsBytes(screenPixels);
      return false;
    }
  } else {
    await snap.writeAsBytes(screenPixels);
    return true;
  }
}