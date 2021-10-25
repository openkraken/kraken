/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
const String _defaultScheme = 'https';

bool isAssetAbsolutePath(String path) {
  return path.indexOf('assets/') == 0;
}

class UriParser {

  Uri resolve(Uri base, Uri relative) {
    // Don't resolve url from assets resource to assets resource.
    if (isAssetAbsolutePath(base.toString()) && isAssetAbsolutePath(relative.toString())) {
      return relative;
    }

    Uri result = base.resolveUri(relative);
    if (!result.hasScheme && result.host.isNotEmpty) {
      result = result.replace(scheme: _defaultScheme);
    }
    return result;
  }
}
