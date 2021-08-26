/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
const String _defaultScheme = 'https';

class UriParser {

  Uri resolve(Uri base, Uri relative) {
    Uri result = base.resolveUri(relative);
    if (!result.hasScheme && result.host.isNotEmpty) {
      result = result.replace(scheme: _defaultScheme);
    }
    return result;
  }
}
