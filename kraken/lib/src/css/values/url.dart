/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart';

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#urls
class CSSUrl {

  static ImageProvider parseUrl(String rawInput, { cache = 'auto', int contextId }) {
    // support input string enclosed in quotation marks
    if ((rawInput.startsWith('\'') && rawInput.endsWith('\'')) ||
        (rawInput.startsWith('\"') && rawInput.endsWith('\"'))) {
      rawInput = rawInput.substring(1, rawInput.length - 1);
    }

    ImageProvider imageProvider;

    if (rawInput.startsWith('//') || rawInput.startsWith('http://') || rawInput.startsWith('https://')) {
      String url = rawInput.startsWith('//') ? 'https:' + rawInput : rawInput;
      // @TODO: caching also works after image downloaded
      if (cache == 'store' || cache == 'auto') {
        imageProvider = getImageProviderFactory(ImageType.cached)(url);
      } else {
        imageProvider = getImageProviderFactory(ImageType.network)(url, [contextId]);
      }
    } else if (rawInput.startsWith('file://')) {
      File file = File.fromUri(Uri.parse(rawInput));
      imageProvider = getImageProviderFactory(ImageType.file)(rawInput, file);
    } else if (rawInput.startsWith('data:')) {
      // Data URL:  https://tools.ietf.org/html/rfc2397
      // dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data

      UriData data = UriData.parse(rawInput);
      if (data.isBase64) {
        imageProvider = getImageProviderFactory(ImageType.dataUrl)(rawInput, data.contentAsBytes());
      }
    } else if (rawInput.startsWith('blob:')) {
      // @TODO: support blob file url
      imageProvider = getImageProviderFactory(ImageType.blob)(rawInput);
    } else {
      // Fallback to asset image
      imageProvider = getImageProviderFactory(ImageType.assets)(rawInput);
    }

    return imageProvider;
  }
}
