import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:kraken/kraken.dart' as kraken;

void main() async {
  //  debugPaintSizeEnabled = true;
//  debugPaintLayerBordersEnabled = true;
  kraken.launch(
//    bundleURLOverride: 'http://127.0.0.1:58083/kraken_debug_server.js',
//    bundleURLOverride: 'http://127.0.0.1:9999/Maze/notable.js',
//    bundleURLOverride: 'http://127.0.0.1:3333/kraken/index.js?mock=true',
//    bundleURLOverride: 'http://127.0.0.1:56749/kraken_debug_server.js'
//    bundleURLOverride: 'http://localhost:9999/kraken/index.js',
    bundleURLOverride: 'http://127.0.0.1:3300/kraken_debug_server.js'

//    bundleURLOverride: 'http://127.0.0.1:9999/maze-flow/notable.js',
//    bundleURLOverride: 'http://127.0.0.1:9999/maze-flex/notable.js',
//    bundleURLOverride: 'http://127.0.0.1:9999/maze-flex-replaced/notable.js',
  );
}
