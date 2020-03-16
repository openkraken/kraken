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

Future<dynamic> getScreenShot(int nodeId) {
  Completer completer = Completer();
  // 20ms is enough for next frame paint
  Timer(Duration(milliseconds: 20), () {
    if (!nodeMap.containsKey(nodeId)) {
      throw ('getScreenShot error: node (id: $nodeId) is not contains in nodeMap.');
    }
    if (!(nodeMap[nodeId] is Element)) {
      throw ('getScreenShot error: node (id: $nodeId) is not an Element.');
    }
    // repaint to get latest screenshot.
    Element node = nodeMap[nodeId];
    node.renderObject.markNeedsPaint();
    RendererBinding.instance.addPostFrameCallback((_) async {
      Uint8List bodyImage = await node.toBlob(devicePixelRatio: 1.0);
      List<int> bodyImageList = bodyImage.toList();
      completer.complete(bodyImageList);
    });
  });
  return completer.future;
}

Future<bool> matchScreenShot(int nodeId, String filename) async {
  List<int> screenPixels = await getScreenShot(nodeId);
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