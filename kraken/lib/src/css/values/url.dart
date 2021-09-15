

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart';

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#urls
class CSSUrl {
  static ImageProvider? parseUrl(Uri resolvedUri, { cache = 'auto', int? contextId }) {

    ImageProvider? imageProvider;
    if (resolvedUri.isScheme('HTTP') || resolvedUri.isScheme('HTTPS')) {
      // @TODO: Caching also works after image downloaded.
      ImageType cacheType = (cache == 'store' || cache == 'auto')
          ? ImageType.cached
          : ImageType.network;
      imageProvider = getImageProviderFactory(cacheType)(resolvedUri, [contextId]);
    } else if (resolvedUri.isScheme('FILE')) {
      File file = File.fromUri(resolvedUri);
      imageProvider = getImageProviderFactory(ImageType.file)(resolvedUri, file);
    } else if (resolvedUri.isScheme('DATA')) {
      // Data URL:  https://tools.ietf.org/html/rfc2397
      // dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
      UriData data = UriData.fromUri(resolvedUri);
      if (data.isBase64) {
        imageProvider = getImageProviderFactory(ImageType.dataUrl)(resolvedUri, data.contentAsBytes());
      }
    } else if (resolvedUri.isScheme('BLOB')) {
      // @TODO: support blob file url
      imageProvider = getImageProviderFactory(ImageType.blob)(resolvedUri);
    } else {
      // Fallback to asset image
      imageProvider = getImageProviderFactory(ImageType.assets)(resolvedUri);
    }

    return imageProvider;
  }
}
