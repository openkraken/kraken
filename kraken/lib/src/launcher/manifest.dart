/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';
import 'dart:convert';

class Manifest {
  Manifest.fromJson(String json) {
    assert(json != null);
    window = ManifestWindow();
    Map raw = jsonDecode(json);
    if (raw.containsKey('window')) {
      Map rawWindow = raw['window'];

      if (rawWindow.containsKey('size')) {
        Map rawSize = rawWindow['size'];
        window.size = Size(rawSize['width'] ?? 0, rawSize['height'] ?? 0);
      }

      if (rawWindow.containsKey('title')) {
        window.title = rawWindow['title'];
      }

      if (rawWindow.containsKey('resizeable')) {
        window.resizeable = rawWindow['resizeable'];
      }
    }
  }

  Manifest({ this.window });
  ManifestWindow window;
}

class ManifestWindow {
  ManifestWindow({ this.size, this.resizeable });

  String title;
  Size size;
  bool resizeable;
}
