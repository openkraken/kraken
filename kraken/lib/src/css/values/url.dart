/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart';

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#urls

class CSSUrl {
  static ImageProvider getImageProviderByUrl(String url, {String cache = 'auto'}) {
    if (url.startsWith('//') || url.startsWith('http://') ||
        url.startsWith('https://')) {
      url = url.startsWith('//') ? 'https:' + url : url;
      // @TODO: caching also works after image downloaded
      if (cache == 'store' || cache == 'auto') {
        return CachedNetworkImage(url);
      } else {
        return NetworkImage(url);
      }
    } else if (url.startsWith('file://')) {
      return FileImage(File.fromUri(Uri.parse(url)));
    } else {
      // Fallback to asset image
      return AssetImage(url);
    }
  }

}
