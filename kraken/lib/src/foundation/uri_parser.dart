/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

class UriParser {
  Uri resolve(Uri base, Uri relative) {
    final Uri uri = base.resolveUri(relative);
    assert(uri.hasScheme);
    return uri;
  }
}
