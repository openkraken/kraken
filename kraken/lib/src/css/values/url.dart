/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/painting.dart';

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#urls
class CSSUrl {
  static ImageType parseImageUrl(Uri resolvedUri, { cache = 'auto' }) {
    if (resolvedUri.isScheme('HTTP') || resolvedUri.isScheme('HTTPS')) {
        return (cache == 'store' || cache == 'auto')
            ? ImageType.cached
            : ImageType.network;
    } else if (resolvedUri.isScheme('FILE')) {
      return ImageType.file;
    } else if (resolvedUri.isScheme('DATA')) {
      return ImageType.dataUrl;
    } else if (resolvedUri.isScheme('BLOB')) {
      return ImageType.blob;
    } else {
      return ImageType.assets;
    }
  }
}
